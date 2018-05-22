import std.stdio;
import vibe.d;
import service.db;
import handling.tracker;
import handling.socket;

shared static this()
{
	auto router = new URLRouter;

	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("/new", staticTemplate!("new.dt"));
	router.get("/*", &handleTracker);
	//router.get("*", serveStaticFiles("public/"));

	router.post("/new_tracker", &handleNewTracker);

	auto settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	ensureValid();
	listenHTTP(settings, router);
}
