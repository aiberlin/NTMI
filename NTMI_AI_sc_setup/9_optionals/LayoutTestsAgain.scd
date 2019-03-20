w = Window().front;
w.layout = VLayout(
	HLayout(
		MultiSliderView().elasticMode_(1)
		.minSize_(Size(120, 200)).maxSize_(Size(180, 300)).indexIsHorizontal_(false).value_({ 1.0.rand } ! 17),
		UserView().minSize_(Size(200, 200)).maxSize_(Size(300, 300))
		.background_(Color.red)
	),
	HLayout(
		StaticText().minSize_(Size(120, 120)).maxSize_(Size(180, 300)),
		MultiSliderView(w).minSize_(Size(200, 120)).maxSize_(Size(300, 300))
		.elasticMode_(1).value_({ 1.0.rand } ! 18)
	)
);