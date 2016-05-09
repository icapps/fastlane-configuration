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
- Run the tests on your AWS Device Farm.
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
- Upload the dSYM to Crittercism.
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

## Extra Information

### Crittercism

To obtain a OAuth Token for a application. You can run the following cURL request.

    $ curl -X POST https://developers.crittercism.com/v1.0/token -u <Client ID> -d 'grant_type=password&username=<user e-mail>&password=<user-password>&scope=app%2F<app id>%2Fsymbols'

 - Client ID: Can be found [here](https://app.crittercism.com/developers/user-settings) (OAuth Client ID)
 - Username: You're Crittercism Email Address
 - Password: You're Crittercism password
 - App ID: The ID of you're application

## License

Copyright (c) 2015 iCapps

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
