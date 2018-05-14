module service.query;
import pubg.player;
import service.qdefs;
import std.stdio;

struct PlayerStats
{
    int kills;
    int headshots;
    int wins;
    int losses;
}

//TODO: make this just query database and move code from here to some other function
PlayerStats getFullStats(string region, string accountId)
{
    PlayerStats playerStats = cast(PlayerStats)0;
    PlayerRequest playerRequest = new PlayerRequest(region);
    Player player = playerRequest.getExtendedPlayer(accountId, getLatestSeason());
    foreach (mode; getGameModes())
    {
        auto gmStats = player.getGameModeStats(mode);
        playerStats.kills += gmStats.getKills();
        //doesn't work because of spelling error :/
        //playerStats.headshots += gmStats.getHeadshotKills();
        playerStats.wins += gmStats.getWins();
        playerStats.losses += gmStats.getLosses();
    }
    return playerStats;
}
