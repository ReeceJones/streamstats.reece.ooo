module service.qdefs;

string[] getGameModes()
{
    return [
        "solo",
        "solo-fpp",
        "duo",
        "duo-fpp",
        "squad",
        "squad-fpp"
    ];
}

string getLatestSeason()
{
    return "division.bro.official.2018-05";
}
