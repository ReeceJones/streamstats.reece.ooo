import std.stdio;
import vibe.d;
import service.db;
import handling.tracker;
import handling.socket;
import auth.login;

shared static this()
{
	auto router = new URLRouter;

	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("/", staticTemplate!("index.dt"));
	router.get("/new", staticTemplate!("new.dt"));
	router.get("/login", staticTemplate!("login.dt"));
	router.get("/login/", staticTemplate!("login.dt"));
	router.get("/create", staticTemplate!("create.dt"));
	router.get("/create/", staticTemplate!("create.dt"));
	router.get("/stats/*", &handleTracker);
	router.get("*", serveStaticFiles("public/"));

	router.post("/new", &handleNewTracker);
	router.post("/login", &login);
	router.post("/create", &create);

	auto settings = new HTTPServerSettings;

	settings.port = 9002;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	settings.sessionStore = new MemorySessionStore;
	ensureValid();
	listenHTTP(settings, router);
}
