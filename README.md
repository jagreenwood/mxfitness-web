# mxfitness-web

## To start development:

- Install [Xcode 11.4 beta](https://developer.apple.com/download/)
- From Terminal issue `sudo xcode-select -s /Applications/Xcode-Beta.app` to set this version of Xcode as the current version
- Install the RC of [Vapor 4](https://docs.vapor.codes/4.0/install/macos/) `brew install vapor/tap/vapor-beta`
- From Terminal issue `createdb mxfitness` to create Postgres database

Note: If running in Xcode, the working directory must be set. 
mxfitness -> Edit Scheme -> Run, tick the box "User custom working directory" and select the root project directory
