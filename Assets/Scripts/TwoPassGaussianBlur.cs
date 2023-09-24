using UnityEngine;
using UnityEngine.Rendering;

namespace Blur
{
    public class TwoPassGaussianBlur : MonoBehaviour
    {
        const string ShaderName = "Blur/TwoPassGaussianBlur";

        static readonly int Temp1Id = Shader.PropertyToID("_Temp1");
        static readonly int SigmaId = Shader.PropertyToID("_Sigma");

        CommandBuffer commandBuffer;
        [SerializeField] Material material;

        [SerializeField, Range(0.0001f, 1f)] float sigma = 0.1f;
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

        void Update()
        {
            Shader.SetGlobalFloat(SigmaId, sigma);
        }

        void BuildCommandBuffer()
        {
            if (material == null)
            {
                material = new Material(Shader.Find(ShaderName));
            }
            if (material != null)
            {
                commandBuffer = new CommandBuffer();
                commandBuffer.BeginSample("TwoPassGaussianBlur");
                commandBuffer.GetTemporaryRT(Temp1Id, -1, -1, 0);
                commandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, Temp1Id, material, 0);
                commandBuffer.Blit(Temp1Id, BuiltinRenderTextureType.None, material, 1);
                commandBuffer.ReleaseTemporaryRT(Temp1Id);
                commandBuffer.EndSample("TwoPassGaussianBlur");
            }
        }
    }
}
