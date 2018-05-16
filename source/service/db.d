module service.db;
import vibe.db.mongo.mongo;

struct DBStatStore
{
    int kills;
    int headshots;
    int wins;
    int losses;
    string username;
    string accountId;
    string creationDate;
    string status;
}

void ensureValid()
{
    conn = connectMongoDB("mongodb://127.0.0.1");
    store = conn.getCollection("stats.pubg");
}

DBStatStore lookupByName(string username)
{
    auto q = store.find(Bson(["username" : Bson(username)]));
    if (q.empty)
        return cast(DBStatStore)0;
    DBStatStore stats;
    stats.username = username;
    stats.accountId = cast(string)q.front["id"];
    stats.kills = cast(int)q.front["kills"];
    stats.headshots = cast(int)q.front["headshots"];
    stats.wins = cast(int)q.front["wins"];
    stats.losses = cast(int)q.front["losses"];
    stats.creationDate = cast(string)q.front["creationDate"];
    stats.status = cast(string)q.front["status"];
    return stats;
}

//inserts a new store into the db if it doesn't exist, and updates it if it does
void statsStore(DBStatStore stats)
{
    auto q = store.find(Bson(["id" : Bson(stats.accountId)]));
    if (q.empty)
    {
        store.insert(Bson([
            "username"  : Bson(stats.username),
            "id"        : Bson(stats.accountId),
            "kills"     : Bson(stats.kills),
            "headshots" : Bson(stats.headshots),
            "wins"      : Bson(stats.wins),
            "losses"    : Bson(stats.losses),
            "creationDate" : Bson(stats.creationDate),
            "status"    : Bson(stats.status)
        ]));
    }
    else
    {
        store.update(Bson(["id" : Bson(stats.accountId)]),
        Bson([
            "username"  : Bson(stats.username),
            "id"        : Bson(stats.accountId),
            "kills"     : Bson(stats.kills),
            "headshots" : Bson(stats.headshots),
            "wins"      : Bson(stats.wins),
            "losses"    : Bson(stats.losses),
            "creationDate" : Bson(stats.creationDate),
            "status"    : Bson(stats.status)
        ]));
    }
}

private
{
    MongoClient conn;
    MongoCollection store;
}