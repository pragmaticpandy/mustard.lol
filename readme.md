## About
This is the code for my static website, [mustard.lol](https://mustard.lol).

## Environment setup
There are a few dependencies required by the build and deployment scripts, including `pandoc`,
`fswatch`, `browser-sync`, and the AWS CLI. You'll figure these out when things fail with command not
found errors. The following should work for these:

* `brew install pandoc`
* `brew install fswatch`
* For `browsersync`
    1. [Install NPM](https://www.npmjs.com/get-npm)
    2. `npm install -g browser-sync`
* [AWS CLI install](https://aws.amazon.com/cli/)

For deployment to work, setup permissions like so:

1. Create user in console
    * Attach ```assume-mustard-lol-deployer-policy``` and ```mustard-lol-deployment-policy```
1. Create something like the following in ```~/.aws/config```:
   ```
   [profile mustard-lol-deployer]
   role_arn = arn:aws:iam::900943508744:role/mustard-lol-deployer
   region = us-west-2
   source_profile = default
   ```
1. Configure the default profile with the user you created: `aws configure`

## Development

New pages just need `.md` and `.metadata` files in the pages dir with matching prefixes.

Build with `bin/build.zsh`, or `bin/build.zsh --server` to start a continuously updating local test
server.

Deploy with `bin/deploy.zsh`, but make sure you've stopped any local server first.

