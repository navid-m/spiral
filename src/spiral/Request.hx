package spiral;

import sys.net.Socket;
import haxe.io.Bytes;

class Request {
	public var method:String;
	public var path:String;
	public var query:Map<String, String>;
	public var headers:Map<String, String>;
	public var body:String;
	public var params:Map<String, String>;
	public var httpVersion:String;

	var socket:Socket;

	public function new() {
		query = new Map();
		headers = new Map();
		params = new Map();
		body = "";
	}

	public static function parse(data:String, socket:Socket):Request {
		var request = new Request();
		request.socket = socket;

		var lines = data.split("\r\n");
		if (lines.length == 0) {
			request.method = "GET";
			request.path = "/";
			request.httpVersion = "HTTP/1.1";
			return request;
		}

		var requestLine = lines[0].split(" ");
		if (requestLine.length >= 3) {
			request.method = requestLine[0];
			request.httpVersion = requestLine[2];

			var urlParts = requestLine[1].split("?");
			request.path = urlParts[0];

			if (urlParts.length > 1) {
				var queryString = urlParts[1];
				var queryPairs = queryString.split("&");
				for (pair in queryPairs) {
					var kv = pair.split("=");
					if (kv.length == 2) {
						request.query.set(kv[0], StringTools.urlDecode(kv[1]));
					}
				}
			}
		} else {
			request.method = "GET";
			request.path = "/";
			request.httpVersion = "HTTP/1.1";
		}

		var i = 1;
		while (i < lines.length && lines[i] != "") {
			var headerLine = lines[i];
			var colonIndex = headerLine.indexOf(":");
			if (colonIndex > 0) {
				var key = headerLine.substring(0, colonIndex).toLowerCase();
				var value = StringTools.trim(headerLine.substring(colonIndex + 1));
				request.headers.set(key, value);
			}
			i++;
		}

		i++;
		if (i < lines.length) {
			request.body = lines.slice(i).join("\r\n");
		}

		return request;
	}

	public function header(name:String):Null<String> {
		return headers.get(name.toLowerCase());
	}

	public function getQuery(name:String):Null<String> {
		return query.get(name);
	}

	public function getParam(name:String):Null<String> {
		return params.get(name);
	}
}

