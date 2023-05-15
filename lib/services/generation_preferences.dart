class GenerationPreferences {
  late final List selectedModels;
  late final List selectedSamplers;

  void init(modelsAmount, samplersAmount) {
    selectedModels = List.generate(modelsAmount, (_) => true);
    selectedSamplers = List.generate(samplersAmount, (_) => true);
  }

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

  bool isModelEnabled(n, txtToImage) {
    if ((n < 0) || (n >= txtToImage.allmodels().length)) {
      return false;
    } else {
      return selectedModels[n];
    }
  }

  void toggleModel(n, txtToImage) {
    if ((n < 0) || (n >= txtToImage.allmodels().length)) return;
    selectedModels[n] = !selectedModels[n];
  }

  bool isSamplerEnabled(s, txtToImage) {
    if ((s < 0) || (s >= txtToImage.allsamplers().length)) return false;
    return selectedSamplers[s];
  }

  void toggleSampler(s, txtToImage) {
    if ((s < 0) || (s >= txtToImage.allsamplers().length)) return;
    selectedSamplers[s] = !selectedSamplers[s];
  }
}
