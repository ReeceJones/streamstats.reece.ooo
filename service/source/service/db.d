module service.db;
import vibe.db.mongo.mongo;

struct DBStatStore
{
    int originalKills;
    int originalHeadshots;
    int originalWins;
    int originalLosses;    
    int postKills;
    int postHeadshots;
    int postWins;
    int postLosses;
    string username;
    string accountId;
    string creationDate;
    string status;
}

void ensureValid()
{
    conn = connectMongoDB("mongodb://127.0.0.1");
    store = conn.getCollection("stats.pubg");
    queue = conn.getCollection("queue.pubg");
}

int getEntries()
{
    return cast(int)store.count("{}");
}

DBStatStore lookupByName(string username)
{
    auto q = store.find(Bson(["username" : Bson(username)]));
    if (q.empty)
        return cast(DBStatStore)0;
    DBStatStore stats;
    stats.username = username;
    stats.accountId = cast(string)q.front["id"];
    stats.originalKills = cast(int)q.front["original"]["kills"];
    stats.originalHeadshots = cast(int)q.front["original"]["headshots"];
    stats.originalWins = cast(int)q.front["original"]["wins"];
    stats.originalLosses = cast(int)q.front["original"]["losses"];

    stats.postKills = cast(int)q.front["post"]["kills"];
    stats.postHeadshots = cast(int)q.front["post"]["headshots"];
    stats.postWins = cast(int)q.front["post"]["wins"];
    stats.postLosses = cast(int)q.front["post"]["losses"];
    
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
            "original"  : Bson([
                "kills"     : Bson(stats.originalKills),
                "headshots" : Bson(stats.originalHeadshots),
                "wins"      : Bson(stats.originalWins),
                "losses"    : Bson(stats.originalLosses)
            ]),
            "post"  : Bson([
                "kills"     : Bson(stats.postKills),
                "headshots" : Bson(stats.postHeadshots),
                "wins"      : Bson(stats.postWins),
                "losses"    : Bson(stats.postLosses)
            ]),
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
            "original"  : Bson([
                "kills"     : Bson(stats.originalKills),
                "headshots" : Bson(stats.originalHeadshots),
                "wins"      : Bson(stats.originalWins),
                "losses"    : Bson(stats.originalLosses)
            ]),
            "post"  : Bson([
                "kills"     : Bson(stats.postKills),
                "headshots" : Bson(stats.postHeadshots),
                "wins"      : Bson(stats.postWins),
                "losses"    : Bson(stats.postLosses)
            ]),
            "creationDate" : Bson(stats.creationDate),
            "status"    : Bson(stats.status)
        ]));
    }
}

string[] getQueued()
{
    //find everyone in the queue
    auto q = queue.find();
    string[] queued;
    foreach (i, doc; q.byPair)
    {
        queued ~= cast(string)doc["username"];
    }
    // //clear queue
    // queue.remove(Bson(""));
    return queued;
}

void removeFromQueue(string username)
{
    queue.remove(Bson([
        "username" : Bson(username)
    ]));
}

private
{
    MongoClient conn;
    MongoCollection store;
    MongoCollection queue;
}