import std.stdio;
import service.db;
import service.queue;
import pubg.request;

void main()
{
	writeln("starting streamstats service...");
	setAPIKey("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJkZDUzNTMzMC0zMmYxLTAxMzYtODI3Ny0wOWZlNWVjZTk5YjYiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNTI1NTY2MzEyLCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6ImFtb3VudC1vZi1raWxscy1pbi10aW1lLXBlcmlvZCIsInNjb3BlIjoiY29tbXVuaXR5IiwibGltaXQiOjEwfQ.OZCRQlb2Ah2ZkQoo1ImkBNHy0xytQgBgttp_nXZLZqk");
	ensureValid();
	startQueue();
}
