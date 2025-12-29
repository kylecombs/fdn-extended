/*(
SynthDef(\fdnWindExtended, {
	arg in, out = 0, mix = 0.5, feedback = 0.85,
	    modRate = 0.1, modDepth = 0.002,
	    brightness = 0.6, density = 0.7;

	var sig, dry, wet, delays;
	var delayTimes, mods;
	var numDelays = 8;

	// prime-ish delay times - irregular spacing creates complex modes
	delayTimes = [0.0197, 0.0233, 0.0291, 0.0347, 0.0419, 0.0487, 0.0557, 0.0631];

	// slow, independent modulation on each delay
	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	delays = LocalIn.ar(numDelays);

	// inject input across taps
	delays = delays + (dry * ([0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05] * density));

	// the delays with modulated times
	delays = numDelays.collect { |i|
		DelayC.ar(delays[i], 0.1, (delayTimes[i] + mods[i]).clip(0.001, 0.1))
	};

	// householder-style feedback matrix
	// simpler and actually works in SC
	delays = delays.collect { |tap, i|
		var others = delays.sum - tap;
		(tap * -0.75) + (others * (0.25))
	};

	// per-tap filtering for "air column" character
	delays = delays.collect { |tap, i|
		var freq = (800 + (i * 400)) * brightness;
		var rq = 0.3 + (i * 0.1);
		BLowPass.ar(tap, freq, rq)
	};

	// subtle nonlinearity - overblown edge
	delays = delays.collect { |tap|
		(tap * 1.5).tanh * 0.8
	};

	LocalOut.ar(delays * feedback);

	// stereo spread
	wet = Splay.ar(delays, spread: 0.8, center: 0.0);

	// breath noise
	wet = wet + (PinkNoise.ar(0.008) * Amplitude.kr(dry, 0.01, 0.1));

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)*/

// Version 2 with dynamic amplitude response
(
SynthDef(\fdnWindExtended, {
	arg in, out = 0, mix = 0.5,
	    feedbackBase = 0.5, feedbackMod = 0.4,
	    modRate = 0.1, modDepth = 0.002,
	    brightnessBase = 0.25, brightnessMod = 0.6,
	    density = 0.7,
	    attackTime = 0.01, releaseTime = 0.3;

	var sig, dry, wet, delays;
	var delayTimes, mods;
	var numDelays = 8;
	var amp, feedbackAmount, internalAmp, brightness;

	delayTimes = [0.0197, 0.0233, 0.0291, 0.0347, 0.0419, 0.0487, 0.0557, 0.0631];

	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	amp = Amplitude.kr(dry, attackTime, releaseTime);

	feedbackAmount = feedbackBase + (feedbackMod * amp);
	brightness = brightnessBase + (brightnessMod * amp);

	delays = LocalIn.ar(numDelays);

	internalAmp = Amplitude.kr(delays.sum, 0.01, 0.1);
	feedbackAmount = feedbackAmount * (1 - (internalAmp * 0.5)).clip(0.3, 1);

	delays = delays + (dry * ([0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05] * density));

	delays = numDelays.collect { |i|
		DelayC.ar(delays[i], 0.1, (delayTimes[i] + mods[i]).clip(0.001, 0.1))
	};

	delays = delays.collect { |tap, i|
		var others = delays.sum - tap;
		(tap * -0.75) + (others * 0.25)
	};

	// split the difference: 250-1450 Hz base range
	delays = delays.collect { |tap, i|
		var baseFreq = 250 + (i * 150);
		var freq = baseFreq + (baseFreq * 1.5 * brightness);
		var rq = 0.6 - (brightness * 0.25);
		BLowPass.ar(tap, freq.clip(100, 6000), rq.clip(0.15, 1))
	};

	delays = delays.collect { |tap|
		var drive = 1.1 + (amp * 1.0);
		(tap * drive).tanh * 0.85
	};

	LocalOut.ar(delays * feedbackAmount);

	wet = Splay.ar(delays, spread: 0.8, center: 0.0);
	wet = wet + (PinkNoise.ar(0.006) * amp);

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)

// Version 3 variable delay times
(
SynthDef(\fdnWindExtended, {
	arg in, out = 0, mix = 0.5,
	    feedbackBase = 0.5, feedbackMod = 0.4,
	    modRate = 0.1, modDepth = 0.002,
	    brightnessBase = 0.25, brightnessMod = 0.6,
	    density = 0.7,
	    attackTime = 0.01, releaseTime = 0.3,
	    delayScale = 1.0; // scale all delay times

	var sig, dry, wet, delays;
	var delayTimes, mods;
	var numDelays = 8;
	var amp, feedbackAmount, internalAmp, brightness;

	// swap these out to experiment
	// primes
	// delayTimes = [17, 23, 29, 37, 43, 53, 61, 71] / 1000;

	// golden ratio
	// delayTimes = Array.geom(8, 0.017, 1.618.pow(1/4));

	// original
	// delayTimes = [0.0197, 0.0233, 0.0291, 0.0347, 0.0419, 0.0487, 0.0557, 0.0631];

	// room modes
	// delayTimes = [1, 1.19, 1.41, 1.68, 2.0, 2.38, 2.83, 3.36] * 0.02;

	// tighter clustering (higher resonance)
	// delayTimes = [0.012, 0.014, 0.016, 0.019, 0.022, 0.025, 0.029, 0.033];

	// wider spread (deeper, more diffuse)
	// delayTimes = [0.029, 0.043, 0.059, 0.079, 0.101, 0.127, 0.157, 0.191];

	// CLARINET-LIKE (closed tube, ~60cm, odd harmonics)
	// fundamental ~143 Hz
	// delayTimes = [1, 3, 5, 7, 9, 11, 13, 15] * 0.007;

	// DIDGERIDOO (long closed tube, ~1.5m)
	// fundamental ~57 Hz, rich in close partials
	// delayTimes = [1, 3, 5, 7, 9, 11, 13, 15] * 0.0175;

	// BASS CLARINET register (~1.2m)
	// delayTimes = [1, 3, 5, 7, 9, 11, 13, 15] * 0.014;

	// CONICAL BORE (saxophone, oboe - all harmonics but different weighting)
    // acts more like open tube despite being closed at reed
	// delayTimes = [1, 2, 3, 4, 5, 6, 7, 8] * 0.008;

	// HUMAN VOCAL TRACT (formants, ~17cm)
	// not harmonic - based on resonant cavities
	// delayTimes = [0.001, 0.0025, 0.004, 0.006, 0.008, 0.011, 0.015, 0.02];

	// MULTIPHONIC - detuned harmonics (extended technique!)
	// slight deviations from integer ratios create beating
	// delayTimes = [1, 1.98, 3.03, 3.95, 5.02, 5.97, 7.04, 7.98] * 0.006;

	// OVERBLOWN/UNSTABLE - ratios between harmonic series
	// simulates cross-fingering, half-holing
	// delayTimes = [1, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5] * 0.005;

	// BISBIGLIANDO (flute whisper tones)
	// very close times create subtle phase cancellations
	// delayTimes = [1, 1.02, 1.05, 1.08, 1.12, 1.17, 1.23, 1.30] * 0.015;

	// SPLIT TONES (brass cracked partials)
	// two fundamentals at once - near-octave with beating
	// delayTimes = [1, 2.03, 2, 4.05, 4, 6.02, 6, 8.04] * 0.004;

	// SPECTRAL FINGERING (clarinet microtones)
	// partials that don't belong to the same series
	// delayTimes = [1, 2.2, 3.1, 4.7, 5.3, 6.8, 7.4, 9.1] * 0.005;

	// AEOLIAN (wind across opening, unstable vortices)
	// inharmonic, clustered in bands
	delayTimes = [0.012, 0.013, 0.014, 0.028, 0.030, 0.031, 0.055, 0.058];

	// THROAT SINGING (two simultaneous pitches)
	// fundamental plus isolated high partial
	// delayTimes = [1, 1, 6, 6.05, 7, 7.03, 8, 8.02] * 0.012;

	// SUBTONE (saxophone, below normal register)
	// fundamental emphasized, weak upper partials
	// delayTimes = [1, 1.01, 1.02, 3, 5, 7, 9, 11] * 0.02;

	// JET WHISTLE (flute air noise with pitch)
	// very short delays = high resonance, breathy
	// delayTimes = [0.002, 0.0023, 0.0027, 0.0031, 0.0037, 0.0043, 0.0051, 0.006];

	// SHELL/CONCH (irregular cavity)
	// fibonacci-ish spacing, organic
	// delayTimes = [1, 2, 3, 5, 8, 13, 21, 34] * 0.0018;

	// WOLF TONE (cello/viola problematic resonance)
	// two close frequencies that "fight"
	// delayTimes = [1, 1.06, 2, 2.06, 3, 3.06, 4, 4.06] * 0.008;

	// DIFFERENCE TONES (brass multiphonics)
	// creates phantom bass from interference
	// delayTimes = [5, 6, 7, 8, 9, 10, 11, 12] * 0.003;

	// FLAGEOLET/HARMONIC GLISS
	// isolated high partials, wide gaps
	// delayTimes = [4, 5, 6, 7, 8, 9, 10, 11] * 0.002;

	// PREPARED TUBE (objects inside, irregular nodes)
	// breaks up the standing wave pattern
	// delayTimes = [0.017, 0.024, 0.029, 0.041, 0.047, 0.062, 0.071, 0.089];

	// CIRCULAR BREATHING FLUTTER
	// rapid alternation between two states
	// delayTimes = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5] * 0.009;

	// DOUBLE REED INSTABILITY (oboe, bassoon squawk)
	// very tight clustering, almost chorus
	// delayTimes = [1, 1.008, 1.016, 1.024, 1.032, 1.040, 1.048, 1.056] * 0.025;

	delayTimes = delayTimes * delayScale;

	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	amp = Amplitude.kr(dry, attackTime, releaseTime);

	feedbackAmount = feedbackBase + (feedbackMod * amp);
	brightness = brightnessBase + (brightnessMod * amp);

	delays = LocalIn.ar(numDelays);

	internalAmp = Amplitude.kr(delays.sum, 0.01, 0.1);
	feedbackAmount = feedbackAmount * (1 - (internalAmp * 0.5)).clip(0.3, 1);

	delays = delays + (dry * ([0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05] * density));

	delays = numDelays.collect { |i|
		DelayC.ar(delays[i], 0.25, (delayTimes[i] + mods[i]).clip(0.001, 0.25))
	};

	delays = delays.collect { |tap, i|
		var others = delays.sum - tap;
		(tap * -0.75) + (others * 0.25)
	};

	delays = delays.collect { |tap, i|
		var baseFreq = 250 + (i * 150);
		var freq = baseFreq + (baseFreq * 1.5 * brightness);
		var rq = 0.6 - (brightness * 0.25);
		BLowPass.ar(tap, freq.clip(100, 6000), rq.clip(0.15, 1))
	};

	delays = delays.collect { |tap|
		var drive = 1.1 + (amp * 1.0);
		(tap * drive).tanh * 0.85
	};

	LocalOut.ar(delays * feedbackAmount);

	wet = Splay.ar(delays, spread: 0.8, center: 0.0);
	wet = wet + (PinkNoise.ar(0.006) * amp);

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)

// Version 4 with tuned fundamental
(
SynthDef(\fdnWindTuned, {
	arg in, out = 0, mix = 0.5,
	    feedbackBase = 0.6, feedbackMod = 0.4,
	    modRate = 0.1, modDepth = 0.002,
	    brightnessBase = 0.25, brightnessMod = 0.6,
	    density = 0.7,
	    attackTime = 0.01, releaseTime = 0.3,
	    fundamental = 55,
	    technique = 0; // select extended technique

	var sig, dry, wet, delays;
	var delayTimes, mods, ratios;
	var numDelays = 8;
	var amp, feedbackAmount, internalAmp, brightness;

	// extended technique ratio patterns
	ratios = Select.kr(technique, [
		// 0: harmonic series
		[1, 2, 3, 4, 5, 6, 7, 8],
		// 1: odd harmonics (clarinet)
		[1, 3, 5, 7, 9, 11, 13, 15],
		// 2: multiphonic (detuned harmonics)
		[1, 1.98, 3.03, 3.95, 5.02, 5.97, 7.04, 7.98],
		// 3: overblown/unstable
		[1, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5],
		// 4: bisbigliando (whisper tones)
		[1, 1.02, 1.05, 1.08, 1.12, 1.17, 1.23, 1.30],
		// 5: split tones
		[1, 2, 2.03, 4, 4.05, 6, 6.02, 8.04],
		// 6: wolf tone
		[1, 1.06, 2, 2.06, 3, 3.06, 4, 4.06],
		// 7: throat singing
		[1, 1.01, 6, 6.05, 7, 7.03, 8, 8.02],
		// 8: aeolian (inharmonic clusters)
		[1, 1.08, 1.17, 2.33, 2.5, 2.58, 4.58, 4.83],
		// 9: spectral fingering
		[1, 2.2, 3.1, 4.7, 5.3, 6.8, 7.4, 9.1],
		// 10: double reed instability
		[1, 1.008, 1.016, 1.024, 1.032, 1.040, 1.048, 1.056],
		// 11: difference tones
		[5, 6, 7, 8, 9, 10, 11, 12],
		// 12: shell/conch (fibonacci)
		[1, 2, 3, 5, 8, 13, 21, 34] / 5
	]);

	delayTimes = ratios.collect { |r|
		(1 / (fundamental * r)).clip(0.0005, 0.25)
	};

	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	amp = Amplitude.kr(dry, attackTime, releaseTime);

	feedbackAmount = feedbackBase + (feedbackMod * amp);
	brightness = brightnessBase + (brightnessMod * amp);

	delays = LocalIn.ar(numDelays);

	internalAmp = Amplitude.kr(delays.sum, 0.01, 0.1);
	feedbackAmount = feedbackAmount * (1 - (internalAmp * 0.5)).clip(0.3, 1);

	delays = delays + (dry * ([0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05] * density));

	delays = numDelays.collect { |i|
		DelayC.ar(delays[i], 0.25, (delayTimes[i] + mods[i]).clip(0.0005, 0.25))
	};

	delays = delays.collect { |tap, i|
		var others = delays.sum - tap;
		(tap * -0.75) + (others * 0.25)
	};

	delays = delays.collect { |tap, i|
		var baseFreq = 250 + (i * 150);
		var freq = baseFreq + (baseFreq * 1.5 * brightness);
		var rq = 0.6 - (brightness * 0.25);
		BLowPass.ar(tap, freq.clip(100, 6000), rq.clip(0.15, 1))
	};

	delays = delays.collect { |tap|
		var drive = 1.1 + (amp * 1.0);
		(tap * drive).tanh * 0.85
	};

	LocalOut.ar(delays * feedbackAmount);

	wet = Splay.ar(delays, spread: 0.8, center: 0.0);
	wet = wet + (PinkNoise.ar(0.006) * amp);

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)

// Version 5 back to untuned version more resonant
(
SynthDef(\fdnWindExtended, {
	arg in, out = 0, mix = 0.5,
	    feedbackBase = 0.5, feedbackMod = 0.4,
	    modRate = 0.1, modDepth = 0.002,
	    brightnessBase = 0.25, brightnessMod = 0.6,
	    density = 0.7,
	    attackTime = 0.01, releaseTime = 0.3,
	    delayScale = 1.0;

	var sig, dry, wet, delays;
	var delayTimes, mods;
	var numDelays = 8;
	var amp, feedbackAmount, internalAmp, brightness;

	// delayTimes = [0.012, 0.013, 0.014, 0.028, 0.030, 0.031, 0.055, 0.058];

	// MULTIPHONIC - detuned harmonics (extended technique!)
	// slight deviations from integer ratios create beating
	delayTimes = [1, 1.98, 3.03, 3.95, 5.02, 5.97, 7.04, 7.98] * 0.006;

	// OVERBLOWN/UNSTABLE - ratios between harmonic series
	// simulates cross-fingering, half-holing
	// delayTimes = [1, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5] * 0.005;

	// SPECTRAL FINGERING (clarinet microtones)
	// partials that don't belong to the same series
	// delayTimes = [1, 2.2, 3.1, 4.7, 5.3, 6.8, 7.4, 9.1] * 0.005;

	delayTimes = delayTimes * delayScale;

	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	amp = Amplitude.kr(dry, attackTime, releaseTime);

	// scale amp more aggressively so feedbackMod is more noticeable
	// amp often sits low, so boost its influence
	feedbackAmount = feedbackBase + (feedbackMod * amp * 3).clip(0, 0.45);

	brightness = brightnessBase + (brightnessMod * amp);

	delays = LocalIn.ar(numDelays);

	// gentler internal limiting - only tames runaway, not normal operation
	internalAmp = Amplitude.kr(delays.sum, 0.05, 0.2);
	feedbackAmount = feedbackAmount * (1 - (internalAmp * 0.8)).clip(0.6, 1);

	delays = delays + (dry * ([0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05] * density));

	delays = numDelays.collect { |i|
		DelayC.ar(delays[i], 0.25, (delayTimes[i] + mods[i]).clip(0.001, 0.25))
	};

	delays = delays.collect { |tap, i|
		var others = delays.sum - tap;
		(tap * -0.75) + (others * 0.25)
	};

	// less aggressive filtering - was eating too much energy
	delays = delays.collect { |tap, i|
		var baseFreq = 250 + (i * 180);
		var freq = baseFreq + (baseFreq * 1.2 * brightness);
		var rq = 0.7 - (brightness * 0.2);
		BLowPass.ar(tap, freq.clip(150, 7000), rq.clip(0.2, 1))
	};

	// softer saturation - less energy loss
	delays = delays.collect { |tap|
		var drive = 1.05 + (amp * 0.7);
		(tap * drive).tanh * 0.6
	};

	LocalOut.ar(delays * feedbackAmount);

	wet = Splay.ar(delays, spread: 0.8, center: 0.0);
	wet = wet + (PinkNoise.ar(0.006) * amp);

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)

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

~fdn = Synth(\fdnWindTuned, [\in, 10, \fundamental, 55, \technique, 2], addAction: \addToTail);

// shift the resonance
~fdn.set(\fundamental, 82.4); // E2
~fdn.set(\fundamental, 73.4); // D2
~fdn.set(\fundamental, 110);  // A2

// change partial structure
~fdn.set(\technique, 0); // harmonic
~fdn.set(\technique, 1); // odd only (hollower)
~fdn.set(\technique, 2); // multiphonic
~fdn.set(\technique, 9); // spectral fingering

// or use midi notes
~fdn.set(\fundamental, 45.midicps); // A1

~fdn = Synth(\fdnWindExtended, [\in, 10, \feedbackBase, 0.3, \feedbackMod, 0.6, \brightnessBase, 0.6, \brightnessMod, 0.7, \modRate, 0.03, \mix, 0.5], addAction: \addToTail);

~fdn.set(\feedbackMod, 0.6);
~fdn.set(\feedbackBase, 0.5);
~fdn.set(\delayScale, 0.5);
~fdn.set(\mix, 1.0);