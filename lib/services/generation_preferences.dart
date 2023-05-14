class GenerationPreferences {
  bool _randomSeed = false;
  bool getRandomSeed() => _randomSeed;
  void setRandomSeed(v) {
    _randomSeed = v;
  }

  bool _upscale = false;
  bool getUpscale() => _upscale;
  void setUpscale(n) {
    _upscale = n;
  }

  double cfgSliderValue = 7;
  void setCfgSliderValue(v) => cfgSliderValue = v;

  double stepSliderValue = 35;
  void setStepSliderValue(v) => stepSliderValue = v;

  double cfgSliderEValue = 7;
  void setCfgSliderEValue(v) => cfgSliderEValue = v;

  double stepSliderEValue = 35;
  void setStepSliderEValue(v) => stepSliderEValue = v;

  final models = [
    "elldreths-vivid-mix.safetensors [342d9d26]", //#shiny
    "deliberate_v2.safetensors [10ec4b29]", // #realistic #errorprone
    "dreamshaper_5BakedVae.safetensors [a3fbf318]", // #art b&w
    "revAnimated_v122.safetensors [3f4fefd9]", // #plastic
    "lyriel_v15.safetensors [65d547c5]", // #jesus
    "Realistic_Vision_V2.0.safetensors [79587710]",
    "timeless-1.0.ckpt [7c4971d4]",
    "portrait+1.0.safetensors [1400e684]",
    "openjourney_V4.ckpt [ca2f377f]",
    "theallys-mix-ii-churned.safetensors [5d9225a4]",
    "analog-diffusion-1.0.ckpt [9ca13f02]",
  ];

  var selectedModels = [
    true,
    false,
    false,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  bool isModelEnabled(n) {
    if ((n < 0) || (n >= models.length)) {
      return false;
    } else {
      return selectedModels[n];
    }
  }

  void toggleModel(n) {
    if ((n < 0) || (n >= models.length)) return;
    selectedModels[n] = !selectedModels[n];
  }

  final samplers = [
    "DPM++ 2M Karras",
    "Euler",
    "Euler a",
    "Heun",
  ];

  final selectedSamplers = [
    true,
    false,
    true,
    true,
  ];

  bool isSamplerEnabled(s) {
    if ((s < 0) || (s >= samplers.length)) return false;
    return selectedSamplers[s];
  }

  void toggleSampler(s) {
    if ((s < 0) || (s >= samplers.length)) return;
    selectedSamplers[s] = !selectedSamplers[s];
  }
}
