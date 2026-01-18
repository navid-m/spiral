package spiral;

import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;

class Server {
	var host:String;
	var port:Int;
	var router:Router;
	var middlewares:Array<Middleware>;

	public function new(host:String = "127.0.0.1", port:Int = 8080) {
		this.host = host;
		this.port = port;
		this.router = new Router();
		this.middlewares = [];
	}

	public function use(middleware:Middleware):Void {
		middlewares.push(middleware);
	}

	public function get(path:String, handler:Request->Response->Void):Void {
		router.addRoute("GET", path, handler);
	}

	public function post(path:String, handler:Request->Response->Void):Void {
		router.addRoute("POST", path, handler);
	}

	public function put(path:String, handler:Request->Response->Void):Void {
		router.addRoute("PUT", path, handler);
	}

	public function delete(path:String, handler:Request->Response->Void):Void {
		router.addRoute("DELETE", path, handler);
	}

	public function patch(path:String, handler:Request->Response->Void):Void {
		router.addRoute("PATCH", path, handler);
	}

	public function listen(?callback:Void->Void):Void {
		var socket = new Socket();
		socket.bind(new Host(host), port);
		socket.listen(100);

		trace('Server listening on http://${host}:${port}');
		if (callback != null)
			callback();

		while (true) {
			try {
				var client = socket.accept();
				handleClient(client);
			} catch (e:Dynamic) {
				trace('Error accepting client: $e');
			}
		}
	}

	function handleClient(client:Socket):Void {
		try {
			var requestData = client.input.readAll().toString();
			var request = Request.parse(requestData, client);
			var response = new Response(client);

			var index = 0;
			function next():Void {
				if (index < middlewares.length) {
					var middleware = middlewares[index++];
					middleware(request, response, next);
				} else {
					router.handle(request, response);
				}
			}

			next();

			if (!response.sent) {
				response.status(404).send("Not Found");
			}

			client.close();
		} catch (e:Dynamic) {
			trace('Error handling client: $e');
			try {
				client.close();
			} catch (_:Dynamic) {}
		}
	}
}

