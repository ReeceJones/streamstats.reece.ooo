import std.stdio;
import vibe.d;

shared static this()
{
	auto router = new URLRouter;

	router.get("*", serveStaticFiles("public/"));

	auto settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	listenHTTP(settings, router);
}
