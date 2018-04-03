# Fastlane configuration

This is an example configuration of how we configure our [Fastlane](http://fastlane.tools) setup.

## Setup

The only thing you need to do is install the fastlane gem. Install snapshot by running this command in your CLI:

```
$ gem install fastlane
```

Copy the fastlane folder from this repo to your project root, and start tweaking.

There are currently 2 fastlane configuration available, one for iOS and one for
Android. Please choose the one that interests you.

## Extra Information

### Apteligent

There is an Apteligent script available on our [Github](https://github.com/icapps/scripts/tree/master/ruby/generate_apteligent_token) where you can generate the
correct authentication codes.

## Remarks

### 'pilot' team id

When specifying the team_id parameter in the 'pilot' section of your fastfile, you can't use the team id as mentioned in the Apple Developer portal.
The correct team id can be found as follows:

- Login to itunesconnect (https://itunesconnect.apple.com/)
- Get output (JSON) from (https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/detail)
- You can now get your iTunes Connect ids from the associatedAccounts array with the different contentProvider objects - the entry named contentProviderId reflects the iTunes Connect id, lookup for the name value to pick the correct one

## License

Copyright (c) 2015 iCapps

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
