
// make an MKtl description dict for the flatcat:
(
descName: "flatcat",
deviceName: "flatcat",
protocol: \osc,
deviceType: \robotPet,
elementTypes: [\sensor],
status: (
	linux: "unknown",
	osx: "unknown",
	win: "unknown"
),

idInfo: "flatcat",
// info for flatcat in accesspoint mode
netAddrInfo: (ipAddress: "192.168.4.1", srcPort: 46757, recvPort: 8999 ),

deviceInfo: (
	vendorURI: "https://flatcat.berlin",
	description: "robot pet",
	features: [
	],
	longName: "jetpack lab flatcat",
	notes: "",
),

specs: (

	'voltage': [2.5, 6.5],

	'temper': [10, 60],
	'angle': [-0.5, 0.5],
	'velo': \bipolar,
	'curr': [-0.5, 0.5]
),

collectives: (
	alldata: (
		oscPath: '/flatcat',
		elements: [
			[\ubat], [\ubus], [\umot],

			[\temper0], [\angle0], [\velo0],[\curr0],
			[\temper1], [\angle1], [\velo1], [\curr1],
			[\temper2],[\angle2], [\velo2], [\curr2],
		],
		ioType: \in
	),
),

elementsDesc: (
	// input elements:
	shared: (elementType: 'slider', ioType: \collectiveIn),

	elements: [

		( key: \ubat, \spec: 'voltage' ),
		( key: \ubus, \spec: 'voltage' ),
		( key: \umot, \spec: 'voltage' ),

		( key: \temper0, \spec: 'temper' ),
		( key: \temper1, \spec: 'temper' ),
		( key: \temper2, \spec: 'temper' ),

		( key: \angle0, \spec: 'angle' ),
		( key: \angle1, \spec: 'angle' ),
		( key: \angle2, \spec: 'angle' ),

		( key: \velo0, \spec: 'velo' ),
		( key: \velo1, \spec: 'velo' ),
		( key: \velo2, \spec: 'velo' ),

		( key: \curr0, \spec: 'curr' ),
		( key: \curr1, \spec: 'curr' ),
		( key: \curr2, \spec: 'curr' )
	].collect { |el, i|
		el.put(\style, (column: i, height: 2))
	}
)
);