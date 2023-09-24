﻿using UnityEngine;
using UnityEngine.Rendering;

namespace Blur
{
    public class TwoPassGaussianBlur : MonoBehaviour
    {
        static readonly int Temp1Id = Shader.PropertyToID("_Temp1");

        [SerializeField] Shader shader;
        [SerializeField, Range(0.0001f, 1f)] float sigma = 0.1f;

        CommandBuffer commandBuffer;
        Material material;
        Camera mainCamera;

        void OnEnable()
        {
            mainCamera = Camera.main;
            if (mainCamera == null)
            {
                return;
            }
            BuildCommandBuffer();
            mainCamera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
        }

        void OnDisable()
        {
            if (mainCamera != null && commandBuffer != null)
            {
                mainCamera.RemoveCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
            }
        }

        void BuildCommandBuffer()
        {
            if (material == null)
            {
                material = new Material(shader);
            }
            if (material != null)
            {
                commandBuffer = new CommandBuffer();
                commandBuffer.name = shader.name;
                commandBuffer.BeginSample(shader.name);
                commandBuffer.GetTemporaryRT(Temp1Id, -1, -1, 0, FilterMode.Bilinear);
                // NOTE: _MainTex in this pass is NOT Bilinear filtered. Use Bilinear SampleState in shader!
                commandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, Temp1Id, material, 0);
                commandBuffer.Blit(Temp1Id, BuiltinRenderTextureType.None, material, 1);
                commandBuffer.ReleaseTemporaryRT(Temp1Id);
                commandBuffer.EndSample(shader.name);
            }
        }

        void OnDestroy()
        {
            if (material != null)
            {
                Destroy(material);
            }
        }
    }
}
