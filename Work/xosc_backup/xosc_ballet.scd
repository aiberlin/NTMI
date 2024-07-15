////////////// xosc nufo is unused by now ///////////
// OSCdef(\xoscAlive, { |msg, time|
// 	if (NTMI.nufo.lastInTime == 0 or: { NTMI.nufo.timeSinceLast > 10 }) {
// 		Tdef(\allLEDs).play;
// 	};
// 	NTMI.nufo.deviceName = \xosc;
// 	NTMI.nufo.lastInTime = time;
// }, "/imu").permanent_(true);
