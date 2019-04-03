//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// GAMEPAD         ////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

/*

******** FERRARI Gamepad patch for Liz Allbee *********

INSTRUCTIONS:

--- START:
-  Attach Ferrari Gamepad
- start HAI_xosc app
-> loads everything automatically,
ends with big gui window


--- PLAYING:
== on GUI:
- select 4 front sounds in the 4 big GUI slots
- default is rjkChaos, kiteHi, moogSing, xFMSH

== on Ferrari:

- SELECT sounds to activate: Buttons 1 2 3 4  dis/enable four front sounds

- PLAY / Silence : Hold Button 6 - right shoulder - to play, let go for silence

--- CONTROL/INFLUENCE sound params by joysticks:
+ right joystick up/down is always amp,
+ left joystick (and right js left/right) are either:
- first 3 parameters of each active sound (direct control),
+ meta controls that influance all parameters 3 thru an influx object

- CHOOSE control mode: press button 6 for
-> direct mode -> sliders are light gray
-> influx mode -> sliders are green

-
*/

/*
MKtl.find(\hid);
MKtl('fer').free;
MKtl.openDescriptionFolder;

q.keys(Array).sort.cs
q.ndefs - the 4 active ones
q.active;

// all the element names
q.gpad.mktl.postElements;
q.gpad.mktl.gui;



*/

q = q ? ();
q.gpad = ();						// sub-Dict for all things gamePad

// MKtl.find(\hid);
// Ferrari wireless gamepad for Liz

if (MKtlLookup.findByIDInfo("Run'N' Drive_Thrustmaster").size == 1) {
	MKtl.all['fer'].free;
	q.gpad.mktl = g = MKtl('fer', "*run-n-drive");
} {
	if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size == 1) {
		MKtl.all['fer'].free;
		q.gpad.mktl = g = MKtl('fer', "*run-n-drive-wireless");
	};
};


if (q.gpad.mktl.isNil) {
	"No Ferrari Gamepad present - not loading gamepad patch.".postln;
} {
	"*** Ferrari Gamepad present - loading gamepad patch!!!".postln;

	q.gpad.mktl .gui;

	defer ({ (q.topDir +/+ "Ferrari_instructions.txt").openOS }, 5);
	q.active.gpad = Set[q.ndefs[0]];

	(
		// prepare all elements for debugging:
		g.elementsDict.do(_.action_(MFunc()));
		g.elementsDict.do { |el| el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln }) };
		g.elementsDict.do { |el| el.action.enable(\post) };
		g.elementsDict.do { |el| el.action.disable(\post) };


		// ACTIVES SELECTION: use buttons 1-4 to toggle 4 front sounds on/off
		[\bt_1, \bt_2, \bt_3, \bt_4].do { |btkey, i|
			g.elementsDict[btkey].action.add(\togPlay, { |bt|
				var ndef = q.ndefs[i];
				if ( bt.value > 0 ) {
					if (q.active.gpad.includes(ndef)) {
						q.active.gpad.remove(ndef)
					} {
						q.active.gpad.add(ndef)
					};
					q.active.gpad.postcs;
				};
			});
		};

		// ARTICULATION: only play while bt 6 (right shoulder) is held down
		// ToDo: button may change from gamepad to gamepad!
		g.elementsDict[\bt_6].action.add(\holdPlay, {|el|
			if (el.value > 0) {
				"*** GP play: ".post;
				q.active.gpad.do(_.play).postln;
			} {
				"*** GP stops all: ".post;
				q.ndefs.do(_.stop).postln;
			};
		});


		////////// CONTROL / INFLUX
		q.gpad.joyNames = [\joy_r_y, \joy_r_x, \joy_l_y, \joy_l_x];
		q.gpad.joyEls = q.gpad.joyNames.collect( MKtl(\fer).elementsDict[_]);

		// button 5 toggles between direct control and influx control
		g.elementsDict[\bt_5].action.add(\holdPlay, {|el|
			if (el.value > 0) {
				if (q.gpad.useInflux != true) {
					"*** GP switching to influx...".postln;
					q.gpad.useInflux = true;

					// attach q.ndefs minus amp control
					q.ndefs.do { |ndef|
						q.inphlux.attachMapped(
							ndef, ndef.key,
							ndef.controlKeys.drop(1)
						)
					};
				} {
					"*** GP switching to direct control...".postln;
					q.gpad.useInflux = false;
					q.ndefs.do { |ndef| q.inphlux.removeMapped( ndef.key ) };
				};
			}
		});

		q.gpad.joyNames.do { |joyName, i|
			var joyElem = g.elementsDict[joyName];

			///////// Direct set of amp and 3 params:
			joyElem.action.add(\set, { |el|
				q.active.gpad.do { |px|
					var paramName = px.controlKeys[i];
					var newval = el.value;
					// flip the y values so all forward is +1, pull back is 0
					if (i.even) { newval = 1 - newval };
					px.setUni(paramName, newval);
				}
			});
			///////// set by influx:
			joyElem.action.add(\infset, { |el|
				// leave amp control direct
				if (i == 0) {
					q.active.gpad.do { |px|
						var paramName = px.controlKeys[0];
						var newval = el.value;
						if (i.even) { newval = 1 - newval };
						px.setUni(paramName, newval);
					}
				} {
					// next three are influxed
					q.inphlux.set(q.inphlux.inNames[i], el.value.unibi);
				}
			}, false);
		};

		///////// still interesting?
		///////// ToDo: for Ferrari, add gas pedals for 1st and 2nd param ...
	);
};