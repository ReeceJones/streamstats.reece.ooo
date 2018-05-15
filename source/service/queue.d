module service.queue;
import service.db;

string pop()
{
    string t = usernames[0];
    usernames = usernames[1..$];
    return t;
}

private
{
    string[] usernames;
}