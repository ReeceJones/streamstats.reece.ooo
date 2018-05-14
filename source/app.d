import std.stdio;
import vibe.d;
import pubg.request;
import service.query;
import std.array: split;

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
	auto stats = getFullStats("pc-na", requestedUser);
    res.render!("index.dt", stats, requestedStat);
}

shared static this()
{
	auto router = new URLRouter;

	router.get("*", &handleRetard);

	auto settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];

	setAPIKey("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJkZDUzNTMzMC0zMmYxLTAxMzYtODI3Ny0wOWZlNWVjZTk5YjYiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTI1NTY2MzEyLCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6ImFtb3VudC1vZi1raWxscy1pbi10aW1lLXBlcmlvZCIsInNjb3BlIjoiY29tbXVuaXR5IiwibGltaXQiOjEwfQ.OZCRQlb2Ah2ZkQoo1ImkBNHy0xytQgBgttp_nXZLZqk");
	listenHTTP(settings, router);
}
