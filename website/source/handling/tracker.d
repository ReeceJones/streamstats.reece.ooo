module handling.tracker;
import vibe.d;
import service.db;
import std.conv: text;
import std.array: split;

void handleTracker(HTTPServerRequest req, HTTPServerResponse res)
{
    auto uri = req.requestURI; 
	//remove the blank and stats
    string[] s = uri.split("/")[2..$];
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

	if (!req.session)
	{
		res.redirect("/login");
		return;
	}

	string username = cast(string)req.form["username"];
	//now add them to the queue
	queueInsert(username);
	string responseURL = "http://localhost:8080/stats/" ~ username ~ "/";
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