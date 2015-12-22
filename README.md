# Fastlane configuration

This is an example configuration of how we configure our [Fastlane](http://fastlane.tools) setup.

## Setup

The only thing you need to do is install the fastlane gem. Install snapshot by running this command in your CLI:

```
$ gem install fastlane
```

Copy the fastlane folder from this repo to your project root, and start tweaking.

## Our configuration

Our Fastlane configuration currently supports the following lanes.

### CI lane

Run the CI lane.

    $ fastlane ci

Performs the following tasks:

- Build the application.
- Run the tests.
- Send notifications to Slack.

### TestFlight lane

Run the TestFlight lane.

    $ fastlane testflight

Performs the following tasks:

- Version bumping with tagging.
- Build the application.
- Run the tests.
- Upload the application to Apple TestFlight.
- Upload the dSYM to Splunk.
- Send notifications to Slack.

### HockeyApp lane

Run the HockeyApp lane.

    $ fastlane hockey

Performs the following tasks:

- Version bumping with tagging.
- Build the application.
- Run the tests.
- Upload the application to HockeyApp.
- Send notifications to Slack.

## License

Copyright (c) 2015 iCapps

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
