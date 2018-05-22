module handling.tracker;
import vibe.d;
import service.db;
import std.conv: text;
import std.array: split;

void handleTracker(HTTPServerRequest req, HTTPServerResponse res)
{
    auto uri = req.requestURI; 
	//remove the blank
    string[] s = uri.split("/")[1..$];
    string requestedUser = s[0];
    string requestedStat = s[1];
	string useDelta = text!bool(s.length > 2 && s[2] == "delta");
    res.render!("tracker.dt", requestedStat, requestedUser, useDelta);
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
	res.redirect("/new");
	res.render!("res.dt", responseURL);
}