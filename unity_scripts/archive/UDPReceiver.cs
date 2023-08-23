using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;

public class UDPReceiver : MonoBehaviour
{
    UdpClient udp;

    void Start()
    {
        udp = new UdpClient(55555);
    }

    void Update()
    {
        while (udp.Available > 0)
        {
            IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);
            byte[] receiveBytes = udp.Receive(ref RemoteIpEndPoint);
            double[] data = new double[receiveBytes.Length / 8];
            for (int i = 0; i < data.Length; i++)
            {
                data[i] = System.BitConverter.ToDouble(receiveBytes, i * 8);
            }

            // Print the received data to the console.
            string dataStr = string.Join(", ", data);
            Debug.Log("Received data: " + dataStr);
        }
    }

    void OnApplicationQuit()
    {
        udp.Close();
    }
}
