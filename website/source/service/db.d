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

struct PlayerStats
{
    int kills;
    int headshots;
    int wins;
    int losses;
    string status;
}

PlayerStats getFullStats(string region, string name)
{
    PlayerStats playerStats = cast(PlayerStats)0;
    DBStatStore store = lookupByName(name);
    playerStats.kills = store.kills;
    playerStats.headshots = store.headshots;
    playerStats.wins = store.wins;
    playerStats.losses = store.losses;
    playerStats.status = store.status;
    return playerStats;
}


private
{
    MongoClient conn;
    MongoCollection store;
}