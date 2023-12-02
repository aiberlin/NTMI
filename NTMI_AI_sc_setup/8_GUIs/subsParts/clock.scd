// maainstage clock and gui

/////// Clock display shows how long something has been running
/*
Tdef(\clocK).gui;

Tdef(\clocK).set(\isRunning, true);
// jumps back to zero when stopped
Tdef(\clocK).set(\isRunning, false);

// watch some Tdef to see how long a piece has been running
Tdef(\clocK).set(\isRunning, { Tdef(\watchMe).isPlaying });

Tdef(\watchMe).play;
Tdef(\watchMe).stop;

NTMI.g.main.clockZone = nil;

NTMI.g.main.clockZone.bounds;
*/

NTMI.g.clok = NTMI.g.clok ? ();
//
if (NTMI.g.main.clockZone.notNil and: {
	NTMI.g.main.clockZone.isClosed.not }) {
	"clock: using existing view...".postln;
	NTMI.g.clok.zone = NTMI.g.main.clockZone;
	NTMI.g.clok.extent = NTMI.g.clok.zone.bounds.extent;
} {
	var w;
	NTMI.g.clok.extent = 236@126; // same size;
	w = Window("clock", NTMI.g.clok.extent).front;
	"clock: making view".postln;
	NTMI.g.clok.zone = w.view;
};

NTMI.g.clok.uv = UserView(
	NTMI.g.clok.zone,
	NTMI.g.clok.extent * [1, 0.5]
);
//.background_(Color.rand)
NTMI.g.clok.uv.drawFunc_({ |uv|
	var timeStr = Tdef(\clocK).get(\timeStr);
	var font = NTMI.g.font.copy;
	var strBounds = timeStr.bounds(font);
	font.size_((font.size * (uv.bounds.width * 0.9 / strBounds.width)).round);
	Pen.stringCenteredIn(timeStr, uv.bounds, font, Color.white)
});

NTMI.g.clok.but = Button(
	NTMI.g.clok.zone,
	NTMI.g.clok.uv.bounds.top_(NTMI.g.clok.extent.y * 0.5)
)
//.background_(Color.rand)
.states_([
	["Reset Clock", Color.white, Color.grey(0.3, 0.3)],
]).font_(NTMI.g.font)
.action_({
	Tdef(\clocK).set(\runtime, 0, \isRunning, true).stop.play
});

Tdef(\clocK).clock = SystemClock;
Tdef(\clocK).addSpec(\runtime, [0, 10000, \lin, 1]);
Tdef(\clocK).set(\runtime, 0, \isRunning, true);
Tdef(\clocK).set(\timeStr, "00:00:00");

Tdef(\clocK, { |envir|
	var dt = 1;
	inf.do { |i|
		envir.timeStr = envir.runtime.asTimeString.drop(-4);
		defer { try { NTMI.g.clok.uv.refresh } };

		dt.wait;
		if (envir.isRunning == true) {
			envir.runtime = envir.runtime ? 0 + dt;
		} {
			envir.runtime = 0;
		};

	}
}).play;
