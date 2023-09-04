using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Uduino;

public class LoadCellToMotor : MonoBehaviour
{
    UduinoManager uduino;
    // Arduinoのピン情報→Motor
    private const int pwmPin = 3;
    private const int enablePin = 2;

    // HX711の変換定数
    const float OUT_VOL = 0.002f;
    const float LOAD = 100000.0f;
    const float HX711_R1 = 20000.0f;
    const float HX711_R2 = 8200.0f;
    const float HX711_VBG = 1.25f;
    const float HX711_AVDD = 4.2987f; // (HX711_VBG*((HX711_R1+HX711_R2)/HX711_R2))
    const float HX711_ADC1bit = HX711_AVDD / 16777216; // 16777216=(2^24)
    const float HX711_PGA = 128;
    const float HX711_SCALE = (OUT_VOL * HX711_AVDD / LOAD * HX711_PGA);
    //
    bool isFirstDataReceived = false;
    float offset = 0.0f;
    float threshold = -100.0f;
    private bool isCoroutineRunning = false;
    private float timeToStopMotor = 0f;
    private bool isMotorRunning = false;

    private void Start()
    {
        uduino = UduinoManager.Instance;
        //Motorまわり
        uduino.pinMode(pwmPin, PinMode.Output);
        uduino.pinMode(enablePin, PinMode.Output);
        uduino.digitalWrite(enablePin, State.HIGH); // Enable ESCON
        //uduino.analogWrite(pwmPin, 20);  // Set the motor speed
        //LoadCellまわり
        uduino.OnDataReceived += ConvertDataToGrams;
        isFirstDataReceived = false;
        offset = 0;

    }


    void Update()
    {
        if (uduino != null)
        {
            uduino.sendCommand("getWeight");
        }
        if (isMotorRunning)
        {
            if (Time.time >= timeToStopMotor)
            {
                // Your motor deactivation code here
                // モーターを無効化
                uduino.analogWrite(pwmPin, 20);  // Set the motor speed to 0
                Debug.Log("Motor stopped at: " + Time.time);
                isMotorRunning = false;
            }
        }
    }

    void ConvertDataToGrams(string data, UduinoDevice device)
    {
        // 受け取ったローデータをログに出力
        //Debug.Log("Received Raw Data: " + data);
        //uduino.analogWrite(pwmPin, 20);  // Set the motor speed
        if (long.TryParse(data, out long rawValue))
        {
            float weightInGrams = (rawValue * HX711_ADC1bit) / HX711_SCALE;
            weightInGrams = weightInGrams - offset;
            /* if (!isFirstDataReceived)
            {
                offset = weightInGrams;
                isFirstDataReceived = true;
            }
 */
            if (!isFirstDataReceived || weightInGrams >= 180000)
            {
                offset = weightInGrams;
                isFirstDataReceived = true;
            }


            Debug.Log("Weight: " + weightInGrams + " grams");
            //Motorの処理
            if(weightInGrams < threshold && !isMotorRunning){
                // Your motor activation code here
                Debug.Log("Motor started at: " + Time.time);
                uduino.analogWrite(pwmPin, 50);  // Set the motor speed 40は弱い

                timeToStopMotor = Time.time + 1f;
                isMotorRunning = true;
            }
        }
    }
   
    private void OnDestroy()
    {
        if (uduino != null)
        {
            uduino.OnDataReceived -= ConvertDataToGrams;
        }
    }
}
