module service.queue;
import service.db;
import core.thread: Thread;
import pubg.player;
import std.datetime;
import std.stdio;
import service.query;

void startQueue()
{
    auto playerRequest = new PlayerRequest("pc-na");
    while (true)
    {
        Thread.sleep(6.seconds);
        writeln("updating...");
        if (usernames.length <= 0)
        {
            // Thread.sleep(6.seconds);
            continue;
        }
        string user = pop();
        DBStatStore lookup = lookupByName(user);
        //user is not in the database, have to add them
        if (lookup == cast(DBStatStore)0)
        {
            writeln("user " ~ user ~ " not present");
            auto player = playerRequest.getPlayerFromName(user);
            DBStatStore store;
            store.username = user;
            store.accountId = player.getId();
            writeln(store.accountId);
            //store.creationDate = PosixTimeZone.getTimeZone("America/Los_Angeles").toISOExtString();
            auto currentTime = Clock.currTime();
            auto timeString = currentTime.toISOExtString();
            store.creationDate = timeString;
            store.status = "loading...";
            //store the user in the database
            statsStore(store);
            push(user);
        }
        else
        {
            writeln(user ~ " exists");
            //get updated information
            auto newStats = getFullStats("pc-na", lookup.accountId);
            DBStatStore store;
            store.username = user;
            store.accountId = lookup.accountId;
            store.status = "";
            store.creationDate = lookup.creationDate;
            store.kills = newStats.kills;
            store.headshots = newStats.headshots;
            store.wins = newStats.wins;
            store.losses = newStats.losses;
            writeln(store.wins);
            //check if the user is valid before readding them to the stack
            auto currentTime = Clock.currTime();
            if (SysTime.fromISOExtString(lookup.creationDate).day + 2 > currentTime.day)
            {
                push(user);
            }
            else
                store.status = "STATISTIC TRACKER EXPIRED";
            //then store the new information
            statsStore(store);
        }
    }
}

void push(string username)
{
    usernames ~= username;
}

private
{
    string[] usernames;

    string pop()
    {
        string t = usernames[0];
        usernames = usernames[1..$];
        return t;
    }
}