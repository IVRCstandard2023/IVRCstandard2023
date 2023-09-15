// 必要なライブラリをインクルード
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <Melopero_VL53L1X.h>

Melopero_VL53L1X sensor;

// モーターのPWMピンと方向の制御ピンを定義
const int motorPWMPin = 32;       // PWM信号を出力するピン
const int motorDirectionPin = 33; // モーターの方向制御信号を出力するピン

// ファンピン番号の定義
const int pin25 = 25; // 25番ピン
const int pin26 = 26; // 26番ピン

const char ssid[] = "ESP32WiFi";
const char pass[] = "esp32wifi";
const IPAddress ip(192, 168, 30, 3);
const IPAddress RemoteIP(192, 168, 30, 4); // 送信先の固定IPアドレス
const IPAddress subnet(255, 255, 255, 0);

const int send_port = 65000;  //送り先
const int receive_port = 10000; // このESP32 のポート番号

WiFiUDP udp;

void setup()
{
    //motor setting
    // ピンモードを設定
    pinMode(motorPWMPin, OUTPUT);
    pinMode(motorDirectionPin, OUTPUT);

    // ピンモードを設定
    pinMode(pin25, OUTPUT); // 25番ピンを出力モードに設定
    pinMode(pin26, OUTPUT); // 26番ピンを出力モードに設定

    // PWM周波数を設定
    ledcSetup(0, 5000, 8);         // チャネル0を5000HzのPWM信号で8ビット分解能でセットアップ
    ledcAttachPin(motorPWMPin, 0); // チャネル0をmotorPWMPinにアタッチ


    // sensor setting
    Serial.begin(9600);
    while(!Serial);
    Serial.println("Starting...");

    VL53L1_Error status = 0;
    Wire.begin(); // use Wire1.begin() to use I2C-1 
    sensor.initI2C(0x29, Wire); // use sensor.initI2C(0x29, Wire1); to use I2C-1
  
    status = sensor.initSensor();
    printStatus("Device initialized : ", status);
  
    status = sensor.setDistanceMode(VL53L1_DISTANCEMODE_MEDIUM);
    printStatus("Set distance mode : ", status);

    /*  Timing budget is the time required by the sensor to perform one range 
     *  measurement. The minimum and maximum timing budgets are [20 ms, 1000 ms] */
    status = sensor.setMeasurementTimingBudgetMicroSeconds(66000);
    printStatus("Set timing budget: ", status);

    /*  Sets the inter-measurement period (the delay between two ranging operations) in milliseconds. The minimum 
     *  inter-measurement period must be longer than the timing budget + 4 ms.*/
    status = sensor.setInterMeasurementPeriodMilliSeconds(75);
    printStatus("Set inter measurement time: ", status);

    //If the above constraints are not respected the status is -4: VL53L1_ERROR_INVALID_PARAMS
    status = sensor.clearInterruptAndStartMeasurement();
    printStatus("Start measurement: ", status);


    //wifi setting
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

        // // UDPで受信確認メッセージを送信
        // udp.beginPacket(udp.remoteIP(), send_port);
        // udp.write((uint8_t*)"Received UDP", 12); // 受信確認メッセージ

        // Serial.println("Already sent UDP message.");
        // udp.endPacket();

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


void printStatus(String msg, VL53L1_Error status){
  Serial.print(msg);
  Serial.println(status);
}


void loop()
{
    VL53L1_Error status = 0;

    status = sensor.waitMeasurementDataReady();
    if (status != VL53L1_ERROR_NONE) printStatus("Error in wait data ready: ",  status);

    status = sensor.getRangingMeasurementData();
    if (status != VL53L1_ERROR_NONE) printStatus("Error in get measurement data: ",  status);

    status = sensor.clearInterruptAndStartMeasurement();
    if (status != VL53L1_ERROR_NONE) printStatus("Error in clear interrupts: ",  status);

    Serial.print((float)sensor.measurementData.RangeMilliMeter + (float)sensor.measurementData.RangeFractionalPart/256.0);
    Serial.println(" mm");


    // // 送信先のIPアドレスをシリアル出力
    // Serial.print("Sending to IP address: ");
    // Serial.println(udp.remoteIP());
    // センサーデータから整数部を取得
    int sensorDataInteger = sensor.measurementData.RangeMilliMeter;

    // 整数部を文字列に変換
    char sensorDataStr[10]; // 十分な桁数を確保
    sprintf(sensorDataStr, "%d", sensorDataInteger);

    // UDPパケットを作成
    udp.beginPacket(RemoteIP, send_port);
    udp.write((uint8_t*)sensorDataStr, strlen(sensorDataStr)); // センサーデータの整数部をUDPパケットに追加
    udp.endPacket();

    receiveUDP();
    delay(10); // 少しの遅延を追加して、連続的なシリアル出力を減少させます。
}