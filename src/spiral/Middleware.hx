package spiral;

typedef Middleware = Request->Response->(Void->Void)->Void;

class MiddlewareHelper {
	public static function logger():Middleware {
		return function(req:Request, res:Response, next:Void->Void) {
			var timestamp = Date.now().toString();
			trace('[$timestamp] ${req.method} ${req.path}');
			next();
		};
	}

	public static function cors(origin:String = "*"):Middleware {
		return function(req:Request, res:Response, next:Void->Void) {
			res.setHeader("Access-Control-Allow-Origin", origin);
			res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS");
			res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

			if (req.method == "OPTIONS") {
				res.status(204).send("");
			} else {
				next();
			}
		};
	}

	public static function bodyParser():Middleware {
		return function(req:Request, res:Response, next:Void->Void) {
			var contentType = req.header("content-type");
			if (contentType != null && contentType.indexOf("application/json") >= 0) {
				try {
					var parsed = haxe.Json.parse(req.body);
					Reflect.setField(req, "json", parsed);
				} catch (e:Dynamic) {
					trace('Error parsing JSON body: $e');
				}
			}
			next();
		};
	}

	public static function staticFiles(directory:String):Middleware {
		return function(req:Request, res:Response, next:Void->Void) {
			if (req.method != "GET") {
				next();
				return;
			}

			var filePath = directory + req.path;
			if (sys.FileSystem.exists(filePath) && !sys.FileSystem.isDirectory(filePath)) {
				try {
					var content = sys.io.File.getContent(filePath);
					var ext = haxe.io.Path.extension(filePath).toLowerCase();
					var contentType = getContentType(ext);
					res.setHeader("Content-Type", contentType);
					res.send(content);
				} catch (e:Dynamic) {
					trace('Error reading file: $e');
					next();
				}
			} else {
				next();
			}
		};
	}

	static function getContentType(ext:String):String {
		return switch (ext) {
			case "html": "text/html";
			case "css": "text/css";
			case "js": "application/javascript";
			case "json": "application/json";
			case "png": "image/png";
			case "jpg", "jpeg": "image/jpeg";
			case "gif": "image/gif";
			case "svg": "image/svg+xml";
			case "txt": "text/plain";
			default: "application/octet-stream";
		}
	}
}

