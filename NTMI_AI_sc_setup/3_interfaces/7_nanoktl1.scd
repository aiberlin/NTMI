/*
// using q.ndefs as list of the 8 ndefs to control from nano scene 1

// turn posting on and off;
q.midi.slidas.do { |el| el.action.enable(\post); };
q.midi.botButz.do { |el| el.action.enable(\post); };
q.midi.topButz.do { |el| el.action.enable(\post); };

q.midi.slidas.do { |el| el.action.disable(\post); };
q.midi.botButz.do { |el| el.action.disable(\post); };
q.midi.topButz.do { |el| el.action.disable(\post); };

MKtl.find(\midi);
MIDIFunc.trace(true);
MIDIFunc.trace(false);

// MKtlDesc.postLoadable;

!! conflict with slider 1, Scene 3
should be CC 85, not 2
*/

q = q ? ();
q.midi = ();
q.active = q.active ? ();
fork {
	0.2.wait;

	q.midi.ktl = MKtl('nanoKtl', "korg-nanokontrol");

	//q.midi.ktl.desc.openFile
	/*
	q.midi.ktl.gui;
	q.midi.ktl.elementsDict.printAll;\;
	q.midi.ktl.trace(true);
	q.midi.ktl.trace(false);

	q.active.midi = q.active.midi ?? {Set.new};
	if (q.ndefs.notNil) { q.active.midi.add(q.ndefs.choose) };
	*/
	0.2.wait;

	//q.active.midi = [\moogSing, \etude, \dog, \frya].collect{ |key| Ndef(key) };
	//q.active.nano = Ndef(\moogSing);

	0.2.wait;

	// switch bank of 8 sliders: << is 1-8, >> is 9 - 16

	q.slOffset = 0;
	q.midi.ktl.elAt(\tr, \rew).action = { q.slOffset = 0 };
	q.midi.ktl.elAt(\tr, \fwd).action = { q.slOffset = 8 };



	// select one Ndef to be in the active = attached sliders
	(
		8.do{|j|
			q.midi.ktl.elementAt(\bt, 0, 0, j).action = {|sl|  q.active.nano = q.ndefs.wrapAt(j).postln };
		};

		q.midi.ktl.elementAt(\bt, 0, 1).elements.do{|el, k|
			//		el.value.dump;
			var ndef2 = q.ndefs[k];
			el.action = {
				if(el.value.postln > 0){ "in".postln;
					if( ndef2.monitor.isPlaying ){
						["stop", ndef2.key, k].postln;
						ndef2.stop(1)
					}{
						["play", ndef2.key, k].postln;
						ndef2.play;
					}
				};
			}
		};


	);

	({
		// q.active.midi.do{|ndef, i|
		var i = 0;
		var sceneSlidas = q.midi.ktl.elementAt(\sl, i).elements.keep(8);


		q.ndefs.keep(8).do{|ndef2, j|

			q.midi.ktl.elementAt(\kn, i, j).action = {|sl| ndef2.vol_(sl.value); };



			sceneSlidas.do { |sl, i|
				sl.action_( MFunc());

				//	sl.action.add(\post, { |el|	[el.name,el.value].round(0.001).postln	});

				sl.action.add(\setNdefs, { |el|
					var ndef = q.active.nano;
					var param = ndef.controlKeys[i + q.slOffset ];
					var paramValue = sl.value;
					if (param.notNil) {
						// [param, paramValue].postln;
						ndef.setUni(param, paramValue);
					};
				});
			};
		}
	}.value;
	);

	Spec.add(\mastaVol, [s.volume.min, s.volume.max, \db]); // master volum spec
	q.midi.ktl.elAt(\sl, 0, 8).action = { |sl| s.volume.volume = \mastaVol.asSpec.map(sl.value) }; /// master volum slider setting

	"nanoKontrol2 midi setup done.".postln;

};


/*
q.midi.ktl.elements[2][0][0];// buttons
q.midi.ktl.elements['button'], i).elements;
q.midi.ktl.elementAt(\sl, 2).elements;
q.midi.ktl.elementAt(\bt, 2, 0, 0)
*/