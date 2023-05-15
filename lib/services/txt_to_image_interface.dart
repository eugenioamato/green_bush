abstract class TxtToImageInterface {
  List<String> allmodels();
  List<String> allsamplers();

  void startGeneration(
      int index,
      prompt,
      nprompt,
      model,
      sampler,
      cfg,
      steps,
      seed,
      upscale,
      apiKey,
      apiName,
      apiSessionKey,
      apiSessionName,
      apiGenerationEndpoint,
      apiFetchEndpoint,
      setState,
      repeatIndex);
  void multiSpan(setState, apiKey, apiName, apiSessionKey, apiSessionName,
      apiGenerationEndpoint, apiFetchEndpoint, prompt, nprompt);
}
