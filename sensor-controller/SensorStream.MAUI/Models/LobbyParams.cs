namespace SensorStream.MAUI.Models;

public class LobbyParams
{
    public LobbyParams(BroadcastMessageModel server, string username)
    {
        Server = server;
        Username = username;
    }
    
    public BroadcastMessageModel Server { get; set; }
    public string Username { get; set; }
    
}