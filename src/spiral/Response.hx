package spiral;

import sys.net.Socket;
import haxe.io.Bytes;

class Response {
	var socket:Socket;
	var statusCode:Int;
	var statusMessage:String;
	var headers:Map<String, String>;

	public var sent:Bool;

	public function new(socket:Socket) {
		this.socket = socket;
		this.statusCode = 200;
		this.statusMessage = "OK";
		this.headers = new Map();
		this.sent = false;

		setHeader("Server", "Spiral/1.0");
		setHeader("Connection", "close");
	}

	public function status(code:Int):Response {
		statusCode = code;
		statusMessage = getStatusMessage(code);
		return this;
	}

	public function setHeader(name:String, value:String):Response {
		headers.set(name, value);
		return this;
	}

	public function json(data:Dynamic):Void {
		setHeader("Content-Type", "application/json");
		send(haxe.Json.stringify(data));
	}

	public function html(content:String):Void {
		setHeader("Content-Type", "text/html; charset=utf-8");
		send(content);
	}

	public function text(content:String):Void {
		setHeader("Content-Type", "text/plain; charset=utf-8");
		send(content);
	}

	public function send(content:String):Void {
		if (sent)
			return;

		var body = Bytes.ofString(content);
		setHeader("Content-Length", Std.string(body.length));

		var response = 'HTTP/1.1 ${statusCode} ${statusMessage}\r\n';
		for (key in headers.keys()) {
			response += '${key}: ${headers.get(key)}\r\n';
		}
		response += '\r\n';
		response += content;

		try {
			socket.output.writeString(response);
			socket.output.flush();
			sent = true;
		} catch (e:Dynamic) {
			trace('Error sending response: $e');
		}
	}

	public function redirect(url:String, code:Int = 302):Void {
		status(code);
		setHeader("Location", url);
		send("");
	}

	function getStatusMessage(code:Int):String {
		return switch (code) {
			case 200: "OK";
			case 201: "Created";
			case 204: "No Content";
			case 301: "Moved Permanently";
			case 302: "Found";
			case 304: "Not Modified";
			case 400: "Bad Request";
			case 401: "Unauthorized";
			case 403: "Forbidden";
			case 404: "Not Found";
			case 405: "Method Not Allowed";
			case 500: "Internal Server Error";
			case 502: "Bad Gateway";
			case 503: "Service Unavailable";
			default: "Unknown";
		}
	}
}

