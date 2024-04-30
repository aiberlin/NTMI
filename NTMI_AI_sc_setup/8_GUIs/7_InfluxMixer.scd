/***
This mixer shows all sources of Influence:

- all local sources, typically MKtls
- if existing, the /OSCRouter network connection
- if enabled, xflux and sources arriving via xflux
- xflux sending and listening settings - flags and zoom levels.

One can set the amount of influence (zoom) for each of these sources,
and (where available) switch between setRel and setAbs modes.
***/


NTMI.mkmix = NTMI.mkmix ? ();

NTMI.mkmix.colors = 9.collect { |i| Color.hsv(i/9, 0.5, 1) };

Butz('interfaces').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });
Butz('NTMI').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });

WinBounds.addMake(\InfluxMixer, {
	var mktls = MKtl.all.skeys.select(_ != \xflux).collect(MKtl(_));
	// maybe some sources are added later
	var numItems = (NTMI.mkmix.numItems ? 6).max(mktls.size + 4);

	var f = Font(Font.defaultMonoFace, 14, true);
	var w = Window(\InfluxMixer,
		Rect.aboutPoint(NTMI.g.bounds.center, 250, numItems + 2 * 12)
	).front.alpha_(NTMI.g.alpha);
	w.addFlowLayout(2@2, 2@2);

	NTMI.mkmix.numItems = numItems;

	// only make oscar/xflux guis if there:
	if (NTMI.oscar.oscar.notNil) {
		// xflux global settings here:
		// oscar status / join button
		NTMI.mkmix.oscBut = Button(w, Rect(0, 0, 100, 40)).font_(f)
		.states_([["NTMI.oscar \njoin"], ["NTMI.oscar \njoined", Color.black, Color.green]])
		.action_({ |bt, mod = 0|
			if (bt.value > 0) {
				"join...".postln;
				NTMI.oscar.oscar.join;
			} {
				if (mod > 0) {
					NTMI.oscar.oscar.close;
				} {
					"Hold shift to close OSCRouter!".postln
				};
			}
		});
		NTMI.mkmix.peersV = StaticText(w, Rect(0, 0, 390, 40)).string_("peers").align_(\center).font_(f).background_(Color.grey(0.95));

		// xflux status and global zoom levels
		NTMI.mkmix.xsendBut = Button(w, Rect(0, 0, 120, 20)).font_(f)
		.states_([["xflux send"], ["xflux sends", Color.black, Color.green]])
		.action_({ |bt| NTMI.xflux.sends = bt.value > 0 });
		NTMI.mkmix.xsendSl = EZSlider(w, Rect(0, 0, 340, 20), "zoomSend", [0, 1], { |sl|
			NTMI.xflux.zoomSend = sl.value;
		}, labelWidth: 100, numberWidth: 40).font_(f);

		NTMI.mkmix.xlistenBut = Button(w, Rect(0, 0, 120, 20)).font_(f)
		.states_([["xflux listens"], ["xflux listens", Color.black, Color.green]])
		.action_({ |bt| NTMI.xflux.listens = bt.value > 0 });
		NTMI.mkmix.xlistenSl = EZSlider(w, Rect(0, 0, 340, 20), "zoomListen", [0, 1], { |sl|
			NTMI.xflux.zoomListen = sl.value;
		}, labelWidth: 100, numberWidth: 40).font_(f);

	} {
		Button(w, Rect(0, 0, 500, 20)).font_(f)
		.states_([["NTMI.oscar.makeServer"]])
		.action_({ |bt, mod = 0|
			NTMI.oscar.makeServer;
			defer ({
				if (NTMI.oscar.oscar.notNil) {
					NTMI.mkmix.skip.stop.free;
					w.close;
					WinBounds.showOrMake(\InfluxMixer)
				}
			}, 0.2);
		});

	};

	// then local mktls
	StaticText(w, Rect(0, 0, 500, 20)).font_(f)
	.string_("protocol, status, MKtl name, influxMode, influxZoom");

	NTMI.mkmix.influxModes = [\setRel, \setAbs];
	NTMI.mkmix.mktls = mktls;
	NTMI.mkmix.numMKtls = 0;

	// if not there, make dict for mktl and fill with defaults
	mktls.do { |mk, i|
		var mkdict = NTMI.q[mk.name];

		if (mkdict.isNil) {
			"*** % has no NTMI dict - making it now.\n".postf(mk);
			NTMI.q.put(mk.name, mkdict = ());
		};
		mkdict.influxMode = mkdict.influxMode ? NTMI.mkmix.influxModes[0];
		mkdict.zoom = mkdict.zoom ? 0.5;
		// [mk, mkdict].postln;
	};

	NTMI.mkmix.lines = numItems.collect { |i|
		[
			StaticText(w, Rect(0, 0, 50, 20)).font_(f).string_("prot"),

			Button(w, Rect(180, 0, 40, 20)).states_([["virtual"], ["real!"]])
			.action_({ |bt, mod = 0|
				var mk = NTMI.mkmix.mktls[i];
				if (bt.value > 0 and: mk.hasDevice.not) {
					mk.openDevice
				} {
					if (mod.postln == 0) {
						"hold shift, alt or ctrl to close device...".postln;
					} {
						mk.closeDevice
					};
				};
				bt.value = mk.hasDevice
			}),

			Button(w, Rect(180, 0, 40, 20)).states_([["gui"]])
			.action_({
				var mk = NTMI.mkmix.mktls[i];
				if (WinBounds.makeFuncs[mk.name].notNil) {
					WinBounds.showOrMake(mk.name)
				} { mk.gui.showLabels }
			}),

			DragSource(w, Rect(40, 0, 140, 20)).font_(f).background_(Color.green)
			.object_(NTMI.mkmix.mktls[i]),

			PopUpMenu(w, Rect(220, 0, 70, 20)).items_([ \setRel, \setAbs])
			.action_({ |pop|
				var mk = NTMI.mkmix.mktls[i];
				// if there is a swth function, call it
				NTMI.at(mk.name)[pop.item.postln].value.postln;
				// if not, always set the mode
				NTMI.at(mk.name).influxMode = pop.item;
			}),

			EZSlider(w, Rect(290, i + 1 * 20, 140, 20), "", [0, 1], { |sl|
				var mk = NTMI.mkmix.mktls[i];
				NTMI.at(mk.name).zoom = sl.value;
			}, labelWidth: 0, numberWidth: 35)
		]
	};

	NTMI.mkmix.skip.stop.free;
	NTMI.mkmix.prevMKtls = [];

	NTMI.mkmix.skip = SkipJack({
		var oscarExists = NTMI.oscar.oscar.notNil;
		var now = Main.elapsedTime;

		if (NTMI.oscar.oscar.notNil and: NTMI.mkmix.oscBut.notNil) {
			// oscar/xflux status:
			NTMI.mkmix.oscBut.value_(NTMI.oscar.oscar.hasJoined);
			NTMI.mkmix.peersV.string = NTMI.oscar.oscar.peers.cs;
			NTMI.mkmix.xsendBut.value_(NTMI.xflux.sends);
			NTMI.mkmix.xsendSl.value_(NTMI.xflux.zoomSend ? 1);
			NTMI.mkmix.xlistenBut.value_(NTMI.xflux.listens);
			NTMI.mkmix.xlistenSl.value_(NTMI.xflux.zoomListen ? 1);
		};

		NTMI.mkmix.mktls = MKtl.all.skeys.select(_ != \xflux).collect(MKtl(_));

		// only set visible if changed
		if (NTMI.mkmix.mktls != NTMI.mkmix.prevMKtls) {
			NTMI.mkmix.lines.do { |line, i|
				var show = NTMI.mkmix.mktls[i].notNil;
				line.do(_.visible_(show));
			};
		};
		NTMI.mkmix.prevMKtls = NTMI.mkmix.mktls;
		NTMI.mkmix.numMKtls = NTMI.mkmix.mktls.size;

		///// then update only visibles
		NTMI.mkmix.lines.keep(NTMI.mkmix.mktls.size).do { |line, i|
			var mk = NTMI.mkmix.mktls[i];
			var name = mk.name, mkdict = NTMI.q.at(name);
			var isDirect = mk.desc.protocol != \xflux;

			var infMode  = mkdict.influxMode;
			var infModeIndex = NTMI.mkmix.influxModes.indexOf(infMode);
			line[0].string = mk.desc.protocol;


			line[1].value = mk.hasDevice;
			line[1].visible = isDirect;
			line[2].visible = isDirect;

			line[3].object = mk;
			if (now - mk.lastUpdateTime < 0.5) {
				line[3].background_(NTMI.mkmix.colors.choose);
			} {
				line[3].background_(Color.green);
			};

			line[4].enabled_(isDirect);
			line[4].value = infModeIndex;
			line[5].value = mkdict.zoom;
		};

	}, 0.2, { w.isClosed }, \mkmix);

	w
});
