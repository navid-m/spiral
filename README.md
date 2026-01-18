# Spiral

A modern, lightweight web framework for Haxe.

## Features

- Express-style API
- Fast C++ native performance with hxcpp
- Flexible routing with URL parameters
- Middleware support
- JSON request/response handling
- CORS support
- Built-in logging
- Static file serving
- Query string parsing

## Quick Start

```haxe
import spiral.*;

class Main {
    static function main() {
        var app = Spiral.createServer("127.0.0.1", 8080);
        
        app.use(MiddlewareHelper.logger());
        app.use(MiddlewareHelper.cors());
        app.use(MiddlewareHelper.bodyParser());
        
        app.get("/", function(req, res) {
            res.html("<h1>Hello, Spiral!</h1>");
        });
        
        app.get("/api/hello", function(req, res) {
            res.json({ message: "Hello, World!" });
        });
        
        app.listen(function() {
            trace("Server is ready!");
        });
    }
}
```

## Building

```bash
haxe build.hxml
./bin/cpp/Main
```

## API Reference

### Creating a Server

```haxe
var app = Spiral.createServer("127.0.0.1", 8080);
```

### Routes

```haxe
// GET request
app.get("/path", function(req, res) {
    res.text("Hello!");
});

// POST request
app.post("/path", function(req, res) {
    res.json({ status: "created" });
});

// Other HTTP methods
app.put("/path", handler);
app.delete("/path", handler);
app.patch("/path", handler);
```

### URL Parameters

```haxe
app.get("/user/:id", function(req, res) {
    var userId = req.getParam("id");
    res.json({ userId: userId });
});
```

### Query Parameters

```haxe
app.get("/search", function(req, res) {
    var query = req.getQuery("q");
    res.json({ query: query });
});
```

### Request Object

```haxe
req.method          // HTTP method
req.path            // Request path
req.body            // Request body
req.header(name)    // Get header
req.getParam(name)  // Get URL parameter
req.getQuery(name)  // Get query parameter
```

### Response Object

```haxe
res.status(code)              // Set status code
res.setHeader(name, value)    // Set header
res.json(data)                // Send JSON response
res.html(content)             // Send HTML response
res.text(content)             // Send text response
res.send(content)             // Send raw content
res.redirect(url, code)       // Redirect
```

### Middleware

```haxe
app.use(MiddlewareHelper.logger());
app.use(MiddlewareHelper.cors("*"));
app.use(MiddlewareHelper.bodyParser());
app.use(MiddlewareHelper.staticFiles("./public"));

app.use(function(req, res, next) {
    trace("Custom middleware");
    next();
});
```

