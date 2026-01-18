package spiral;

class Spiral {
	public static inline var VERSION:String = "1.0.0";

	public static function createServer(?host:String, ?port:Int):Server {
		return new Server(host != null ? host : "127.0.0.1", port != null ? port : 8080);
	}
}

