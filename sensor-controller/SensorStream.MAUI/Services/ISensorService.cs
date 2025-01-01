
using System.Numerics;

namespace SensorStream.MAUI.Services
{
    public interface ISensorService
    {
        Vector3 AccelerometerData { get; }
        Vector3 GyroscopeData { get; }
        Quaternion OrientationData { get; }

        void StartIfNotStarted();
        void StopIfStarted();
    }
}