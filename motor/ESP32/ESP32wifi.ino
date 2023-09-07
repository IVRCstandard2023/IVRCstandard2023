// 必要なライブラリをインクルード
#include <Arduino.h>

// モーターのPWMピンと制御ピンを定義
const int motorPWMPin = 26;  // PWM信号を出力するピン
const int motorControlPin = 25;  // モーターの制御信号を出力するピン

/* WiFi-Control-Car(softAP) */							
#include <WiFi.h>
#include <WiFiUdp.h>

const char ssid[] = "ESP32WiFi";
const char pass[] = "esp32wifi";
const IPAddress ip(192,168,30,3);
const IPAddress subnet(255,255,255,0);
const char* send_address = "192.168.30.3";

const int send_port = 22222;  //送り先
const int receive_port = 22224;  //このESP32 のポート番号

WiFiUDP udp;

//送るデータのサイズ。データはショート型の符号付き２バイト、送信時は１バイトに変換。
static const int MSG_SIZE = 10;//送信データの数
static const int MSG_BUFF = MSG_SIZE * 2;//送信データのバイト数

//共用体の設定。共用体はたとえばデータをショートで格納し、バイト型として取り出せる
typedef union {
  short sval[MSG_SIZE];//ショート型
  uint8_t bval[MSG_BUFF];//符号なしバイト型
} UDPData;
UDPData s_upd_message_buf; //送信用共用体のインスタンスを宣言
UDPData r_upd_message_buf; //受信用共用体のインスタンスを宣言

int count = 0;//送信変数用のカウント

void setup() {
      // ピンモードを設定
  pinMode(motorPWMPin, OUTPUT);
  pinMode(motorControlPin, OUTPUT);

  // PWM周波数を設定
  ledcSetup(0, 5000, 8);  // チャネル0を5000HzのPWM信号で8ビット分解能でセットアップ
  ledcAttachPin(motorPWMPin, 0);  // チャネル0をmotorPWMPinにアタッチ

  Serial.begin(115200);
  WiFi.softAP(ssid,pass);
  delay(100);
  WiFi.softAPConfig(ip,ip,subnet);
  IPAddress myIP = WiFi.softAPIP();

  Serial.print("SSID: ");
  Serial.println(ssid);
  Serial.print("AP IP address: ");
  Serial.println(myIP);
  Serial.println("Server start!");

  //UDP 開始
  udp.begin(receive_port);
  delay(500);
}

//受信用の関数
//パケットが来ているか確認し、r_upd_message_buf配列に保存する
void receiveUDP() {
  int packetSize = udp.parsePacket();
  byte tmpbuf[MSG_BUFF];//パケットを一次受けする配列

  //データの受信
  Serial.print("[RESV] ");
  if (packetSize == MSG_BUFF) {//受信したパケットの量を確認
    udp.read(tmpbuf, MSG_BUFF);//パケットを受信
    for (int i = 0; i < MSG_BUFF; i++)
    {
      r_upd_message_buf.bval[i] = tmpbuf[i];//受信データを共用体に転記
    }
    for (int i = 0; i < MSG_SIZE; i++)
    {
      Serial.print(String(r_upd_message_buf.sval[i]));//シリアルモニタに出力
      Serial.print(", ");
    }
  } else
  {
  Serial.print("none.");//受信していない場合はシリアルモニタにnone.を出力
  }
  Serial.println();
}

//送信用の関数
void sendUDP() {
  String test = "";//表示用の変数

  udp.beginPacket(send_address, send_port);//UDPパケットの開始

  for (int i = 0; i < MSG_BUFF; i++) {
    udp.write(s_upd_message_buf.bval[i]);//１バイトずつ送信
    if (i % 2 == 0) {//表示用に送信データを共用体から2バイトずつ取得
      test += String(s_upd_message_buf.sval[i / 2]) + ", ";
    }
  }
  Serial.println("[SEND] " + test );//送信データ（short型）を表示

  udp.endPacket();//UDPパケットの終了
}

void loop() {
  // put your main code here, to run repeatedly:
  //もしデータパケットが来ていれば受信する
  receiveUDP();

  //送信するデータを作成
  for (int i = 0; i < MSG_SIZE; i++) {
    s_upd_message_buf.sval[i] = (short)( i + count);
  }

  sendUDP();//UDPで送信

  count += 10;//データ作成用のカウントを追加
  if (count > 10000) {
    count = 0;
  }

  delay(500);
}
