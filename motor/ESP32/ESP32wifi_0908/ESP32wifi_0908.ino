// 必要なライブラリをインクルード
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>

// モーターのPWMピンと方向の制御ピンを定義
const int motorPWMPin = 26;       // PWM信号を出力するピン
const int motorDirectionPin = 25; // モーターの方向制御信号を出力するピン

const char ssid[] = "ESP32WiFi";
const char pass[] = "esp32wifi";
const IPAddress ip(192, 168, 30, 3);
const IPAddress subnet(255, 255, 255, 0);

const int receive_port = 22224; // このESP32 のポート番号

WiFiUDP udp;

void setup()
{
    // ピンモードを設定
    pinMode(motorPWMPin, OUTPUT);
    pinMode(motorDirectionPin, OUTPUT);

    // PWM周波数を設定
    ledcSetup(0, 5000, 8);         // チャネル0を5000HzのPWM信号で8ビット分解能でセットアップ
    ledcAttachPin(motorPWMPin, 0); // チャネル0をmotorPWMPinにアタッチ

    Serial.begin(115200);
    WiFi.softAP(ssid, pass);
    delay(100);
    WiFi.softAPConfig(ip, ip, subnet);
    IPAddress myIP = WiFi.softAPIP();

    Serial.print("SSID: ");
    Serial.println(ssid);
    Serial.print("AP IP address: ");
    Serial.println(myIP);
    Serial.println("Server start!");

    // UDP 開始
    udp.begin(receive_port);
    delay(500);
}

// データ受信とモーター制御
void receiveUDP()
{
    int packetSize = udp.parsePacket();
    byte tmpbuf[2];

    Serial.print("[RESV] ");
    if (packetSize == 2)
    {
        udp.read(tmpbuf, 2);

        uint8_t motorPower = tmpbuf[0];
        bool motorDirection = tmpbuf[1]; // 0: low, 1: high

        controlMotor(motorPower, motorDirection);

        Serial.print("Motor Power: " + String(motorPower));
        Serial.print(", Direction: " + (motorDirection ? "HIGH" : "LOW"));
    }
    else
    {
        Serial.print("none.");
    }
    Serial.println();
}

void controlMotor(uint8_t power, bool direction)
{
    ledcWrite(0, power);
    digitalWrite(motorDirectionPin, direction ? HIGH : LOW);
}

void loop()
{
    receiveUDP();
    delay(10); // 少しの遅延を追加して、連続的なシリアル出力を減少させます。
}
