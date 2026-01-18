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
			client.setTimeout(5);

			var lines:Array<String> = [];
			var input = client.input;

			while (true) {
				try {
					var line = input.readLine();
					lines.push(line);
					if (line == "")
						break;
				} catch (e:Dynamic) {
					break;
				}
			}

			var contentLength = 0;
			for (line in lines) {
				if (line.toLowerCase().indexOf("content-length:") == 0) {
					var parts = line.split(":");
					if (parts.length >= 2) {
						var parsed = Std.parseInt(StringTools.trim(parts[1]));
						contentLength = (parsed != null) ? parsed : 0;
					}
					break;
				}
			}

			var body = "";
			if (contentLength > 0) {
				try {
					var bodyBytes = haxe.io.Bytes.alloc(contentLength);
					input.readFullBytes(bodyBytes, 0, contentLength);
					body = bodyBytes.toString();
					lines.push("");
					lines.push(body);
				} catch (e:Dynamic) {
					trace('Error reading body: $e');
				}
			}

			var requestData = lines.join("\r\n");
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

