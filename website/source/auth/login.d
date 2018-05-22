module auth.login;
import std.stdio;
import vibe.d;
import service.db;

void login(HTTPServerRequest req, HTTPServerResponse res)
{
    //make sure to check that a username and a password were supplied
    enforceHTTP("username" in req.form && "password" in req.form,
	 	HTTPStatus.badRequest, "Missing username/password field.");
    //start a session
	string username = req.form["username"];
    string password = req.form["password"];
	res.terminateSession();
    auto session = res.startSession();
    bool userIsAdmin;
    if (checkPassword(username, password, userIsAdmin))
    {
        //have the username variable set in the session
        session.set("username", username);
        if (userIsAdmin)
            session.set("isAdmin", "true");
        else
            session.set("isAdmin", "false");
    }
    else
        res.terminateSession();
    res.redirect("/new");
}

void create(HTTPServerRequest req, HTTPServerResponse res)
{
    //make sure to check that a username and a password were supplied
    enforceHTTP("username" in req.form && "password" in req.form,
	 	HTTPStatus.badRequest, "Missing username/password field.");
    //start a session
	string username = req.form["username"];
    string password = req.form["password"];
    string isAdmin = username == "reece" ? "true" : "false";
    if (createUser(username, password, isAdmin) == false)
        res.redirect("/l");
    else
    {
        auto session = res.startSession();
        session.set("username", username);
        session.set("isAdmin", isAdmin);
        res.redirect("/cp");
    }
}

void logout(HTTPServerRequest req, HTTPServerResponse res)
{
	res.terminateSession();
    res.redirect("/");
}