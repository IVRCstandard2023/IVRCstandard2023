// ESCONモータコントローラの制御ピンを定義
const int enablePin = 3;  // Arduino Digital 3 → ESCON Digital 1 (Enable)
const int setPin = 5;     // Arduino Digital 5 → ESCON Digital 3 (Set)

void setup() {
  // モータコントローラのピンを出力モードに設定
  pinMode(enablePin, OUTPUT);
  pinMode(setPin, OUTPUT);

  // ESCONを初期状態に設定
  digitalWrite(enablePin, LOW);  // Disable ESCON
  digitalWrite(setPin, LOW);     // Set value to 0
}

void loop() {
  // モータコントローラを有効化
  digitalWrite(enablePin, HIGH);
  
  // Set value to 1
  digitalWrite(setPin, HIGH);
  
  // 5秒間待つ
  delay(5000);
  
  // Set value to 0
  digitalWrite(setPin, LOW);
  
  // 1秒間待つ
  delay(1000);
}
