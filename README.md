## JavaScript implementation of a diplomatic game.
NOTE: This is currently in development, so the readme is developer-focused.

# Prerequisites
- Gulp (JS task runner) `npm install -g gulp`
- Ruby's SASS (for css compilation) `gem install sass`

# Setup
Run `npm install` and `bower install`

# Running
Run `gulp serve` for a browser preview. It autoupdates as you make
changes to html/js/css!

# Testing
- (setup): run `bower install` in the `/test` folder
- Run `gulp serve`
- Load `http://localhost:9000/test/`

# Building
Run `gulp` to build into `dist/`

# Planning
Current planning document at [Project Planning](https://hackpad.com/jsDip-Project-Plan-Jj5sK0HFCvn)

# Cheatsheet

- Add a frontend package: `bower install <package name> --save`
- Add a frontend test-related package: `bower install <package name> --save-dev`
- Add an npm package: `npm install <package name> --save-dev` (assuming
  all npm packages are for dev tasks)
