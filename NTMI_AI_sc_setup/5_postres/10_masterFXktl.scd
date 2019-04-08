// // ctl master FX via (Korg Nanoktl) Midi Fader box
//
// /*
// q.mFX.pxChain.proxy.controlKeys.sort;
// q.mFX.pxChain.proxy.controlKeys;
//
// a = q.mFX.pxChain.slotsInUse.choose;
// q.fx[a].def.argNames.drop(1);
//
// press reset
//
// */
// (
// q.mfx = q.mfx?();
//
// q.mfx.slot = q.mFX.pxChain.slotsInUse.asArray @@ 1;
// q.midi.ktl.elementAt(\bt, 1, 0).elements.do{|el, k|
// 	//		el.value.dump;
// 	var ndef2 = q.ndefs[k];
// 	el.action = {
// 		k.postcln;
// 		if(el.value.postln > 0) {
// 			q.mfx.slot = q.mFX.pxChain.slotsInUse.asArray.clipAt(k).postln;
//
// 		};
// 	}
// };
//
//
// 9.do{|j|
// 	q.midi.ktl.elementAt(\sl, 1, j).action = {|sl|
// 		var key = 	q.fx[q.mfx.slot].def.argNames.drop(1).wrapAt(j);
// 		[key, sl.value].postln;
// 		q.mFX.pxChain.proxy.setUni(key, sl.value);
// 	}
// };
//
// 9.do{|j|
// 	q.midi.ktl.elementAt(\kn, 1, j).action = {|sl|
// 		var key = q.mFX.pxChain.proxy.controlKeys.sort.select{|k| k.asString.beginsWith("wet") }[j];
// 		q.mFX.pxChain.proxy.set(key, sl.value);
// 	}
// };
// )