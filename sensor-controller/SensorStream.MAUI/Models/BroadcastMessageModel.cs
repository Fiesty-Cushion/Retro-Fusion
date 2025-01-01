namespace SensorStream.MAUI.Models;

public class BroadcastMessageModel
{
    public BroadcastMessageModel(string name, string iP, int ws_port)
    {
        Name = name;
        IP = iP;
        WS_Port = ws_port;
    }

    public string Name { get; set; }
    public string IP { get; set; }
    public int WS_Port { get; set; }

    public override bool Equals(object? obj)
    {
        return obj is BroadcastMessageModel other &&
               Name == other.Name &&
               IP == other.IP &&
               WS_Port == other.WS_Port;
    }

    public override int GetHashCode()
    {
        return HashCode.Combine(Name, IP, WS_Port);
    }

    public override string ToString()
    {
        return $"  Name: {Name}\n" +
               $"  IP: {IP}\n" +
               $"  WS_Port: {WS_Port}";
    }
}
