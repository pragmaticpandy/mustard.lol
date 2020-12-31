#!/usr/bin/env zsh

if [[ $1 == "--prod" ]]; then
    rm -rf build
fi

# This is a map that is imported for pages.
typeset -A metadata

local site_dir=build/site
mkdir -p "$site_dir"
rm -rf build/tmp

build() (

    local markdown_dir=build/tmp/markdown
    mkdir -p "$markdown_dir"

    # Copy markdown to staging area
    rsync -a pages/ "$markdown_dir"

    #
    # Ammend index page body
    #

    # create index html body
    local index_dir=build/tmp/index
    mkdir -p "$index_dir"

    local index_md="$markdown_dir"/index.md
    local pages_list="$index_dir"/pages.txt
    echo "" > "$pages_list"
    for f in pages/**/*(.); do

        # for every page on the site except this page, add a line to the pages list
        if [[ $f:t:e == "metadata" && $f:t != "index.metadata" ]]; then
            source $f
            if [[ $1 == "--prod" ]]; then
                local url=${metadata[url]}
            else
                # browser-sync doesn't support no extention
                local url=${metadata[url]}.html
            fi

            echo ${metadata[created]} \[${metadata[title]}\]\($url\) >> "$pages_list"
        fi
    done

    # Newest pages first
    local sorted_pages="$index_dir"/sorted-pages.txt
    echo "" > "$sorted_pages"
    cat "$pages_list" | sort -r > "$sorted_pages"

    printf "\n\n" >> "$index_md"
    while IFS='' read -r line || [ -n "${line}" ]; do
        if [[ ! -z "${line}" ]] ; then
            printf "%s—%s\n\n" \
                "$(date -d \
                    "$(echo "${line}" | awk '{split($0, line_parts," "); print line_parts[1]}')" \
                    "+%B %-d, %Y")" \
                "$(echo "${line}" | awk \
                    '{n=split($0, line_parts," "); for (i = 2; i <= n; i++) print line_parts[i]}')" \
                >> "$index_md"
        fi
    done < "$sorted_pages"

    # close the content-text div
    printf "</div>\n" >> "$index_md"

    #
    # End index page amendment
    #

    local bodies_dir=build/tmp/html-bodies
    mkdir -p "$bodies_dir"

    # create html bodies
    for f in "$markdown_dir"/*(.); do
        if [[ $f:t:e == "md" ]]; then
            pandoc $f > "$bodies_dir"/$f:t:r.html
        fi
    done

    local unsubstituted_html_dir=build/tmp/unsubstituted-html
    mkdir -p "$unsubstituted_html_dir"

    # create html
    for f in "$bodies_dir"/* ; do
        local top_nav_div=resources/top-nav-div.html
        local bottom_nav_div=resources/home-button-div.html
        if [[ $f:t == "index.html" ]] ; then
            local top_nav_div=resources/theme-button-div.html
            local bottom_nav_div=resources/empty-div.html
        fi

        cat resources/prefix.html \
            "$top_nav_div" \
            resources/open-content-div.html \
            $f \
            resources/close-div.html \
            "$bottom_nav_div" \
            resources/suffix.html > "$unsubstituted_html_dir"/$f:t

    done

    for f in "$unsubstituted_html_dir"/* ; do
        source pages/$f:t:r.metadata

        # Make pretty dates available
        metadata[pretty_created]=$(date -d "${metadata[created]}" "+%B %-d, %Y")
        metadata[pretty_updated]=$(date -d "${metadata[updated]}" "+%B %-d, %Y")

        for key val in ${(kv)metadata}; do

            # anything in the text that has the ␚ symbol followed by a metadata key will be substituted
            sed -i '.sed-backup' "s/␚$key/$val/g" $f
        done
    done

    rm "$unsubstituted_html_dir"/*.sed-backup

    for f in "$unsubstituted_html_dir"/* ; do
        source pages/$f:t:r.metadata
        if [[ $1 == "--prod" || ${metadata[url]} == "index.html" ]]; then
            local url=${metadata[url]}
        else
            # browser-sync doesn't support no extention
            local url=${metadata[url]}.html
        fi

        cp $f "$site_dir"/$url
    done

    rsync -a copy-as-is/ "$site_dir"

    sed 's/␚title/404/g' resources/prefix.html > "$site_dir"/404.html
    cat resources/home-button-div.html \
        resources/open-content-div.html \
        resources/404-body.html \
        resources/close-div.html \
        resources/empty-div.html \
        resources/suffix.html >> "$site_dir"/404.html
)

echo "Building..."
build $@
echo "Done."

if [[ $1 == "--server" ]]; then
    echo "Will listen for changes..."
    (browser-sync start --server $site_dir --files $site_dir --no-notify --no-open)&
    fswatch -r --exclude bin --exclude build -m poll_monitor -0 . | while read -d "" event ; do
        build $@
    done
fi
