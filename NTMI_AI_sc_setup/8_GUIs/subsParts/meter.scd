// ServerMeter does not scale at all...
// put it in its own window?

var numInsToShow = max(NTMI.numIns ? NTMI.numChans, s.options.numInputBusChannels);
var numOutsToShow = max(NTMI.numChans, s.options.numOutputBusChannels);

NTMI.g.main.meterWidth = ServerMeterView.getWidth(numInsToShow, numOutsToShow);

// try to center it, but keep outside scope view
NTMI.g.main.meterLeft = (NTMI.g.main.w.bounds.width - NTMI.g.main.meterWidth div: 2).max(270);

NTMI.g.main.meter = ServerMeterView(s,
	NTMI.g.main.w,
	NTMI.g.main.meterLeft@0,
	numInsToShow, numOutsToShow
);

