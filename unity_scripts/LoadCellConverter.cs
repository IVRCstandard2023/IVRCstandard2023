using UnityEngine;
using Uduino;

public class LoadCellConverter : MonoBehaviour
{
    UduinoManager uduino;

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

    private void Start()
    {
        uduino = UduinoManager.Instance;
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
    }

    void ConvertDataToGrams(string data, UduinoDevice device)
    {
        // 受け取ったローデータをログに出力
        //Debug.Log("Received Raw Data: " + data);
        if (long.TryParse(data, out long rawValue))
        {
            float weightInGrams = (rawValue * HX711_ADC1bit) / HX711_SCALE;
            weightInGrams = weightInGrams - offset;
            if (!isFirstDataReceived){
                offset = weightInGrams;
                isFirstDataReceived = true;
            }

        

            Debug.Log("Weight: " + weightInGrams + " grams");
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