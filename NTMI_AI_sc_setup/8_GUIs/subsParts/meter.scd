// ServerMeter does not scale at all...
// put it in its own window?

NTMI.g.main.meterWidth = ServerMeterView.getWidth(
	NTMI.numIns ? NTMI.numChans,
	s.options.numOutputBusChannels
);

// try to center it, but keep outside scope view
NTMI.g.main.meterLeft = (NTMI.g.main.w.bounds.width - NTMI.g.main.meterWidth div: 2).max(400);

NTMI.g.main.meter = ServerMeterView(s,
	NTMI.g.main.w,
	NTMI.g.main.meterLeft@0,
	max(NTMI.numIns, s.options.numInputBusChannels),
	max(NTMI.numChans, s.options.numOutputBusChannels)
);

