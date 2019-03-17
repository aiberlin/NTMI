q.makeGui.xosc = {
	q.closeGuis ("xosc");
	q.guiXOSC = x.gui;

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
