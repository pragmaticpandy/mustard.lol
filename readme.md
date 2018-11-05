## Initial set up - Ruby
Installed ruby with rbenv
https://github.com/rbenv/rbenv

Installed Ruby 2.5.3

Use it:
rbenv global 2.5.3

## Building
bundle exec jekyll serve

## Deploying
* Delete route 53 alias
* take S3 static hosting offline
* Copy contents of generated site folder to S3 bucket
* put s3 static hosting back online with index.html and 404.html
* create route 53 alias again
* test

