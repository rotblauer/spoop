## Test

```
$ rake test:models # model driven (Unit tests)
$ rake test:controllers # only api, deferring to integration-style tests
$ rake test:integration # controller/model interaction driven 
$ rake minitest:features # ui-driven
```