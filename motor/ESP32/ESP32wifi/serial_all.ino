#include <Arduino.h>
#include <WiFi.h>
#include <Melopero_VL53L1X.h>

// FreeRTOSのインクルードとタスクハンドルの宣言
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
TaskHandle_t sensorTaskHandle = NULL;

Melopero_VL53L1X sensor;

// モーターのPWMピンと方向の制御ピンを定義
const int motorPWMPin = 32;       // PWM信号を出力するピン
const int motorDirectionPin = 33; // モーターの方向制御信号を出力するピン

// ファンピン番号の定義
const int pin25 = 25; // 25番ピン
const int pin26 = 26; // 26番ピン

const int receive_baud = 9600; // COM7とのシリアル通信のボーレート
const int send_baud = 9600;    // COM7とのシリアル通信のボーレート

// センサー読み取りタスク
void sensorTask(void* pvParameters) {
    while (1) {
        VL53L1_Error status = 0;

        status = sensor.waitMeasurementDataReady();
        if (status != VL53L1_ERROR_NONE)
            printStatus("Error in wait data ready: ", status);

        status = sensor.getRangingMeasurementData();
        if (status != VL53L1_ERROR_NONE)
            printStatus("Error in get measurement data: ", status);

        status = sensor.clearInterruptAndStartMeasurement();
        if (status != VL53L1_ERROR_NONE)
            printStatus("Error in clear interrupts: ", status);

        Serial.print((float)sensor.measurementData.RangeMilliMeter + (float)sensor.measurementData.RangeFractionalPart / 256.0);
        Serial.println(" mm");

        // センサー読み取りの間隔を調整（例: 66ミリ秒）
        vTaskDelay(pdMS_TO_TICKS(30));
    }
}

void setup() {
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
    Serial.begin(9600); // COM7とのシリアル通信のボーレートに合わせて設定
    while (!Serial);
    Serial.println("Starting...");

    Wire.begin();
    sensor.initI2C(0x29, Wire);

    VL53L1_Error status = sensor.initSensor();
    printStatus("Device initialized : ", status);

    status = sensor.setDistanceMode(VL53L1_DISTANCEMODE_MEDIUM);
    printStatus("Set distance mode : ", status);

    status = sensor.setMeasurementTimingBudgetMicroSeconds(66000);
    printStatus("Set timing budget: ", status);

    status = sensor.setInterMeasurementPeriodMilliSeconds(75);
    printStatus("Set inter measurement time: ", status);

    status = sensor.clearInterruptAndStartMeasurement();
    printStatus("Start measurement: ", status);

    // センサー読み取りタスクを作成
    xTaskCreate(sensorTask, "Sensor Task", 2048, NULL, 1, &sensorTaskHandle);
}

void receiveSerial() {
    if (Serial.available() >= 1) {
        byte tmpbuf[1];
        Serial.readBytes(tmpbuf, 1);
        uint8_t motorPower = tmpbuf[0];
        bool motorDirection = 0; // 0: forward, 1: backward
        controlMotor(motorPower, motorDirection);

        // motorPowerはクリア前50-255のレンジ、クリア後は0を送ることにする
        digitalWrite(pin25, motorPower == 0 ? HIGH : LOW);
        digitalWrite(pin26, LOW);
    }
}

void controlMotor(uint8_t power, bool direction) {
    ledcWrite(0, power);
    digitalWrite(motorDirectionPin, direction ? HIGH : LOW);
}

void printStatus(String msg, VL53L1_Error status) {
    Serial.print(msg);
    Serial.println(status);
}

void loop() {
    receiveSerial();
}