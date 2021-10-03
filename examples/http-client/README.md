# HTTP Client Example

This example shows how to build a HTTP client with Lean, which sends a GET request to <http://www.example.com>.

To run this example, switch to the `example/http-client` folder, build and run.

```sh
$ cd examples/http-client
$ lake build-bin
$ ./build/bin/http-client
```

You will see outputs like this:

```html
Remote Addr: (93.184.216.34, 80, AF_INET)
Connected!
Send 43 bytes!

-- Responses --

HTTP/1.1 200 OK
Accept-Ranges: bytes
Age: 268014
Cache-Control: max-age=604800
Content-Type: text/html; charset=UTF-8
Date: Sun, 03 Oct 2021 14:13:00 GMT
Etag: "3147526947"
Expires: Sun, 10 Oct 2021 14:13:00 GMT
Last-Modified: Thu, 17 Oct 2019 07:18:26 GMT
Server: ECS (sab/5695)
Vary: Accept-Encoding
X-Cache: HIT
Content-Length: 1256

<!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
    body {
        background-color: #f0f0f2;
        margin: 0;
        padding: 0;
        font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
        
    }
    div {
        width: 600px;
        margin: 5em auto;
        padding: 2em;
        background-color: #fdfdff;
        border-radius: 0.5em;
        box-shadow: 2px 3px 7px 2px rgba(0,0,0,0.02);
    }
    a:link, a:visited {
        color: #38488f;
        text-decoration: none;
    }
    @media (max-width: 700px) {
        div {
            margin: 0 auto;
            width: auto;
        }
    }
    </style>    
</head>

<body>
<div>
    <h1>Example Domain</h1>
    <p>This domain is for use in illustrative examples in documents. You may use this
    domain in literature without prior coordination or asking for permission.</p>
    <p><a href="https://www.iana.org/domains/example">More information...</a></p>
</div>
</body>
</html>

```