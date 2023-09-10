using System;
using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System.Text;

public class ESP32Control : MonoBehaviour
{
    private string ESP32_IP = "192.168.30.3";  // ESP32のIPアドレス
    private const int SEND_PORT = 10000;  // ESP32の受信ポート
    private const int RECEIVE_PORT = 65000;  // Unityの送信ポート

    static UdpClient udp_receive;//UDP受信を使う準備
    static UdpClient udp_send;//UDP送信を使う準備

    // モーターパワーを設定するための変数
    // [Range]属性を使ってmotorPower変数に範囲を指定
    [Range(0, 255)]
    public byte motorPower = 128;
    // ファンを制御するための変数
    public bool fanSwitch = false;

    public string receivedMessage = "";

    void Start()
    {
        try
        {
            udp_receive = new UdpClient(RECEIVE_PORT);
            udp_receive.Client.ReceiveTimeout = 1000; // UDP通信のタイムアウト設定
            udp_receive.BeginReceive(ReceiveCallback, null);

            udp_send = new UdpClient();
            udp_send.Connect(ESP32_IP, SEND_PORT);
        }
        catch (Exception e)
        {
            Debug.LogError("Error initializing UDP: " + e.Message);
        }
    }

    void Update()
    {
        // インスペクターから設定された値を使用してデータを送信
        SendData(motorPower, fanSwitch);
    }

    // モーターパワー、方向、ファンの状態をESP32に送信する関数
    void SendData(byte motorPower, bool fanSwitch)
    {
        byte[] data = new byte[2];
        data[0] = motorPower;
        data[1] = (byte)(fanSwitch ? 1 : 0);  // ファンスイッチがONなら1、OFFなら0

        udp_send.Send(data, data.Length);
    }

    private void ReceiveCallback(IAsyncResult ar)
    {
        try
        {
            IPEndPoint remoteEndPoint = new IPEndPoint(IPAddress.Any, RECEIVE_PORT);
            byte[] receivedData = udp_receive.EndReceive(ar, ref remoteEndPoint);
            receivedMessage = Encoding.ASCII.GetString(receivedData); // 受信したメッセージを保存

            Debug.Log("Received message from ESP32: " + receivedMessage);

            // ここで受信したメッセージを解析して必要な処理を行う
            // 例: 受信したメッセージに応じて何か処理を実行する
            if (receivedMessage == "Received UDP")
            {
                // 受信確認メッセージが正常に受信された場合の処理
            }

            // 再度受信を待機
            udp_receive.BeginReceive(ReceiveCallback, null);
        }
        catch (Exception e)
        {
            Debug.LogError("Error receiving UDP data: " + e.Message);
        }
    }

    void OnDestroy()
    {
        udp_receive.Close();
        udp_send.Close();
    }
}
