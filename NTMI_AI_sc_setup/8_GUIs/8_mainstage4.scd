// mainstage3 rewritten all to responsive Layout with PaneView Quark andLayouts. Maybe get rid of Panes again..
// ver 4: with rec but

g.makeGui.mainStage4 = {
	var p, w, scope, scopeV, modeBut, sliders, zoomTxt, zoomSl, clockTxt, clockBut, fontt;
	fontt = Font("Monaco", 66);

	sliders = { |i|
		[
			// StaticText(p).string_(q.ndefs[i].key)
			// .maxHeight_(50).font_(Font("Monaco", 40)),

			//		EZPopUpMenu(p, 200@50, "*", q.allSoundNames, {|mo| mo.postln}, i),

			PopUpMenu(p, Rect(0, 0, 180, 50)),

			Slider()
			.orientation_(\horizontal)
			.maxHeight_(150)
		]
	} ! 4;

	q.sliders = sliders;



	try{ g.mainstage.close};
	w = Window("NTMI.1",
		Rect.aboutPoint(Window.availableBounds.center, Window.availableBounds.width/2, Window.availableBounds.height/2)
	).front;
	w.bounds = Window.availableBounds;
	g.mainstage = w;
	w.alpha = 0.85;
	/*w.background = (
	'laVulega': Color.magenta(0.9),
	//	'arik': Color.new(1, 0.5, 0),
	'arik': Color.blue(0.9),
	'isakhan': Color.new255(255, 69, 0),
	)[q.me.asSymbol ];*/

	q.presetCols = q.inphlux.getHalo(\randSeeds).size.collect{|i| Color.hsv(i/ q.inphlux.getHalo(\randSeeds).size + 0.0, 1, 1, 1)};

	w.background = q.presetCols @@ q.inphlux.getHalo(\presIndex);

	p = PaneView(w.view, \horizontal, 4, [4,13,2,4], 30, 5, Color.clear);
	p.panes[0] !? {|p|
		p.layout_(VLayout(
			scopeV = View().background_(Color.clear).maxHeight_(300),
			// StaticText(p).string_("mode:").maxHeight_(50),
			modeBut = Button(p).minHeight_(400)
			.states_([
				["move", Color.black, Color.green],
				["touch", Color.black, Color.new255(251, 145, 167)],
			]).font_(fontt)
			.action_({|b|
				x.elementsDict[\inD_4].action[\front] .value(1)
			});
	)) };

	p.panes[1].layout_(
		VLayout(
			*sliders.flat
		)
	);
	p.panes[2].layout_( // zoom slider vert.
		VLayout(
			zoomTxt = StaticText(p)
			.string_("zoom")
			.font_(Font("Monaco", 40))
			,
			zoomSl = Slider().background_(Color.grey(0.8))
		)
	);

	p.panes[3] !? {|p|  // clock
		p.layout_(
			VLayout(
				q.timeText = StaticText(p).string_("clokk")
				.font_(Font("Monaco", 120))
				.minSize_(350@400)
				.background_(Color.red.alpha_(0.2)),

				// gets value from ??
				q.timerButton = Button(p)
				.states_([
					["OSC alive :)", Color.black, Color.green],
					["no OSC :(", Color.white, Color.red],
				])
				//	.minSize_(350@50)
				.fixedHeight_(40)
				.minWidth_(280)
				.font_(Font("Monaco", 15)),


				clockBut = Button(p)
				.states_([
					["reset\nclock", Color.black, Color.green],
				])
				.minHeight_(150)
				.minWidth_(280)
				.font_(Font("Monaco", 40))
				.action_({|b| Tdef(\clocK).reset.play; q.timeText.string = "00:\n00" }),


				Button(p)
				.states_([
					["Rec", Color.black, Color.green],
					["stop Rec", Color.white, Color.red],
				])
				.minHeight_(150)
				.minWidth_(280)
				.font_(Font("Monaco", 40))
				.action_({|b|
					if(b.value.postcln != 0)
					{s.record; "s.rec".postln;}
					{
						s.stopRecording;
						// Platform.recordingsDir.absolutePath.openOS;
						"rec OVER".postln;
					};
				})

			)
		)
	};

	// add functionality
	Stethoscope(s, (q.numChans), view: scopeV);
	// config sliders
	sliders.flop[1].do{|sl, i| sl.action_({ |mv| q.ndefs[i].vol_(mv.value) })};
	// config popupz
	sliders.flop[0].do{|pop, i|
		pop.items_( q.allSoundNames)
		.value_(i)
		.value_(q.allSoundNames.indexOfEqual(q.ndefs[i].key.asString);)
		.allowsReselection_(true)
		.font_(Font("Monaco", 40))
		.background_(Color.grey(0.7))
		.action_({ arg menu; q.choiceNewNdefFunc(*[i, menu.value, menu.item].postln);})
	};



	//@@ set background from where ???
	zoomSl.action_({|e| q.setZoom(e.value)});


	// skippy
	(
		q.mainStageSkippa.stop;
		q.mainStageSkippa = SkipJack({
			defer{
				// update Vols
				sliders.do{ |mv, i|
					var ndef = q.ndefs[i];
					var poppy =  mv[0];
					var slidy = mv[1];

					poppy.background = if (ndef.monitor.isPlaying) {
						Color.grey(0.8)
						//	Color.green.alpha_(0.85)
					} {
						Color.grey(0.4)
					};
					slidy.value = ndef.vol;
					slidy.background = if(q.inphlux.action.activeNames.includes(ndef.key))
					{ Color.green}
					{ Color.grey(0.8)}
				};

				// update modeBut according to mode
				modeBut.value = q.inph.modes.indexOf(q.inph.mode);

				// update q.zoom
				zoomSl.value = q.zoom;

				// update bg - bit expensive?
				q.mainstage.background = q.presetCols @@ q.inphlux.getHalo(\presIndex);

				q.timerButton.value = ((thisThread.seconds - q.lastOSCactivity) > 1).binaryValue;

				if(Tdef(\clocK).isPlaying.not){ Tdef(\clocK).play; }
			}
		});
	);


	Tdef(\clocK, {
		var dt = 1;
		var time =0;
		var timestr;
		inf.do{|i|
			time = time  + dt;
			timestr = (time div: 60).asString.padLeft(2, "0")
			++ ":\n"
			++  (time % 60).asString.padLeft(2, "0");
			q.timeText.string = timestr;
			dt.wait;
		}
	}).clock_(AppClock);
	Tdef(\clocK).play;
	Tdef(\clocK).reset;

};