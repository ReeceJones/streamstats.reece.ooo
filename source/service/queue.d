module service.queue;
import pubg.player;
import core.thread, core.time;
import service.db, service.socket;

private:
import std.container.array;
class RequestQueue : Thread
{
public:
    this(uint msRefresh)
    {
        super(&fn);
        this.arr = [];
        this.msRefresh = msRefresh;
    }
    string pop()
    {
        auto n = this.arr[0];
        this.arr = this.arr[1..$];
        return n;
    }
    void push(string pr)
    {
        this.arr ~= pr;
    }
    //make sure you call join after this call
    void stop()
    {
        this.stopRequest = true;
    }
private:
    // refresh function
    void fn()
    {
        while (stopRequest == false)
        {
            this.sleep(this.msRefresh.milliseconds);
            //update the player info
            auto name = this.pop();
            string id;
            bool expired = false;
            //first update the database, and get the Stats
            auto p = updatePlayerInfo(name, id, expired);
            //second dispatch a request to the websockets
            //dispatchWebSocketInfo(p, id, expired);
            //add the request back to the queue if it is still valid
            if (expired == false)
                this.push(p);
        }
    }
    string arr;
    uint msRefresh;
    bool stopRequest = false;
}