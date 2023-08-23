// ESCONモータコントローラの制御ピンを定義
const int pwmPin = 3;     // Arduino Digital 3 → ESCON Digital 1 (PWM)
const int directionPin = 5;     // Arduino Digital 5 → ESCON Digital 3 (Direction)
const int enablePin = 2;  // Arduino 3.3V → ESCON Digital 2 (Enable)

void setup() {
  // モータコントローラのピンを出力モードに設定
  pinMode(pwmPin, OUTPUT);
  pinMode(directionPin, OUTPUT);
  pinMode(enablePin, OUTPUT);

  // シリアル通信の開始
  Serial.begin(9600);

  // ESCONを初期状態に設定
  digitalWrite(enablePin, HIGH);  // Enable ESCON
}

void loop() {
  // モータコントローラを有効化
  digitalWrite(enablePin, HIGH);

  // 回転方向を設定し、PWM duty cycleを0.1から0.2まで変化させる
  for (int i = 0; i < 2; i++) {
    digitalWrite(directionPin, i % 2 == 0 ? HIGH : LOW); // Change direction every cycle

    // PWM duty cycle from 0.1 to 0.2
    for (float dutyCycle = 0.1; dutyCycle <= 0.15; dutyCycle += 0.001) {
      int pwmValue = dutyCycle * 255;
      analogWrite(pwmPin, pwmValue);
      delay(100);

      // シリアルポートからのデータ受信を確認
      if (Serial.available() > 0) {
        break;
      }
    }

    // 3秒待つ
    delay(3000);
  }
}
