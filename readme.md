## About
This is the code for my static website, [mustard.lol](https://mustard.lol).

## Development
There are a few dependencies required by the build and deployment scripts, including pandoc,
fswatch, browsersync, and the AWS CLI. You'll figure these out when things fail with command not
found errors.

New pages just need `.md` and `.metadata` files in the pages dir with matching prefixes.

Build with `bin/build.zsh`, or `bin/build.zsh --server` to start a continuously updating local test
server.

Deploy with `bin/deploy.zsh`. You'll need permissions setup first. To do so:

1. Create user in console
    * Attach ```assume-mustard-lol-deployer-policy``` and ```mustard-lol-deployment-policy```
1. Create something like the following in ```~/.aws/config```:
   ```
   [profile mustard-lol-deployer]
   role_arn = arn:aws:iam::900943508744:role/mustard-lol-deployer
   region = us-west-2
   source_profile = default
   ```
1. Configure the default profile with the user you created.
