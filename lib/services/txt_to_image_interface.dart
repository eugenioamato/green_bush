abstract class TxtToImageInterface {
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
      apiGenerationEndpoint,
      apiFetchEndpoint,
      setState,
      repeatIndex);
  void multiSpan(setState, apiKey, apiName, apiGenerationEndpoint,
      apiFetchEndpoint, prompt, nprompt);
}
