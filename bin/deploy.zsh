#!/usr/bin/env zsh

bin/build.zsh --prod

echo "Deploying..."

aws --profile mustard-lol-deployer s3 rm s3://mustard.lol --recursive

(
    cd build/site
    for f in **/*(.); do
        if [[ "$(head -n 1 "$f")" = '<!DOCTYPE html>' ]]; then

            # Needed for extentionless pages
            echo "Using text/html content-type for "$f""
            aws --profile mustard-lol-deployer s3 cp "$f" s3://mustard.lol/"$f" --acl public-read --content-type "text/html"
        else
            aws --profile mustard-lol-deployer s3 cp "$f" s3://mustard.lol/"$f" --acl public-read
        fi
    done
)

echo "Done."
