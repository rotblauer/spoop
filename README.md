![](./app/assets/images/spoop_icon_small.png)

## Poop is life.

Spoop is poo-tracking application designed (at this point) specifically and unofficially for donors at [Open Biome](//openbiome.org) This is its web app and API. The [iOS app](https://itunes.apple.com/us/app/spoop/id1121224366?mt=8) reads and writes the data made available through the API controllers here.


## Tests
How to run them, because I'll forget these things.
```
$ rake test:models # model driven (Unit tests)
$ rake test:controllers # only api, deferring to integration-style tests
$ rake test:integration # controller/model interaction driven

$ rake test # Cuz I couldn't get MiniTest to rake. But the tests do run. But I don't
# know how to run only them ...
```
