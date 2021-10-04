# HTTP Server Example

This examples shows how to build a HTTP server with Lean, which listens to <http://localhost:8080>. 

To run this example, switch to the `example/http-server` folder, build and run.

*NOTE: As `lake` is undergoing breaking changes, the recommended revision to use is [`111a47f`](https://github.com/leanprover/lake/commit/111a47f8964088aa452aa0fcdd0c1d88562cca68), otherwise you may see errors and have to modify the `lakefile.lean` file yourself.*

```sh
$ cd examples/http-server
$ lake build-bin
$ ./build/bin/http-server
```

Now you can open <http://localhost:8080> in your browser and check the response.