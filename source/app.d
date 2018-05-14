import std.stdio;
import vibe.d;
import pubg.request;
import service.query;
import std.array: split;
import std.string: strip;
import std.conv: text;

void handleRetard(HTTPServerRequest req, HTTPServerResponse res)
{
    auto uri = req.requestURI; 
	//remove the blank
    string[] s = uri.split("/")[1..$];
    string requestedUser = s[0];
    string requestedStat = s[1];
	writeln("user: ", requestedUser);
	writeln("statistic: ", requestedStat);
	// auto stats = getFullStats("pc-na", "account.f80823e2cd624fe8a5a0aa1899ffcc41");
	// auto stats = getFullStats("pc-na", requestedUser);
    res.render!("index.dt", requestedStat, requestedUser);
}


void handleWebSocketConnection(scope WebSocket socket)
{
	logInfo("Got new web socket connection.");
	auto user = socket.receiveText().strip;
	auto stat = socket.receiveText().strip;
	while (true)
	{
		auto stats = getFullStats("pc-na", user);
		if (!socket.connected) break;
		string response = "";
		if (stat == "kills" || stat == "all")
			response ~= "Kills: " ~ text!int(stats.kills) ~ "<br>";
		if (stat == "wins" || stat == "all")
			response ~= "Wins: " ~ text!int(stats.wins) ~ "<br>";
		if (stat == "losses" || stat == "all")
			response ~= "Losses: " ~ text!int(stats.losses) ~ "<br>";
		socket.send(response);
		//we can wait a while
		sleep(5.seconds);
	}
	logInfo("Client disconnected.");
}

shared static this()
{
	auto router = new URLRouter;

	router.get("/account.*", &handleRetard);
	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("*", serveStaticFiles("public/"));

	auto settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];

	setAPIKey("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJkZDUzNTMzMC0zMmYxLTAxMzYtODI3Ny0wOWZlNWVjZTk5YjYiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTI1NTY2MzEyLCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6ImFtb3VudC1vZi1raWxscy1pbi10aW1lLXBlcmlvZCIsInNjb3BlIjoiY29tbXVuaXR5IiwibGltaXQiOjEwfQ.OZCRQlb2Ah2ZkQoo1ImkBNHy0xytQgBgttp_nXZLZqk");
	listenHTTP(settings, router);
}
