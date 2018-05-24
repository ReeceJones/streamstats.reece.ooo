module service.db;
import vibe.db.mongo.mongo;
import dauth;
import std.conv: parse;

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
    users = conn.getCollection("auth.users");
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

struct PlayerStats
{
    int kills;
    int headshots;
    int wins;
    int losses;
    string status;
}

PlayerStats getFullStats(string region, string name, bool useDelta)
{
    PlayerStats playerStats = cast(PlayerStats)0;
    DBStatStore store = lookupByName(name);
    if (useDelta)
    {
        playerStats.kills = store.postKills - store.originalKills;
        playerStats.headshots = store.postHeadshots - store.originalHeadshots;
        playerStats.wins = store.postWins - store.originalWins;
        playerStats.losses = store.postLosses - store.originalLosses;
        playerStats.status = store.status;
    }
    else
    {
        playerStats.kills = store.originalKills;
        playerStats.headshots = store.originalHeadshots;
        playerStats.wins = store.originalWins;
        playerStats.losses = store.originalLosses;
        playerStats.status = store.status;
    }
    return playerStats;
}

void queueInsert(string username)
{
    if (queue.count(Bson(["username" : Bson(username)])) > 0)
        return;
    queue.insert(Bson([
        "username" : Bson(username)
    ]));
}

bool checkPassword(string usr, string pwdRaw, out bool admin)
{
    auto q = users.find(Bson(["username" : Bson(usr)]));
    foreach (i, doc; q.byPair)
    {
        if (isSameHash(toPassword(cast(char[])pwdRaw), parseHash(cast(string)doc["password"])))
        {
            auto isAdmin = cast(string)doc["admin"];
            admin = parse!bool(isAdmin);
            return true;
        }
    }
    return false;
}

bool createUser(string user, string rawPWD, string isAdmin)
{
    bool exists = !users.find(Bson(["username" : Bson(user)])).empty;
    //could not create user
    if (exists == true)
        return false;
    string hashString = makeHash(toPassword(cast(char[])rawPWD)).toString();
    //now just need to insert into mongo
    users.insert(Bson([
        "username"  : Bson(user),
        "password"  : Bson(hashString),
        "admin"     : Bson(isAdmin)
    ]));
    return true;
}

void updateUserPWD(string user, string newPWD)
{
    string hashString = makeHash(toPassword(cast(char[])newPWD)).toString();
    users.update(Bson(
        ["username"  : Bson(user)]
    ),
    Bson(
        ["password"  : Bson(hashString)]
    ));
}

private
{
    MongoClient conn;
    MongoCollection store;
    MongoCollection queue;
    MongoCollection users;
}