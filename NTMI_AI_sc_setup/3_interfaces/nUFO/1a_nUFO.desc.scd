/*

////// desc file for NTMI with ESP32 chip \\\\\\\\\\\\\\\\

///////// quick instructions:

// 1. log into WIFI "NTMI" - one user at a time only!

// 2. select all and load this file

// 3. run this:

(
x.free; x = MKtl(\ntmi, "ai-ntmi");
x.elAt(\enc).value_(0.5);

try { y.close }; y = x.gui;
y.views.detect { |vw| vw.element.name == \enc }.view.centered_(true);

x.device.updateDstAddr("169.254.1.1", 57120);
x.device.updateSrcAddr("169.254.1.1", 57120);
)

// -> gui display should jitter slightly,
// -> and change clearly when you move the xosc!


x.getSpec;

OSCdef.trace;
OSCdef.trace(false);


////////// debug LEDs
fork { 8.do { |i| x.device.source.sendMsg("/ntmi/ledCtl/back", i, 0); 0.1.wait } };
fork { 8.do { |i| x.device.source.sendMsg("/ntmi/ledCtl/front", i, 0); 0.1.wait } };

fork { 8.do { |i| x.device.source.sendMsg("/ntmi/ledCtl/front", i, 1); 1.wait } };

x.device.source.sendMsg("/ntmi/ledCtl/front", 0, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 1, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 2, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 3, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 4, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 5, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 6, 1); //
x.device.source.sendMsg("/ntmi/ledCtl/front", 7, 1); //


// loopback to sclang for testing:
x.device.updateDstAddr("127.0.0.1", 57120);
x.device.updateSrcAddr("127.0.0.1", 57120);

///////// lang sends led values as floats, hm!
/// how to enforce integers?

////// test send messages:

n = NetAddr.localAddr;
n.sendMsg("/ntmi/caps", *8.collect { rrand(0.0, 0.5) });
n.sendMsg("/ntmi/imu",  *(10.collect { 1.0.rand2 }) * [4,4,4,  0.5,0.5,0.5,  0.5,0.5,0.5,  100]);
4.do { n.sendMsg("/ntmi/btns", 8.rand, 2.rand) };
n.sendMsg("/ntmi/enc", rrand(1, 6) * [-1, 1].choose);

*/


MKtlDesc.fromDict(
	(
		descName: "nUFO",
		deviceName: "ntmi",
		protocol: \osc,
		deviceType: \multiController,
		elementTypes: [\accelerometer, \sensor, \serial],
		status: (
			linux: "unknown",
			osx: "unknown",
			win: "unknown"
		),

		idInfo: "ntmi",
		// netAddrInfo: ( /*ipAddress: "169.254.1.1", */srcPort: 9000, recvPort: 8000 ), // ip for adhoc mode

		deviceInfo: (
			vendorURI: "http://www.airborneinstruments.eu",
			//	manualURI: "http://www.x-io.co.uk/downloads/x-OSC-User-Manual-v0.4.pdf",
			description: "nontrivial musical instrument sending by OSC",
			// features: [
			// 	"16× analogue/digital inputs",
			// 	"16× digital/PWM outputs (up to 50 mA per channel)",
			// 	"13-bit ADC with 400 Hz update rate per channel",
			// 	"Up to 16-bit PWM resolution for 5 Hz to 250 kHz",
			// 	"Control up to 400 RGB LEDs (NeoPixel)",
			// 	"4× serial communication channels"
			// ],
			longName: "AI-NTMI_esp32",
			notes: "",
		),

		specs: (
			\switch: [0, 1, \lin, 1],
			\pass: PassSpec,
			// measured degrees of rotation at 100 Hz sendrate:
			gyroAxis: [-250, 250],
			// measured max accel with fast shaking:
			accelAxis: [-8, 8],
			// guessing, usually more between +-0.5:
			magnetAxis: [-64, 64],

			cap: [0, 2047],
			// gyro temperature
			temp: [0, 100],
			// min and max working battery voltage
			batVolt: [3.4, 3.9],
			enc: [-7, 7, \lin, 1],
			ledInt: (default: 0, map: { |d, val| val.round(1).clip(0, 1).asInteger }, unmap: { |d, val| d.map(val) }, asSpec: { |d| d })
		),

		collectives: (
			imu: (
				oscPath: '/ntmi/imu',
				elements: [
					[\accel, \x], [\accel, \y], [\accel, \z],
					[\gyro, \pitch], [\gyro, \roll], [\gyro, \yaw],
					[\magnet, \pitch], [\magnet, \roll], [\magnet, \yaw],
					[\temp]
				],
				ioType: \in
			),
			caps: (
				oscPath: '/ntmi/caps',
				// this is the order in which the pads come from nUFO ... sigh:
				/// [ 1, 4, 0, 3, 5, 6, 7, 2 ]
				// so to get them in correct order ever after, this:
				elements: [ 2, 0, 7, 3, 1, 4, 5, 6 ].collect {|i|
					[\cap, (i + 1).asSymbol]
				},
				ioType: \in
			)
		),

		elementsDesc: (
			// input elements:

			elements: [

				// 10 floating-point arguments indicating the current readings of the on board sensors.
				/// Arguments 1 – 3 gyroscope (°/s) x, y, z; arguments 4 – 6 accelerometer (g), x, y ,z;
				// arguments 7 – 9 magnetometer (Ga) x, y ,z; argument 10 gyroscope temperature (°C)
				(
					key: \accel,
					shared: (elementType: 'accelAxis', ioType: \collectiveIn,
						\spec: 'accelAxis' ),
					elements: [\x, \y, \z].collect { |name, i|
						(key: name, style: (row: 0, column: i * 0.84 + 0, height: 1.5))
					}
				),
				(
					key: \gyro,
					shared: (elementType: 'gyroAxis', ioType: \collectiveIn,
						\spec: 'gyroAxis' ),
					elements: [\pitch, \roll, \yaw].collect{ |name, i|
						(key: name, style: (row: 0, column: i * 0.85 + 2.85, height: 1.5))
					}
				),
				(
					key: \magnet,
					shared: (elementType: 'gyroAxis', ioType: \collectiveIn,
						\spec: 'magnetAxis' ),
					elements: [\pitch, \roll, \yaw].collect { |name, i|
						(key: name, style: (row: 0, column: i* 0.85  + 5.7, height: 1.5))
					}
				),

				//// 8 floating-point analog values from the capsensors. Sent at analogue input message rate
				(
					key: \cap,
					shared: (elementType: \slider, spec: \cap, ioType: \collectiveIn),
					elements:  (1..8).collect { |num, i|
						(key: num.asSymbol,
							style: (column: [2, 5.5][i div: 4], row: i % 4 + 2, width: 1, height: 1.2)
						)

					}
				),

				(
					key: \bt,
					shared: (elementType: \switch, spec: \switch, \oscPath: '/ntmi/btns'),
					elements:  (1..8).collect { |num, i|
						( key: num.asSymbol, argTemplate: [ i ],
							style: (column: [1,6.5][i div: 4], row: i % 4 + 2)
						)
					}
				),

				(
					key: \enc, oscPath: '/ntmi/enc', ioType: \in,
					elementType: \encoder, spec: \enc,
					style: (column: 9, row: 1)

				),

				(
					key: \temp, elementType: 'slider', ioType: \collectiveIn,
					\spec: 'temp', style: (column: 9, row: 2, height: 1.5) ),

				// 1 float indicating the current battery voltage
				(
					key: \battery, oscPath: '/ntmi/batt', ioType: \in,
					elementType: \slider, spec: \batVolt,
					style: (column: 9, row: 3.5, height: 1.5)),


				////// leds are out elements
				(
					key: \led,
					shared: (elementType: \button, spec: \ledInt, ioType: \out),
					elements:  [
						(key: \fr, elements: (1..8).collect { |num, i|
							(
								key: num.asSymbol,
								oscPath: '/ntmi/ledCtl/front',
								argTemplate: [ i ],
								style: (column: [3, 4.5][i div: 4], row: i % 4 + 2)
							)
						}),
						(key: \bk, elements: (1..8).collect { |num, i|
							(
								key: num.asSymbol,
								oscPath: '/ntmi/ledCtl/back',
								argTemplate: [ i ],
								style: (column: [0, 7.5][i div: 4], row: i % 4 + 2)
							)
						}),
					]
				),

			]
		)
	)
);

//////// for testing layout:
// Window.closeAll;
// x.free; x = MKtl(\ntmi, "ai-ntmi"); x.gui;
// x.elAt(\cap).value;