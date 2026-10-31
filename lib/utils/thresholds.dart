// Seuils numériques
// CO₂ (ppm) : <800 air frais, <1200 acceptable, <1800 ventiler, au-delà confiné
const co2VeryLow  = 400.0;
const co2Low      = 800.0;
const co2Moderate = 1200.0;
const co2Elevated = 1800.0;
const co2High     = 2500.0;

// Indice VOC Sensirion (100 = moyenne de référence)
const vocVeryLow  = 0.0;
const vocLow      = 100.0;
const vocModerate = 150.0;
const vocElevated = 250.0;
const vocHigh     = 400.0;

// Indice NOx Sensirion (1 = air propre)
const noxVeryLow  = 1.0;
const noxLow      = 20.0;
const noxModerate = 100.0;
const noxElevated = 250.0;
const noxHigh     = 400.0;

// Pression absolue (hPa) à Clermont-Ferrand (~330 m, moyenne ≈ 975 hPa)
const pressureLow      = 960.0;
const pressureNormal   = 985.0;
const pressureHigh     = 995.0;
const pressureVeryHigh = 1005.0;

// Éclairement intérieur (lux)
const luminosityDark      = 20.0;
const luminosityLowLight  = 100.0;
const luminosityNormal    = 500.0;
const luminosityBright    = 1500.0;

// MQ-2 : valeur ADC brute (0-4095), air propre mesuré ≈ 50-80
const gasGood     = 120.0;
const gasModerate = 200.0;
const gasElevated = 350.0;
const gasDanger   = 600.0;

const temperatureLow      = 19.0;
const temperatureNormal   = 25.0;
const temperatureHigh     = 28.0;
const temperatureVeryHigh = 32.0;

const humidityLow      = 30.0;
const humidityNormal   = 60.0;
const humidityHigh     = 70.0;
const humidityVeryHigh = 80.0;
