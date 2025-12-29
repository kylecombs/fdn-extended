// start with defaults
~fdn = Synth(\fdnWindExtended, [\in, 10]);

// apply a delay preset
(
var p = ~delayPresets[\wolfTone];
~fdn.set(\delayRatios, p.ratios, \delayBase, p.base);
)

// apply a comb preset
~fdn.set(\combRatios, ~combPresets[\detuned]);

// combine them
(
var d = ~delayPresets[\throatSinging];
var c = ~combPresets[\throatSing];
~fdn.set(\delayRatios, d.ratios, \delayBase, d.base, \combRatios, c);
)

// tune the combs to a specific pitch
~fdn.set(\combFreq, 73.4); // D2

(
// quick preset function
~setPreset = { |synth, delayName, combName, freq = 110|
	var d = ~delayPresets[delayName];
	var c = ~combPresets[combName];
	synth.set(
		\delayRatios, d.ratios,
		\delayBase, d.base,
		\combRatios, c,
		\combFreq, freq
	);
};
)

// use it
~setPreset.(~fdn, \multiphonic, \detuned, 82.4);
~setPreset.(~fdn, \bisbigliando, \slightBeat, 110);
~setPreset.(~fdn, \aeolian, \metallic, 55);
~setPreset.(~fdn, \aeolian, \slightBeat, 55);
~setPreset.(~fdn, \overblown, \slightBeat, 55);
~setPreset.(~fdn, \spectralFinger, \detuned, 55);

// usage - assuming you have a drone on bus 10
// x = Synth(\fdnWindExtended, [\in, 10, \feedback, 0.88, \brightness, 0.5]);

// or process live input
/*(
SynthDef(\droneSource, { |out = 10|
	Out.ar(out, SoundIn.ar(0));
}).add;
)*/


(
SynthDef(\droneSource, {|out = 10|
	var buf = Buffer.read(s, "/Users/kylecombs/Desktop/Sax Morph/SC_250130_103535.wav");
	Out.ar(out, PlayBuf.ar(2, buf, BufRateScale.kr(buf)));
}).add;
)

(
SynthDef(\droneSource, {|out = 10|
	var buf = Buffer.read(s, "/Users/kylecombs/Desktop/Sax Morph/Alto_sax_multiphonic_F#1_resynth.wav");
	Out.ar(out, PlayBuf.ar(2, buf, BufRateScale.kr(buf) * 2));
}).add;
)

(
SynthDef(\droneSource, {|out = 10|
	var snd = SinOscFB.ar(110, 0.5, SinOsc.kr(0.05));
	Out.ar(out, snd * 0.05);
}).add;
)


~src = Synth(\droneSource);

~fdn = Synth(\fdnWindExtended, [\in, 10, \feedbackBase, 0.3, \feedbackMod, 0.6, \brightnessBase, 0.7, \brightnessMod, 0.7, \modRate, 0.03, \mix, 0.5], addAction: \addToTail);

~fdn.set(\feedbackMod, 0.5);
~fdn.set(\feedbackBase, 0.4);
~fdn.set(\delayScale, 0.5);
~fdn.set(\mix, 0.6);
~fdn.set(\combMix, 0.3);
~fdn.set(\combDecay, 0.3);