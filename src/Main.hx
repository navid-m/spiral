import spiral.Spiral;
import spiral.Server;
import spiral.Request;
import spiral.Response;
import spiral.Router;
import spiral.Middleware.MiddlewareHelper;

class Main {
	static function main() {
		var app = Spiral.createServer("127.0.0.1", 8080);
		
		app.use(MiddlewareHelper.logger());
		app.use(MiddlewareHelper.cors());
		app.use(MiddlewareHelper.bodyParser());
		
		app.get("/", function(req:Request, res:Response) {
			res.html('
<!DOCTYPE html>
<html>
<head>
	<title>Spiral Framework</title>
	<style>
		body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
		h1 { color: #333; }
		.code { background: #f4f4f4; padding: 10px; border-radius: 5px; margin: 10px 0; }
	</style>
</head>
<body>
	<h1>Welcome to Spiral Framework!</h1>
	<p>A modern web framework for Haxe targeting C++</p>
	<h2>Example Routes:</h2>
	<ul>
		<li><a href="/api/hello">GET /api/hello</a></li>
		<li><a href="/api/user/123">GET /api/user/:id</a></li>
		<li>POST /api/data (with JSON body)</li>
	</ul>
</body>
</html>
			');
		});
		
		app.get("/api/hello", function(req:Request, res:Response) {
			res.json({
				message: "Hello from Spiral!",
				version: Spiral.VERSION,
				timestamp: Date.now().getTime()
			});
		});
		
		app.get("/api/user/:id", function(req:Request, res:Response) {
			var userId = req.getParam("id");
			res.json({
				userId: userId,
				name: 'User $userId',
				email: 'user${userId}@example.com'
			});
		});
		
		app.post("/api/data", function(req:Request, res:Response) {
			var jsonData = Reflect.field(req, "json");
			if (jsonData != null) {
				res.status(201).json({
					success: true,
					received: jsonData,
					timestamp: Date.now().getTime()
				});
			} else {
				res.status(400).json({
					success: false,
					error: "Invalid JSON data"
				});
			}
		});
		
		app.get("/api/query", function(req:Request, res:Response) {
			var name = req.getQuery("name");
			var age = req.getQuery("age");
			res.json({
				name: name != null ? name : "Anonymous",
				age: age != null ? age : "Unknown"
			});
		});
		
		trace('Starting Spiral Framework v${Spiral.VERSION}');
		app.listen(function() {
			trace('Ready to accept connections!');
		});
	}
}

