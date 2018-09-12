# CoreBluetooth Demo

### Description

Demo project based on **CoreBluetooth** framework and **App Coordinators**. Main functionality:
1. Searhing for Mi Band peripheral devices
2. Connecting to the discovered devices
3. Reqesting device services and characteristics
4. Collecting RSSI values over time of all discovered devices and displaying data in chart
5. Sending data to a characteristic without response to start device vibration
6. [Charts](https://github.com/danielgindi/Charts) library usage example
7. Example of App Coordinators usage and DI based on delegation

<div style="text-align:center"><img  src ="https://github.com/davigr/BLEDemo/blob/master/demo-screen-recording.gif"></div>

### Setup

1. Clone or download repository
2. Install Pods

```
pod install
```

### Resources

1. [WWDC 2017 - 712 session](https://developer.apple.com/videos/play/wwdc2017/712/)
2. [Mobiconf 2016 - Best Practices](https://youtu.be/c3ZscUuMdXI)
3. [Apple Docs](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html#//apple_ref/doc/uid/TP40013257-CH1-SW1)
4. [GATT Profile](https://www.bluetooth.com/specifications/gatt/generic-attributes-overview)
5. [Xiaomi Mi Band 2](https://github.com/danielweber90/MiBand-for-Swift)
6. [BLE Intro](https://tessel.io/blog/94736742342/getting-started-with-ble-tessel)
