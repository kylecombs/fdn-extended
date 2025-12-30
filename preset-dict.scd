(
// DELAY TIME DICTIONARIES
~delayPresets = (
	// standard techniques
	harmonic:       (ratios: [1, 2, 3, 4, 5, 6, 7, 8], base: 0.006),
	oddHarmonics:   (ratios: [1, 3, 5, 7, 9, 11, 13, 15], base: 0.007),
	multiphonic:    (ratios: [1, 1.98, 3.03, 3.95, 5.02, 5.97, 7.04, 7.98], base: 0.006),
	overblown:      (ratios: [1, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5], base: 0.005),

	// extended techniques
	bisbigliando:   (ratios: [1, 1.02, 1.05, 1.08, 1.12, 1.17, 1.23, 1.30], base: 0.015),
	splitTones:     (ratios: [1, 2, 2.03, 4, 4.05, 6, 6.02, 8.04], base: 0.004),
	spectralFinger: (ratios: [1, 2.2, 3.1, 4.7, 5.3, 6.8, 7.4, 9.1], base: 0.005),
	wolfTone:       (ratios: [1, 1.06, 2, 2.06, 3, 3.06, 4, 4.06], base: 0.008),
	throatSinging:  (ratios: [1, 1.01, 6, 6.05, 7, 7.03, 8, 8.02], base: 0.012),
	doubleReed:     (ratios: [1, 1.008, 1.016, 1.024, 1.032, 1.040, 1.048, 1.056], base: 0.025),

	// acoustic models
	aeolian:        (ratios: [1, 1.08, 1.17, 2.33, 2.5, 2.58, 4.58, 4.83], base: 0.012),
	shellConch:     (ratios: [1, 2, 3, 5, 8, 13, 21, 34] / 5, base: 0.009),
	subtone:        (ratios: [1, 1.01, 1.02 , 3, 5, 7, 9, 11], base: 0.02),
	jetWhistle:     (ratios: [1, 1.15, 1.35, 1.55, 1.85, 2.15, 2.55, 3], base: 0.002),
	differenceTone: (ratios: [5, 6, 7, 8, 9, 10, 11, 12], base: 0.003),

	// spatial/diffuse
	primes:         (ratios: [17, 23, 29, 37, 43, 53, 61, 71] / 17, base: 0.017),
	goldenRatio:    (ratios: Array.geom(8, 1, 1.618.pow(1/4)), base: 0.017),
	roomModes:      (ratios: [1, 1.19, 1.41, 1.68, 2.0, 2.38, 2.83, 3.36], base: 0.02)
);

// COMB RATIO DICTIONARIES
~combPresets = (
	// harmonic structures
	oddHarmonics:   [1, 3, 5, 7],
	allHarmonics:   [1, 2, 3, 4],
	highPartials:   [4, 5, 6, 7],
	wideHarmonics:  [1, 3, 7, 11],

	// detuned/beating
	detuned:        [1, 2.98, 5.03, 6.97],
	slightBeat:     [1, 1.01, 1.02, 1.03],
	wideBeat:       [1, 1.06, 1.12, 1.18],

	// inharmonic
	metallic:       [1, 2.4, 3.75, 5.9],
	bell:           [1, 2.2, 3.6, 5.1],
	gamelan:        [1, 1.52, 2.08, 2.89],

	// extended technique specific
	multiphonic:    [1, 2.03, 4.97, 7.02],
	throatSing:     [1, 6, 7, 8],
	whistle:        [5, 6, 7, 8],
	subharmonic:    [0.5, 1, 1.5, 2]
);
)