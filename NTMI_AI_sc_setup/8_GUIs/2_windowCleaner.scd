// do the windows positions
/*
Window.getAll.postcs;
*/
Window.setAll(
	[ [ "NdefMixer_p", Rect(5.0, 5.0, 684.0, 165.0) ], [ "Stethoscope", Rect(0.0, 755.0, 264.0, 250.0) ], [ "Influx anonIB", Rect(262.0, 763.0, 346.0, 242.0) ], [ "InfluxIOWGui_anon", Rect(1364.0, 71.0, 284.0, 934.0) ], [ "basic_presets", Rect(3.0, 282.0, 487.0, 450.0) ], [ "xosc", Rect(771.0, -2.0, 910.0, 380.0) ], [ "The 4 Ndefs", Rect(529.0, 205.0, 400.0, 800.0) ], [ "ma master", Rect(907.0, 223.0, 480.0, 782.0) ] ]
);


// // tweak q.guiXOSC to display correct stuff only
q.guiXOSC.views[(0..8)+18].do{|v| v.view.visible_(false)};     // unused Digi ins
q.guiXOSC.views[(0..8)+18+8+8].do{|v| v.view.visible_(false)}; // unused LEDS
q.guiXOSC.views.keep(-16).do{|v| v.view.visible_(false)};      // unused Comparator Buttons
                                                               // switch off unused analog sliders!

///////////// should work but does not?
/*
q.guiXOSC.views[(11..14)].do(_.snapback = true);
*/


/// hack in led displays:
// orig
// q.guiXOSC.views[27 + (0..15)].do { |elvw, i|
// 	elvw.view.view.drawFunc = { |vw|
// 		var value = elvw.element.value;
// 		var color = Color.hsv(value, 1, 1, 1);
// 		vw.background_(color);
// 	};
// };

q.guiXOSC.views[27 + (0..3)].do { |elvw, i|
	var mappe = ItemsSpec( [Color.grey, Color.green] );
	elvw.view.view.drawFunc = { |vw|
		var value = elvw.element.value;
		var color = mappe.map(value).postcs;
		vw.background_(color);
	};
};

q.guiXOSC.views[27 + [4]].do { |elvw, i|
	var mappe = ItemsSpec( [Color.new255(251, 145, 167), Color.green] );
	elvw.view.view.drawFunc = { |vw|
		var value = elvw.element.value;
		var color = mappe.map(value).postcs;
		vw.background_(color);
	};
};

q.guiXOSC.views[27 + (5..7)].do { |elvw, i|
	var mappe = ItemsSpec( q.presetCols );
	elvw.view.view.drawFunc = { |vw|
		var value = elvw.element.value;
		var color = mappe.map(value).postcs;
		vw.background_(color);
	};
};

/*

// send single hue value:

x.elAt(\led, 0).value_(0.333); // green
x.elAt(\led, 0).value_(0.5);
x.elAt(\led, 0).value_(0.666); // blue

x.elAt(\led).value_(0.0!16);
x.elAt(\led).value_(0.1!16);
x.elAt(\led).value_( { 0.5 }.dup(16))
x.elAt(\led).value_( { 0.999 }.dup(16))
x.elAt(\led).value_( { 1.0.rand }.dup(16))
*/

// q.guiXOSC.labelView.drawFunc.dump;
// q.guiXOSC.views[10].view.states.dump
// q.guiXOSC.views[10].view.states.last.first
// q.guiXOSC.views[[0,2,3,4]+10].do{|v| v.view.visible_(true)}
// q.guiXOSC.views[[0,1,2,3]+10].do{|v| v.view.states.do{|st| st[0] = "ew"} }
// q.guiXOSC.parent.refresh
// q.guiXOSC.refresh
//
// q.guiXOSC.views[14].view.background_(Color.red);
// q.guiXOSC.views[14].view.dump; // touch mode switch
// q.guiXOSC.views[[15, 16]] ; // preset swzs.