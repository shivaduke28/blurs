using System;
using UnityEngine;
using UnityEngine.UI;

namespace Blur
{
    public class SigmaSetter : MonoBehaviour
    {
        [SerializeField] Slider slider;
        static readonly int SigmaId = Shader.PropertyToID("_Sigma");

        void Awake()
        {
            slider.onValueChanged.AddListener(x => Shader.SetGlobalFloat(SigmaId, x));
        }
    }
}
