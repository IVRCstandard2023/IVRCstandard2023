// 必要なライブラリをインクルード
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>

// モーターのPWMピンと方向の制御ピンを定義
const int motorPWMPin = 32;       // PWM信号を出力するピン
const int motorDirectionPin = 33; // モーターの方向制御信号を出力するピン

// ファンピン番号の定義
const int pin25 = 25; // 25番ピン
const int pin26 = 26; // 26番ピン

const char ssid[] = "ESP32WiFi";
const char pass[] = "esp32wifi";
const IPAddress ip(192, 168, 30, 3);
const IPAddress subnet(255, 255, 255, 0);

const int send_port = 65000;  //送り先
const int receive_port = 10000; // このESP32 のポート番号

WiFiUDP udp;

void setup()
{
    // ピンモードを設定
    pinMode(motorPWMPin, OUTPUT);
    pinMode(motorDirectionPin, OUTPUT);

    // ピンモードを設定
    pinMode(pin25, OUTPUT); // 25番ピンを出力モードに設定
    pinMode(pin26, OUTPUT); // 26番ピンを出力モードに設定

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
        bool motorDirection = 0; // 0: forward, 1: backward
        bool fanswitch = tmpbuf[1];          // 0: off, 1: on

        uint8_t constrainedPower = constrain(motorPower, 0, 255);
        controlMotor(constrainedPower, motorDirection);

        Serial.print("Motor Power: ");
        Serial.print(constrainedPower);
        Serial.print(", Direction: ");
        Serial.print(motorDirection ? "HIGH" : "LOW");

        if (fanswitch == 1)
        {
            digitalWrite(pin25, HIGH); // 25番ピンをHIGHにする
            digitalWrite(pin26, LOW);  // 26番ピンをLOWにする
            Serial.print(", Fan: ON");
        }
        else
        {
            // モーターの動作止める
            digitalWrite(pin25, LOW);
            digitalWrite(pin26, LOW); 
            Serial.print(", Fan: OFF");
        }

        // UDPで受信確認メッセージを送信
        udp.beginPacket(udp.remoteIP(), send_port);
        udp.write((uint8_t*)"Received UDP", 12); // 受信確認メッセージ

        Serial.println("Already sent UDP message.");
        udp.endPacket();

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