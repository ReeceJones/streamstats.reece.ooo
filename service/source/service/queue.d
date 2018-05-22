module service.queue;
import service.db;
import core.thread: Thread;
import pubg.player;
import std.datetime;
import std.stdio;
import service.query;
import std.string: strip;
import std.conv: text;

void startQueue()
{
    auto playerRequest = new PlayerRequest("pc-na");
    while (true)
    {
        Thread.sleep(6.seconds);
        writeln("updating...");
        iterateDBQueue();
        writeln(usernames);
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
            auto player = playerRequest.getPlayerFromName(user);
            DBStatStore store;
            store.username = user;
            store.accountId = player.getId();
            writeln(user ~ ":");
            writeln("\t" ~ store.accountId);
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
            //get updated information
            auto newStats = getFullStats("pc-na", lookup.accountId);
            DBStatStore store;
            store.username = user;
            store.accountId = lookup.accountId;
            store.creationDate = lookup.creationDate;

            if (lookup.status == "loading...")
            {
                store.originalKills = newStats.kills;
                store.originalHeadshots = newStats.headshots;
                store.originalWins = newStats.wins;
                store.originalLosses = newStats.losses;
            }
            else
            {
                store.originalKills = lookup.originalKills;
                store.originalHeadshots = lookup.originalHeadshots;
                store.originalLosses = lookup.originalLosses;
                store.originalWins = lookup.originalWins;

                store.postKills = newStats.kills;
                store.postHeadshots = newStats.headshots;
                store.postWins = newStats.wins;
                store.postLosses = newStats.losses;
            }
 
            store.status = "";

            writeln(user ~ ":");
            writeln("\tkills: " ~ text!int(store.originalKills));
            writeln("\theadshots: " ~ text!int(store.originalHeadshots));
            writeln("\tlosses: " ~ text!int(store.originalLosses));
            writeln("\twins: " ~ text!int(store.originalWins));
            //check if the user is valid before readding them to the stack
            auto currentTime = Clock.currTime();
            if (SysTime.fromISOExtString(lookup.creationDate).day + 2 > currentTime.day)
            {
                //only if they are still valid do they get pushed back into the queue
                push(user);
            }
            else
            {
                store.status = "STATISTIC TRACKER EXPIRED";
                //they won't be added back into the queue
                removeFromQueue(user);
            }
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
    int currentIndex;
    string pop()
    {
        string t = usernames[0];
        usernames = usernames[1..$];
        return t;
    }
    //push a user to the bottom of the stack so they will be the next one the be queried
    void quickPush(string username)
    {
        usernames = username ~ usernames;
    }
    void iterateDBQueue()
    {
        string[] newInserts = getQueued();
        foreach (ins; newInserts)
        {
            //check to make sure that the user doesn't already exist
            if (!usernames.exists(ins))
            {
                quickPush(ins.strip);
            }
        }
    }
    bool exists(string[] arr, string match)
    {
        foreach (s; arr)
        {
            if (s == match)
                return true;
        }
        return false;
    }
}