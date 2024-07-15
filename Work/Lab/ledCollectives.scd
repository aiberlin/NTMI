s.options.ugenPluginsPath
ugensPlugin

SuperCollider

(Platform.resourceDir +/+ "plugins/").pathMatch.printAll
(Platform.userExtensionDir +/+ "*").pathMatch.printAll

collective

MKtl(\ntmi).desc.openFile;

(
MKtl.addSpec(\pwm8bit, [0, 255, \linear, 1]);

~descCollectiveOut = (
    idInfo: ( name: \collOut, ipAddress: "127.0.0.1", recvPort: NetAddr.langPort ),
	netAddrInfo: ( ipAddress: "127.0.0.1", recvPort: NetAddr.langPort ),
    protocol: \osc,
    'collectives': (
        leds: (
            oscPath: '/leds',
            // elements that make up the group in the order in which
            // they should appear in the output message:
            elements: [ [\led,0], [\led, 1], [\led, 2] ],
            argTemplate: [ 7 ], // default arguments to send
            ioType: \out
        )
    ),
    elementsDesc: (
        elements: [
            (
                key: 'led',
                shared: (
                    default: 0,
                    elementType: 'led', spec: \pwm8bit,
                    // use a group method to create the output
                    ioType: \collectiveOut
                ),
                elements: 3.collect { () }
            )
        ]
    )
);
)

m.free;
m = MKtl( \exampleCollectiveOut, ~descCollectiveOut );
m.gui;
thisProcess.openUDPPort(9000);
thisProcess.openPorts
OSCFunc.trace(true);

(
MKtl.addSpec(\pwm8bit, [0, 255, \linear, 1]);

~descCollectiveOut = (
	// idInfo: (idInfo: \collOutTest),
	idInfo: ( ipAddress: "127.0.0.1", recvPort: NetAddr.langPort ),
	protocol: \osc,

	// 'collectives': {
	// 	var collDict = ();
	//
	// 	(1..8).do { |num, ledI|
	// 		var key = num.asSymbol;
	// 		leds: (
	// 			oscPath: '/leds',
	// 			// elements that make up the group in the order in which
	// 			// they should appear in the output message:
	// 			elements: [ [\led,0], [\led, 1], [\led, 2] ],
	// 			argTemplate: [ 7 ], // default arguments to send
	// 			ioType: \out
	// 		};
	// 	},
		elementsDesc: (
			elements: [
				(
					key: 'led',
					shared: (
						default: 0,
						elementType: 'led', spec: \pwm8bit,
						// use a group method to create the output
						ioType: \collectiveOut
					),
					elements: 3.collect { () }
				)
			]
		)
	);
)

m.free;
m = MKtl( \exampleCollectiveOut, ~descCollectiveOut );
m.gui;



OSCFunc.trace( true );

m.collAt( \leds ).value_( [0, 1, 0] );
m.elAt( \led, 2 ).value_( 0.8 );
m.elAt( \led, 0 ).value_( 0.1 );

s.quit;
