q.pxmix = NdefMixer(s, 6);
q.pxmix.skipjack.dt = 0.5;
q.pxmix.moveTo(5, 5);
ProxyMeter.addMixer(q.pxmix);
// s.scope(q.numChans).window.bounds_(Rect(00, 1000, 261, 250));

q.liveInput.gui;

q.guiMaFX = q.mFX.gui('ma master', 40);
q.guiMaFX.moveTo(790, 1200);


////// entangled GUI and logic:
// q.inphluxGui - needs separation of logic from attachButtons
// presetWins?
/// "3_4wins.scd" <-this could load later
// "ndef-menu-choice.scd" <- this too?
