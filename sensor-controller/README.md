Client app for Retrofusion project

### What it does?

1. The app listens for UDP broadcast messages on the network. These broadcasts contain information about available servers.
2.	Upon receiving a UDP packet, the app parses the packet to extract host information, such as the server's IP address and WebSocket port.
3.	Using the extracted host information, the app establishes a connection to the server using the WebSocket protocol.
4.	Once connected, the app continuously streams the mobile phone's sensor data to the server over the WebSocket connection for gameplay control.