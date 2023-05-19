import 'dart:typed_data';

class Shot implements Comparable<Shot> {
  Shot(this.id, this.url, this.prompt, this.nprompt, this.cfg, this.steps,
      this.seed, this.model, this.sampler, this.index);
  final int index;
  final String id;
  final String prompt;
  final String nprompt;
  final String url;
  final int cfg;
  final int steps;
  final int seed;
  final int model;
  final int sampler;
  double diff = double.infinity;
  Uint8List blob = Uint8List(0);

  void updateBlob(blob) => this.blob = blob;
  void updateDiff(diff) => this.diff = diff;

  @override
  int compareTo(Shot other) {
    if (prompt == other.prompt) {
      if (nprompt == other.nprompt) {
        if (seed == other.seed) {
          if (model == other.model) {
            if (sampler == other.sampler) {
              if (cfg == other.cfg) {
                if (steps == other.steps) {
                  return id.compareTo(other.id);
                } else {
                  return steps.compareTo(other.steps);
                }
              } else {
                return cfg.compareTo(other.cfg);
              }
            } else {
              return sampler.compareTo(other.sampler);
            }
          } else {
            return model.compareTo(other.model);
          }
        } else {
          return seed.compareTo(other.seed);
        }
      } else {
        return nprompt.compareTo(nprompt);
      }
    } else {
      return prompt.compareTo(other.prompt);
    }
  }

  copyWith({required int newIndex}) {
    return Shot(
      id,
      url,
      prompt,
      nprompt,
      cfg,
      steps,
      seed,
      model,
      sampler,
      newIndex,
    );
  }
}
