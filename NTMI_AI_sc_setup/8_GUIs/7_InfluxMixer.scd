/***
add buttons for NTMI.xflux.sends, listens, verbose

Window.find(\InfluxMixer).bounds
***/
NTMI.mkmix = NTMI.mkmix ? ();

Butz('interfaces').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });
Butz('NTMI').add(\InfluxMixer, { WinBounds.showOrMake(\InfluxMixer) });

// GUI sketch only - todo:
// add matrix mix functions
// and gui-update skipjack

WinBounds.addMake(\influxMatrix, {
	var base = Window.find("InfluxMixer").bounds.postln;
	var leftTop = NTMI.mkmix.lines[0][4].bounds.leftTop.postln;
	var rightBot = NTMI.mkmix.lines.last.last.bounds.rightBottom;
	var bounds = base.copy.moveBy(275, 0)
	.width_(base.width - 270).height_(base.height - 60);

	var w = Window("sources VS slots", bounds).front.alpha_(0.9);
	var gridlines;
	w.layout = GridLayout.rows(
		[ "Slot 1", "Slot 2", "Slot 3", "Slot 4" ].collect { |name|
			StaticText(w, ).string_(name).align_(\center)
		},
		*gridlines = NTMI.mkmix.mktls.collect { |mktl, i|
			4.collect { |j|
				var left = (100 * j), top = (40 * i);
				var mv = MView(1.0.rand, w, Rect(left, top, 100, 30));
				mv.dict.font.size_(20);
				mv.dict.backCol_(Color.white);
				mv.dict.valCol_(Color.black);

				mv.uv.background_(Color.white);
				mv.uv.minSize_(60@20);
				mv.putDict(\myspec, [-2, 2].asSpec);
			}
		}
	).spacing_(2);
	NTMI.mkmix.mvgrid = gridlines;

});


WinBounds.addMake(\InfluxMixer, {
	var mktls = MKtl.all.skeys.collect(MKtl(_));
	var numItems = mktls.size + 4; // maybe some are added later
	var halfWinH = 22 * (numItems + 2) / 2;
	var bounds = Rect.aboutPoint(NTMI.g.bounds.center, 250, halfWinH);
	var w = Window(\InfluxMixer, bounds).front;
	var f = Font(Font.defaultMonoFace, 14, true);
	w.addFlowLayout(2@2, 2@2);
	w.alpha_(NTMI.g.alpha);

	StaticText(w, Rect(0, 0, 500, 20)).font_(f)
	.string_("protocol, status, MKtl('name'), influxMode, influxZoom");

	NTMI.mkmix.startBut = Button(w, 100@30).font_(f)
	.states_([['XFLUX ?'], ['XFLUX ON!', nil, Color.green]])
	.action_({ |bt, mod|
		if (bt.value > 0) {
			NTMI.oscar.makeServer
		} {
			NTMI.oscar.quit;
		}
	});
	NTMI.mkmix.peerBut = Button(w, 80@30).font_(f)
	.states_([['peers ?']])
	.action_({ |bt|
		if (NTMI.oscar.oscar.isNil) {
			"NTMI.oscar.oscar not made yet!".postln;
		} {
			var str = "peers: %".format(NTMI.oscar.oscar.peers);
			var w = Window("NTMI.oscar.oscar.peers",
				Window.find("InfluxMixer").bounds
			).front.alpha_(0.7);
			StaticText(w, w.view.bounds).string_(str)
			.font_(Font(Font.defaultMonoFace, 32));
		}
	});
	NTMI.mkmix.sendBut = Button(w, 80@30).font_(f)
	.states_([['send ?'], ['sending!', nil, Color.green]])
	.action_({ |bt| NTMI.xflux.sends = bt.value > 0 });
	NTMI.mkmix.listenBut = Button(w, 80@30).font_(f)
	.states_([['listen ?'], ['listening!', nil, Color.green]])
	.action_({ |bt| NTMI.xflux.listens = bt.value > 0 });
	NTMI.mkmix.verboseBut = Button(w, 80@30).font_(f)
	.states_([['verbose ?'], ['verbose!', nil, Color.green]])
	.action_({ |bt| NTMI.xflux.verbose = bt.value > 0 });
	NTMI.mkmix.perSec = StaticText(w, 60@30).string_("0/sec").font_(f);


	NTMI.mkmix.matrixBut = Button(w, 80@30).font_(f)
	.states_([['matrix']]);
	NTMI.mkmix.matrixBut.action_({
		WinBounds.showOrMake(\influxMatrix)
	});

	StaticText(w, Rect(0, 0, 80, 20)).font_(f)
	.string_("xfluxZoom");

	NTMI.mkmix.xfluxZoom = EZSlider(w, Rect(0, 0, 300, 30), "xfluxZoom", [0, 1, \amp], { |sl|
		NTMI.xflux.zoom = sl.value;
	}, labelWidth: 0, numberWidth: 35);
	w.view.decorator.nextLine;

	NTMI.mkmix.influxModes = [\setRel, \setAbs];
	NTMI.mkmix.mktls = mktls;
	NTMI.mkmix.numMKtls = 0;

	// if not there, make dict for mktl and fill w defaults
	mktls.do { |mk, i|
		var mkdict = NTMI.q[mk.name];

		if (mkdict.isNil) {
			"*** % has no NTMI dict - making it now.\n\n".postf(mk);
			NTMI.makeMKtlHalo(mk);
		};
	};

	NTMI.mkmix.lines = numItems.collect { |i|
		[
			StaticText(w, Rect(0, 0, 45, 20)).font_(f).string_("prot").align_(\center),

			Button(w, Rect(180, 0, 40, 20))
			.states_([["sim"], ["real!", Color.black, Color.green]])
			.action_({ |bt, mod = 0|
				var mk = NTMI.mkmix.mktls[i];
				if (bt.value > 0 and: mk.hasDevice.not) {
					mk.openDevice
				} {
					if (mod == 0) {
						"hold shift, alt or ctrl to close device!".postln;
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

			DragSource(w, Rect(40, 0, 140, 20)).font_(f).align_(\center)
			.background_(Color.grey(1.0))
			.object_(NTMI.mkmix.mktls[i]),

			PopUpMenu(w, Rect(220, 0, 70, 20)).items_([ \setRel, \setAbs])
			.action_({ |pop|
				var mk = NTMI.mkmix.mktls[i];
				// if there is a switch function, call it
				NTMI.at(mk.name)[pop.item].value(NTMI.at(mk.name));
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

		NTMI.mkmix.startBut.value_(NTMI.oscar.oscar.notNil.binaryValue);
		NTMI.mkmix.sendBut.value_(NTMI.xflux.sends.binaryValue);
		NTMI.mkmix.listenBut.value_(NTMI.xflux.listens.binaryValue);
		NTMI.mkmix.verboseBut.value_(NTMI.xflux.verbose.binaryValue);
		NTMI.mkmix.perSec.string_("%/sec".format(NTMI.inph.callsPerSec));
		NTMI.mkmix.xfluxZoom.value_(NTMI.xflux.zoom);

		if (NTMI.oscar.oscar.notNil) {
			var str = "% peers".format(NTMI.oscar.oscar.peers.size);
			NTMI.mkmix.peerBut.states_([[str]])
		} {
			NTMI.mkmix.peerBut.states_([["¿peers?"]])
		};

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
			try { line[3].string = mk.name };
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
	w;
});
