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

PlayerStats getFullStats(string region, string accountId)
{
    PlayerStats playerStats = cast(PlayerStats)0;
    PlayerRequest playerRequest = new PlayerRequest(region);
    Player player = playerRequest.getExtendedPlayer(accountId, getLatestSeason());
    foreach (mode; getGameModes())
    {
        auto gmStats = player.getGameModeStats(mode);
        playerStats.kills += gmStats.getKills();
        playerStats.headshots += gmStats.getHeadshotKills();
        playerStats.wins += gmStats.getWins();
        playerStats.losses += gmStats.getLosses();
    }
    return playerStats;
}
