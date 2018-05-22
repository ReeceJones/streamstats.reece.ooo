import std.stdio;
import vibe.d;
import std.array: split;
import std.string: strip;
import std.conv: text;
import service.db;

void handleRetard(HTTPServerRequest req, HTTPServerResponse res)
{
    auto uri = req.requestURI; 
	//remove the blank
    string[] s = uri.split("/")[1..$];
    string requestedUser = s[0];
    string requestedStat = s[1];
	writeln("user: ", requestedUser);
	writeln("statistic: ", requestedStat);
    res.render!("index.dt", requestedStat, requestedUser);
}


void handleWebSocketConnection(scope WebSocket socket)
{
	logInfo("Got new web socket connection.");
	auto user = socket.receiveText().strip;
	auto stat = socket.receiveText().strip;
	while (true)
	{
		auto stats = getFullStats("pc-na", user, false);
		if (!socket.connected) break;
		string response = "";
		if (stat == "kills" || stat == "all")
			response ~= "Kills: " ~ text!int(stats.kills) ~ "<br>";
		if (stat == "headshots" || stat == "all")
			response ~= "Headshots: " ~ text!int(stats.headshots) ~ "<br>";
		if (stat == "wins" || stat == "all")
			response ~= "Wins: " ~ text!int(stats.wins) ~ "<br>";
		if (stat == "losses" || stat == "all")
			response ~= "Losses: " ~ text!int(stats.losses) ~ "<br>";
		response ~= stats.status ~ "<br>";
		socket.send(response);
		//we can wait a while
		sleep(10.seconds);
	}
	logInfo("Client disconnected.");
}

void handleNewTracker(HTTPServerRequest req, HTTPServerResponse res)
{
	//make sure they did something
    enforceHTTP("username" in req.form && "stat" in req.form,
		HTTPStatus.badRequest, "Missing username field.");
	string username = cast(string)req.form["username"];
	//now add them to the queue
	queueInsert(username);
	string responseURL = "localhost:8080/" ~ username ~ "/";
	switch (req.form["stat"])
	{
		default:
			responseURL ~= "all";
		break;
		case "kills":
			responseURL ~= "kills";
		break;
		case "headshots":
			responseURL ~= "headshots";
		break;
		case "losses":
			responseURL ~= "losses";
		break;
		case "wins":
			responseURL ~= "wins";
		break;
	}
	res.render!("res.dt", responseURL);
}

shared static this()
{
	auto router = new URLRouter;

	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("/new", staticTemplate!("new.dt"));
	router.get("/*", &handleRetard);
	//router.get("*", serveStaticFiles("public/"));

	router.post("/new_tracker", &handleNewTracker);

	auto settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	ensureValid();
	listenHTTP(settings, router);
}
