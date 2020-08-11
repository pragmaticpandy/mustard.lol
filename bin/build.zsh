#!/usr/bin/env zsh

# This is a map that is imported for pages.
typeset -A metadata

local site_dir=build/site
mkdir -p "$site_dir"
rm -rf build/tmp

build() (

    local bodies_dir=build/tmp/html-bodies
    mkdir -p "$bodies_dir"

    # create html bodies
    for f in pages/**/*(.); do
        if [[ $f:t:e == "md" ]]; then
            pandoc $f > "$bodies_dir"/$f:t:r.html
        fi
    done

    #
    # Begin index page generation
    #

    # create index html body
    local index_dir=build/tmp/index
    mkdir -p "$index_dir"

    local index_md="$index_dir"/index.md
    cp special-pages/index/index.md "$index_md"
    local pages_list="$index_dir"/pages.txt
    echo "" > "$pages_list"
    for f in pages/**/*(.); do

        # for every page on the site except this page, add a line to the pages list
        if [[ $f:t:e == "metadata" && $f:t != "index.metadata" ]]; then
            source $f
            echo ${metadata[created]} \[${metadata[title]}\]\(${metadata[url]}\) >> "$pages_list"
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

    pandoc "$index_md" > "$bodies_dir"/index.html

    #
    # End index page generation
    #

    local unsubstituted_html_dir=build/tmp/unsubstituted-html
    mkdir -p "$unsubstituted_html_dir"

    # create html
    for f in "$bodies_dir"/* ; do
        local suffix=resources/html-suffix.html
        if [[ $f:t == "index.html" ]] ; then
            suffix=resources/html-suffix-no-home-button.html
        fi

        cat resources/html-prefix.html $f "$suffix" > "$unsubstituted_html_dir"/$f:t
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
        cp $f "$site_dir"/${metadata[url]}
    done

    rsync -a copy-as-is/ "$site_dir"
)

build
echo "Done."

if [[ $1 == "--server" ]]; then
    echo "Will listen for changes..."
    (browser-sync start --server $site_dir --files $site_dir --no-notify --no-open)&
    fswatch -r --exclude bin --exclude build -m poll_monitor -0 . | while read -d "" event ; do
        build
    done
fi