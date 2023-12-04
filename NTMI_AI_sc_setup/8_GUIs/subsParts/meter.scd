// ServerMeter does not scale at all...
// put it in its own window?

NTMI.g.main.meterWidth = ServerMeterView.getWidth(NTMI.numIns ? NTMI.numChans, NTMI.numChans);
NTMI.g.main.meterLeft = (NTMI.g.main.w.bounds.width - NTMI.g.main.meterWidth) div: 2;

NTMI.g.main.meter = ServerMeterView(s,
	NTMI.g.main.w,
	NTMI.g.main.meterLeft@0,
	NTMI.numIns ? NTMI.numChans,
	NTMI.numChans
);
