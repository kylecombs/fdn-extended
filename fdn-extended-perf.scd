// start with defaults
x = Synth(\fdnWindExtended, [\in, 10]);

// apply a delay preset
(
var p = ~delayPresets[\wolfTone];
x.set(\delayRatios, p.ratios, \delayBase, p.base);
)

// apply a comb preset
x.set(\combRatios, ~combPresets[\detuned]);

// combine them
(
var d = ~delayPresets[\throatSinging];
var c = ~combPresets[\throatSing];
x.set(\delayRatios, d.ratios, \delayBase, d.base, \combRatios, c);
)

// tune the combs to a specific pitch
x.set(\combFreq, 73.4); // D2

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

// use it
~setPreset.(x, \multiphonic, \detuned, 82.4);
~setPreset.(x, \bisbigliando, \slightBeat, 110);
~setPreset.(x, \aeolian, \metallic, 55);

// usage - assuming you have a drone on bus 10
// x = Synth(\fdnWindExtended, [\in, 10, \feedback, 0.88, \brightness, 0.5]);

// or process live input
// (
// SynthDef(\droneSource, { |out = 10|
// 	Out.ar(out, SoundIn.ar(0));
// }).add;
// )


(
SynthDef(\droneSource, {|out = 10|
	var buf = Buffer.read(s, "/Users/kylecombs/Desktop/Sax Morph/SC_250130_103535.wav");
	Out.ar(out, PlayBuf.ar(2, buf, BufRateScale.kr(buf)));
}).add;
)

~src = Synth(\droneSource);

~fdn = Synth(\fdnWindExtended, [\in, 10, \feedbackBase, 0.3, \feedbackMod, 0.6, \brightnessBase, 0.6, \brightnessMod, 0.7, \modRate, 0.03, \mix, 0.5], addAction: \addToTail);

~fdn.set(\feedbackMod, 0.6);
~fdn.set(\feedbackBase, 0.5);
~fdn.set(\delayScale, 0.5);
~fdn.set(\mix, 1.0);