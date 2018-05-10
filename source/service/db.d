module service.db;

import vibe.db.mongo.mongo;

void start()
{
    conn = connectMongoDB("localhost");
    cachePUBG = conn.getCollection("cache.pubg");
    statsPUBG = conn.getCollection("stats.pubg");
}

void cacheStore(string playerName, string playerId)
{
    cachePUBG.insert(Bson([
        "playerName" : Bson(playerName),
        "playerId" : Bson(playerId)
    ]));
}

string cacheRetrieve(string playerName)
{
    return cast(string)cachePUBG.find(Bson(["playerName" : Bson(playerName)])).front["playerId"];
}

bool checkPresent(string playerName)
{
    return !cachePUBG.find(Bson(["playerName" : Bson(playerName)])).empty;
}

struct Stats
{
    int kills;
    int headshots;
    int distance;
    int wins;
    int losses;
}


void statsStore(string playerId, Stats stats)
{
    statsPUBG.insert(Bson([
        "playerId" : cast(string)playerId,
        "kills" : cast(int)stats.kills,
        "headshots" : cast(int)stats.headshots,
        "distance" : cast(int)stats.distance,
        "wins" : cast(int)stats.wins,
        "losses" : cast(int)stats.losses
    ]));
}

void statsUpdate(string playerId, Stats stats)
{
    statsPUBG.update(Bson([
        "playerId" : Bson(cast(string)playerId)
    ]),
    Bson([
        "playerId" : Bson(cast(string)playerId),
        "kills" : Bson(cast(int)stats.kills),
        "headshots" : Bson(cast(int)stats.headshots),
        "distance" : Bson(cast(int)stats.distance),
        "wins" : Bson(cast(int)stats.wins),
        "losses" : Bson(cast(int)stats.losses)
    ]));
}

Stats statsRetrieve(string playerId)
{
    auto q = cachePUBG.find(Bson(["playerName" : Bson(playerName)])).front;
    Stats stats = {
        cast(int)q["kills"],
        cast(int)q["headshots"],
        cast(int)q["distance"],
        cast(int)q["wins"],
        cast(int)q["losses"]
    };
    return stats;
}

Stats statsDelta(Stats s0, Stats s1)
{
    Stats delta = {
        s0.kills - s1.kills,
        s0.headshots - s1.kills,
        s0.distance - s1.distance,
        s0.wins - s1.wins,
        s0.losses - s1.losses
    };
    return delta;
}

bool statsExists(string id)
{
    return !cachePUBG.find(Bson(["playerId" : Bson(playerId)])).empty;
}

Stats updatePlayerInfo(string playerName, out string playerId, out bool expired)
{
    PlayerRequest playerRequest = new PlayerRequest("pc-na");
    //user is not cached
    if (checkPresent(playerName))
    {
        //translate from name to account id
        Player player = playerRequest.getPlayerFromName(playerName);
        //store them in the cache
        cacheStore(playerName, player.getId());
        expired = false;
        //just need some place holder
        id = "waiting...";
    }
    else //because resources are limited and, we don't want to waste requests we ignore them after caching (they will eventually have their stats updated)
    {
        immutable string seasons[] = {
            "division.bro.official.2017-beta",
            "division.bro.official.2017-pre1",
            "division.bro.official.2017-pre2",
            "division.bro.official.2017-pre3",
            "division.bro.official.2017-pre4",
            "division.bro.official.2017-pre5",
            "division.bro.official.2017-pre6",
            "division.bro.official.2017-pre7",
            "division.bro.official.2017-pre8",
            "division.bro.official.2017-pre9",
            "division.bro.official.2018-01",
            "division.bro.official.2018-02",
            "division.bro.official.2018-03",
            "division.bro.official.2018-04",
            "division.bro.official.2018-05"
        };
        immutable string gameModes[] = {
            "duo",
            "duo-fpp",
            "solo",
            "solo-fpp",
            "squad",
            "squad-fpp"
        };
        //get their id from the cache
        string id = cacheRetrieve(playerName);
        //get stats for the latest season
        Player player = playerRequest.getExtendedPlayer(id, seasons[$]);
        Stats aggregatedStats;
        foreach (gm; gameModes)
        {
            auto gms = player.getGameModeStats(gm);
            aggregatedStats.kills += gms.getKills();
            aggregatedStats.headshots += gms.getHeadshotKills();
            aggregatedStats.distance += gms.getRideDistance();
            aggregatedStats.wins += gms.getWins();
            aggregatedStats.losses += gms.getLosses();
        }

        //now that we have the aggregated stats we need to store/update them
        if (statsExists)
            statsUpdate(id, aggregatedStats);
        else
            statsStore(id, aggregatedStats);
        expired = false;
        playerId = id;
        return aggregatedStats;
    }
}

private
{
    MongoClient conn;
    MongoCollection cachePUBG;
    MongoCollection statsPUBG;
}