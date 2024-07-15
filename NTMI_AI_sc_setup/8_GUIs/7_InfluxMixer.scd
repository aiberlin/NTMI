NTMI.mkmix = NTMI.mkmix ? ();

Butz('interfaces').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });
Butz('NTMI').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });

WinBounds.addMake(\InfluxMixer, {
	var w = Window(\InfluxMixer, Rect.aboutPoint(NTMI.g.bounds.center, 250, 100)).front;
	var f = Font(Font.defaultMonoFace, 14, true);
	var mktls = MKtl.all.skeys.collect(MKtl(_));
	var numItems = mktls.size + 4; // maybe some are added later
	w.addFlowLayout(2@2, 2@2);
	w.alpha_(NTMI.g.alpha);

	StaticText(w, Rect(0, 0, 500, 20)).font_(f)
	.string_("protocol, status, MKtl('name'), influxMode, influxZoom");

	NTMI.mkmix.influxModes = [\setRel, \setAbs];
	NTMI.mkmix.mktls = mktls;
	NTMI.mkmix.numMKtls = 0;

	// if not there, make dict for mktl and fill w defaults
	mktls.do { |mk, i|
		var mkdict = NTMI.q[mk.name];

		if (mkdict.isNil) {
			"*** % has no NTMI dict - making it now.n".postf(mk);
			NTMI.q.put(mk.name, mkdict = ());
		};
		mkdict.influxMode = mkdict.influxMode ? NTMI.mkmix.influxModes[0];
		mkdict.zoom = mkdict.zoom ? 0.5;
		[mk, mkdict].postln;
	};

	NTMI.mkmix.lines = numItems.collect { |i|
		[
			StaticText(w, Rect(0, 0, 40, 20)).font_(f).string_("prot"),

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

			DragSource(w, Rect(40, 0, 140, 20)).font_(f).background_(Color.grey(1.0))
			.object_(NTMI.mkmix.mktls[i]),

			PopUpMenu(w, Rect(220, 0, 70, 20)).items_([ \setRel, \setAbs])
			.action_({ |pop|
				var mk = NTMI.mkmix.mktls[i];
				// if there is a swth function, call it
				NTMI.at(mk.name)[pop.item.postln].value.postln;
				// if not, always set the mode
				NTMI.at(mk.name).influxMode = pop.item;
			}),

			EZSlider(w, Rect(290, 0, 140, 20), "", [0, 4, \amp], { |sl|
				var mk = NTMI.mkmix.mktls[i];
				NTMI.at(mk.name).zoom = sl.value;
			}, labelWidth: 0, numberWidth: 35)
		]
	};

	NTMI.mkmix.skip.stop;
	NTMI.mkmix.prevMKtls = [];
	NTMI.mkmix.skip = SkipJack({

		NTMI.mkmix.mktls = MKtl.all.skeys.collect(MKtl(_));

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
			var colArr;

			var infMode  = mkdict.influxMode;
			var infModeIndex = NTMI.mkmix.influxModes.indexOf(infMode);
			line[0].string = mk.desc.protocol;
			line[1].value = mk.hasDevice;
			line[3].object = mk;
			line[4].value = infModeIndex;
			line[5].value = mkdict.zoom;
			if (mk.timeSinceLast < 0.5) {
				line[3].background_(Color.hsv(1.0.rand, 0.5, 1, 1))
			} {
				colArr = line[3].background.asArray;
				if (colArr != [1,1,1,1]) {
					colArr = (colArr + [0.02, 0.02, 0.02, 0]).clip(0, 1);
					line[3].background_(Color.fromArray(colArr))
				};
			}
		}
	}, 0.1, { w.isClosed }, \mkmix);
	w
});
