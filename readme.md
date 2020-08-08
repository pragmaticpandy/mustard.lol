## Permissions setup
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

## Development
Regular old posts need a `.md` and `.metadata` file in the pages dir with matching prefixes.

Build with `bin/build.zsh`, or `bin/build.zsh --server` to start a continously updating local test
server.

Deploy with `bin/deploy.zsh`.
