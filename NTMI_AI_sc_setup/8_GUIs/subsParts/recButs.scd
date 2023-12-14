var zone = NTMI.g.main.recZone;
var bounds = zone.bounds;
var height = bounds.height;
var font = NTMI.g.font;

NTMI.g.main.recBut = Button(zone,
	Rect(0,0, bounds.width, height * 0.5)
).states_([
	["RECORD?", Color.white, NTMI.g.butGrey],
	["Recording!", Color.black, NTMI.g.butGreen]
]).font_(font)
.action_({ |bt|
	if (bt.value > 0) {
		s.recChannels_(q.numChans ? 2);
		s.record;
	} {
		s.stopRecording;
	}
});

Button(zone,
	Rect(0, height * 0.5, bounds.width, height * 0.5)
).states_([
	["show recordings", Color.white, NTMI.g.butGrey]
]).font_(font.copy.size_(font.size * 0.8))
.action_({ |bt|
	Platform.recordingsDir.openOS;
});