module handling.socket;
import vibe.d;
import service.db;
import std.conv: parse, text;
import std.string: strip;

void handleWebSocketConnection(scope WebSocket socket)
{
	logInfo("Got new web socket connection.");
	auto user = socket.receiveText().strip;
	auto stat = socket.receiveText().strip;
	string sDelta = socket.receiveText().strip;
	bool delta = parse!bool(sDelta);
	while (true)
	{
		auto stats = getFullStats("pc-na", user, delta);
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
