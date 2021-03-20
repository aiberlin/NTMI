/////// connecting the touchOSC smartphone app to NTMI:
// layout simple is only used as a starter example;
// one can and should make a better fitting layout with the TouchOSCEditor.app!


/****** SETUP INSTRUCTIONS: ******

0. make sure the smartphone with touchosc
and the computer with SC are in the same network

On the computer:
1. find its IP address
// on macOS:
// look in System Prefs/Network/WiFi,
// or in Terminal with ifconfig, find lines with "inet " and IP4 pattern xxx.xxx.xxx.xxx
// or in SC, select those lines:
unixCmdGetStdOutLines("ifconfig").select(_.contains("inet ")).printcsAll; "";
// -> set ~myLaptopIP below to that number!

On the smartphone, in touchOSC app, go to Settings, OSC, CONNECTIONS:
* set OSC host IP address to the laptop's IP from above
--- (e.g. 192.168.178.23)
* set OSC port number to NetAddr.langPort, i.e. 57120 !
* switch Layout to 'Simple',
* in Options,
-- turn accelerometer on, and touch and ping off
* DONE.

On the computer, in SC:
* check if any OSC is coming in from touchOSC, and note the sending address
OSCFunc.trace(true, true);
OSCFunc.trace(false);
// * if nothing, check again that touchosc sends to NetAddr.langPort.

/*
// Do we need real calibration?
// on my iphone 6, this is good enough:
// lying flat on table: [ 0.503, 0.499, 0.335 ]
// 45 degrees up:       [ 0.497, 0.384, 0.382 ]
// head fully up:       [ 0.501, 0.33, 0.501 ]
~tos2.elAt(\accel).value.round(0.001);
*/

*********/
// set earlier in setup file, or save here:
~myPhoneIP = ~myPhoneIP ? "192.168.178.104"; // adc home
// ~myPhoneIP = "192.168.8.232";  // adc studio

// update Modality if needed:
/*
Quark("Modality-toolkit").update; // to get current
*/

// clear old versions, and reload new ones
// ~to12desc = MKtlDesc.loadDescs("touchosc-simple1_2")[0];
// // FIX DESC TO USE NetAddr.langPort as address touch sends to:
// ~to12desc.fullDesc.netAddrInfo.recvPort = NetAddr.langPort;

~tos2.free; ~tos2 = MKtl(\tosc12, "touchosc-simple1_2");


// set the address to the one you see in the trace:
~tos2.device.updateSrcDstAddr(~myPhoneIP);

/*****
//// TEST: make gui for ~tos2
~tos2.gui;
~tos2.device.dump;
~tos2.trace

// -> WHEN YOU MOVE THE PHONE, the accel faders on the Gui (bottom)
// -> WHEN YOU MOVE A SLIDER, the matching slider on the Gui should move
*****/


////// prepare touchOSC-simple1 for basic NTMI
// label elements so the GUI says what they will do,
// and set their actions accordingly:
// set top xfader to control master volume
~tos2.elAt(\xfader).elemDesc.put(\label, \mainVol);
~tos2.elAt(\xfader).action = { |sl|
	MFdef(\mainVol).value(sl.value);
};

// set 4 faders on page 1 to control slot volumes
~tos2.elAt(\sl).do { |el, i|
	el.elemDesc.put(\label, ("vol_" ++ (i+1)).asSymbol);
};
~tos2.elAt(\sl).do { |el, i|
	el.action = { |el|
		q.slots.actives[i].vol = el.value.squared;
	};
};

// set 4 buttons on page 1 to play/stop the 4 slots
~tos2.elAt(\bt).do { |el, i|
	el.elemDesc.put(\label, ("play_" ++ (i+1)).asSymbol);
};

~tos2.elAt(\bt).do { |el, i|
	el.action = { |el|
		~tos2.elAt(\bt2, i).value = el.value;
		if (el.value > 0) {
			q.slots.playAt(i);

		} {
			q.slots.stopAt(i);
		}
	};
};
// buttons on page 2 synced to page1 toggle on/off:
~tos2.elAt(\bt2).do { |el, i|
	el.elemDesc.put(\label, ("play_" ++ (i+1)).asSymbol);
};

~tos2.elAt(\bt2).do { |el, i|
	el.action = { |el|
		~tos2.elAt(\bt, i).valueAction_(el.value);
	}
};


///////////// ACCELEROMETERS for influx:
/// calibration:
q = q ? ();
q.zero = q.zero ? ();
q.zero.tos2 = [ 0.5, 0.335, 0.5 ].unibi;   // phone head up vertical
q.zero.tos2 = [ 0.5, 0.382, 0.382 ].unibi; // phone head 45 deg up
q.zero.tos2 = [ 0.5, 0.5, 0.335 ].unibi;   // phone flat on table

///// name accel xyz as influx x-y-z
~tos2.elAt(\accel).do { |el, i|
	el.elemDesc.put(\label, ("influx_" ++ "xyz"[i]).asSymbol);
};

// when setting inputs by hand, use coll
~tos2.elAt(\accel).action = { |el|
	var vals = ~tos2.collAt(\accel).value.unibi - q.zero.tos2 * 2;
	vals.round(0.01).postln;
	q.inphlux.set(\x, vals[0], \y, vals[1], \z, vals[2]);
};

// use triple input from coll
// to set influx x y z values in one go:
~tos2.collAt(\accel).action = { |el|
	var vals = el.value.unibi - q.zero.tos2 * 2;
	q.inphlux.set(\x, vals[0], \y, vals[1], \z, vals[2]);
};


// pushbuttons on page 2
// pushbuttons should be momentary on gui - press m key...

// top row sets slot to next preset
~tos2.elAt(\pb)[0..3].do { |el, i|
	el.elemDesc.put(\label, ("pre+" ++ (i+1)).asSymbol);
	el.action = { if (el.isOn) {
		q.pre.stepNdefInf(q.slots.actives[i], 1)
	} }
};

// row 2   sets slot to prev preset
~tos2.elAt(\pb)[4..7].do { |el, i|
	el.elemDesc.put(\label, ("pre-" ++ (i+1)).asSymbol);
	el.action = { if (el.isOn) {
		q.pre.stepNdefInf(q.slots.actives[i], -1)
	} }
};


// row 3 sets slot to next sound func
~tos2.elAt(\pb)[8..11].do { |el, i|
	el.elemDesc.put(\label, ("snd+" ++ (i+1)).asSymbol);
	el.action = { if (el.isOn) {
		q.slots.stepNext(i, 1)
	} }
};

// row 4 sets slot to prev sound func
~tos2.elAt(\pb)[12..15].do { |el, i|
	el.elemDesc.put(\label, ("snd-" ++ (i+1)).asSymbol);
	el.action = { if (el.isOn) {
		q.slots.stepNext(i, -1)
	} }
};

