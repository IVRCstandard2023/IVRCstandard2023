using UnityEngine;
using Uduino;
using System.Collections;

public class LoadCellReader : MonoBehaviour
{
    private float currentWeight = 0.0f;
    public float updateInterval = 1.0f; // 重量情報を要求する間隔（秒）

    private float lastUpdateTime = 0.0f;

    void Start()
    {
        UduinoManager.Instance.OnValueReceived += ReadWeight;
    }

    void Update()
    {
        if (Time.time - lastUpdateTime > updateInterval)
        {
            RequestWeight();
            lastUpdateTime = Time.time;
        }
    }

    public void RequestWeight()
    {
        UduinoManager.Instance.sendCommand("getWeight");
        //Debug.Log("getWeight is send.");
    }

    void ReadWeight(string data, UduinoDevice device)
    {
        //Debug.Log("ReadWeight is called.");
        if (float.TryParse(data, out float weight))
        {
            currentWeight = weight;
            Debug.Log("Current Weight: " + currentWeight);
        }
    }

    void OnDisable()
    {
        UduinoManager.Instance.OnValueReceived -= ReadWeight;
    }
}
