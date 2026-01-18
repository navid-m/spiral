package spiral;

typedef RouteHandler = Request->Response->Void;

typedef Route = {
	method:String,
	pattern:String,
	handler:RouteHandler,
	paramNames:Array<String>
}

class Router {
	var routes:Array<Route>;

	public function new() {
		routes = [];
	}

	public function addRoute(method:String, pattern:String, handler:RouteHandler):Void {
		var paramNames:Array<String> = [];
		var regexPattern = pattern;

		var paramRegex = ~/:([a-zA-Z_][a-zA-Z0-9_]*)/g;
		while (paramRegex.match(regexPattern)) {
			var paramName = paramRegex.matched(1);
			paramNames.push(paramName);
			regexPattern = paramRegex.matchedLeft() + "([^/]+)" + paramRegex.matchedRight();
		}

		routes.push({
			method: method,
			pattern: regexPattern,
			handler: handler,
			paramNames: paramNames
		});
	}

	public function handle(request:Request, response:Response):Void {
		for (route in routes) {
			if (route.method != request.method)
				continue;

			var regex = new EReg("^" + route.pattern + "$", "");
			if (regex.match(request.path)) {
				for (i in 0...route.paramNames.length) {
					var paramValue = regex.matched(i + 1);
					request.params.set(route.paramNames[i], paramValue);
				}

				route.handler(request, response);
				return;
			}
		}
	}
}

