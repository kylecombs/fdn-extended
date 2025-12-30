(
SynthDef(\fdnWindExtended, {
	arg in, out = 0, mix = 0.5,
	    feedbackBase = 0.5, feedbackMod = 0.4,
	    modRate = 0.1, modDepth = 0.002,
	    brightnessBase = 0.25, brightnessMod = 0.6,
	    density = 0.7,
	    attackTime = 0.01, releaseTime = 0.3,
	    delayScale = 1.0,
	    combMix = 0.5, combDecay = 0.3, combFreq = 110, delayRatios = #[1, 1.98, 3.03, 3.95, 5.02, 5.97, 7.04, 7.98], delayBase = 0.006, combRatios = #[1, 3, 5, 7];

	var sig, dry, wet, delays, combed;
	var delayTimes, mods, combTimes;
	var numDelays = 8;
	var amp, feedbackAmount, internalAmp, brightness;

	delayTimes = delayRatios * delayBase * delayScale;
	combTimes = combRatios / combFreq;

	mods = numDelays.collect { |i|
		LFNoise2.kr(modRate * (0.7 + (i * 0.1))) * modDepth
	};

	dry = In.ar(in, 2).sum;

	amp = Amplitude.kr(dry, attackTime, releaseTime);

	feedbackAmount = feedbackBase + (feedbackMod * amp * 2).clip(0, 0.35);
	brightness = brightnessBase + (brightnessMod * amp);

	delays = LocalIn.ar(numDelays);

	internalAmp = Amplitude.kr(delays.sum, 0.05, 0.2);
	feedbackAmount = feedbackAmount * (1 - (internalAmp * 0.7)).clip(0.5, 1);

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
		var freq = baseFreq + (baseFreq * 1.2 * brightness);
		var rq = 0.7 - (brightness * 0.2);
		BLowPass.ar(tap, freq.clip(150, 2000), rq.clip(0.2, 1))
	};

	delays = delays.collect { |tap|
		var drive = 1.05 + (amp * 0.6);
		(tap * drive).tanh * 0.65
	};

	combed = combTimes.collect { |time, i|
		CombL.ar(delays.sum / numDelays, 0.1, time.clip(0.001, 0.1), combDecay)
	};
	combed = combed.sum / combTimes.size;

	delays = delays + (combed * combMix * 0.3);

	LocalOut.ar(delays * feedbackAmount);

	wet = Splay.ar(delays, spread: 0.8, center: 0.0);
	wet = wet + (Splay.ar(combed, spread: 0.6) * combMix);
	// wet = wet + (PinkNoise.ar(0.006) * amp);

	sig = XFade2.ar(dry.dup, wet, mix * 2 - 1);

	Out.ar(out, sig);
}).add;
)