/*

// which views have which elements?
g.guiXOSC.views.do { |vw, i| [i, vw.element.name ].postln };

*/

g.makeGui.xosc = { |dict, name = \xosc|
	var simButStart, simButStop;
	g.guiXOSC = MKtl(\xosc).gui;

	// // tweak g.guiXOSC to display correct stuff only
	g.guiXOSC.views[(0..8)+18].do{|v| v.view.visible_(false)};     // hide unused Digi ins
	g.guiXOSC.views[(0..8)+18].do{|v| v.view.visible_(false)};     // hide unused Digi ins

	g.guiXOSC.views[(0..8)+18+8+8].do{|v| v.view.visible_(false)}; // hide unused LEDS
	g.guiXOSC.views.keep(-16).do{|v| v.view.visible_(false)};      // hide unused Comparator Buttons

	g.guiXOSC.views[(43..49)].do{|v| v.view.enabled_(false)};     // dim unused analog ins

	/// hack in led displays:
	// orig
	// g.guiXOSC.views[27 + (0..15)].do { |elvw, i|
	// 	elvw.view.view.drawFunc = { |vw|
	// 		var value = elvw.element.value;
	// 		var color = Color.hsv(value, 1, 1, 1);
	// 		vw.background_(color);
	// 	};
	// };

	g.guiXOSC.views[27 + (0..3)].do { |elvw, i|
		var mappe = ItemsSpec( [Color.grey, Color.green] );
		elvw.view.view.drawFunc = { |vw|
			var value = elvw.element.value;
			var color = mappe.map(value);
			vw.background_(color);
		};
	};

	g.guiXOSC.views[27 + [4]].do { |elvw, i|
		var mappe = ItemsSpec( [Color.new255(251, 145, 167), Color.green] );
		elvw.view.view.drawFunc = { |vw|
			var value = elvw.element.value;
			var color = mappe.map(value);
			vw.background_(color);
		};
	};

	g.guiXOSC.views[27 + (5..7)].do { |elvw, i|
		var mappe = ItemsSpec( q.inph.presetCols );
		elvw.view.view.drawFunc = { |vw|
			var value = elvw.element.value;
			var color = mappe.map(value);
			vw.background_(color);
		};
	}
};

/*

// send single hue value:

MKtl(\xosc).elAt(\led, 0).value_(0.333); // green
MKtl(\xosc).elAt(\led, 0).value_(0.5);
MKtl(\xosc).elAt(\led, 0).value_(0.666); // blue

MKtl(\xosc).elAt(\led).value_(0.0!16);
MKtl(\xosc).elAt(\led).value_(0.1!16);
MKtl(\xosc).elAt(\led).value_( { 0.5 }.dup(16))
MKtl(\xosc).elAt(\led).value_( { 0.999 }.dup(16))
MKtl(\xosc).elAt(\led).value_( { 1.0.rand }.dup(16))
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
