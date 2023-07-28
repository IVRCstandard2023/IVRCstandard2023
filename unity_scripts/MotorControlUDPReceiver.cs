using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;
using Uduino;

public class MotorControlUDPReceiver : MonoBehaviour
{
    UdpClient udp;

    private const int pwmPin = 3;
    private const int enablePin = 2;

    void Start()
    {
        udp = new UdpClient(55555);
        
        UduinoManager.Instance.pinMode(pwmPin, PinMode.Output);
        UduinoManager.Instance.pinMode(enablePin, PinMode.Output);
        UduinoManager.Instance.digitalWrite(enablePin, State.HIGH); // Enable ESCON
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

            int intensity = (int)data[0];

            // Clip intensity to 500
            intensity = Mathf.Min(intensity, 500);

            // Map intensity from [0, 1000] to [20, 40]
            intensity = (int)Mathf.Lerp(20, 40, intensity / 500f);

            // Write the PWM value
            UduinoManager.Instance.analogWrite(pwmPin, intensity);
        }
    }

    void OnApplicationQuit()
    {
        udp.Close();
    }
}
