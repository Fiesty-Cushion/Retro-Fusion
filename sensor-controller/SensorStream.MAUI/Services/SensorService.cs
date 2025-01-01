using System.Numerics;

namespace SensorStream.MAUI.Services;

public sealed class SensorService : ISensorService
{
    private IAccelerometer Accelerometer { get; } = Microsoft.Maui.Devices.Sensors.Accelerometer.Default;
    private IGyroscope Gyroscope { get; } = Microsoft.Maui.Devices.Sensors.Gyroscope.Default;
    private IOrientationSensor OrientationSensor { get; } = Microsoft.Maui.Devices.Sensors.OrientationSensor.Default;

    public Vector3 AccelerometerData { get; private set; } = new();
    public Vector3 GyroscopeData { get; private set; } = new();
    public Quaternion OrientationData { get; private set; } = new();

    public SensorService()
    {

    }

    public void StartIfNotStarted()
    {
        if (!Accelerometer.IsMonitoring)
        {
            Accelerometer.ReadingChanged += Accelerometer_ReadingChanged;
            Accelerometer.Start(SensorSpeed.Game);
        }
        if (!Gyroscope.IsMonitoring)
        {
            Gyroscope.ReadingChanged += Gyroscope_ReadingChanged;
            Gyroscope.Start(SensorSpeed.Game);
        }
        if (!OrientationSensor.IsMonitoring)
        {
            OrientationSensor.ReadingChanged += OrientationSensor_ReadingChanged;
            OrientationSensor.Start(SensorSpeed.Game);
        }
    }

    public void StopIfStarted()
    {
        if (Accelerometer.IsMonitoring)
        {
            Accelerometer.Stop();
            Accelerometer.ReadingChanged -= Accelerometer_ReadingChanged;
        }
        if (Gyroscope.IsMonitoring)
        {
            Gyroscope.Stop();
            Gyroscope.ReadingChanged -= Gyroscope_ReadingChanged;
        }
        if (OrientationSensor.IsMonitoring)
        {
            OrientationSensor.Stop();
            OrientationSensor.ReadingChanged -= OrientationSensor_ReadingChanged;
        }
    }
    private void Accelerometer_ReadingChanged(object? sender, AccelerometerChangedEventArgs args)
    {
        AccelerometerData = args.Reading.Acceleration;
    }

    private void Gyroscope_ReadingChanged(object? sender, GyroscopeChangedEventArgs args)
    {
        GyroscopeData = args.Reading.AngularVelocity;
    }

    private void OrientationSensor_ReadingChanged(object? sender, OrientationSensorChangedEventArgs args)
    {
        OrientationData = args.Reading.Orientation;
    }
}
