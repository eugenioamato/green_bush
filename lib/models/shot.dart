import 'package:flutter/material.dart';

class Shot implements Comparable<Shot> {
  Shot(this.id, this.url, this.prompt, this.nprompt, this.cfg, this.steps,
      this.seed, this.method, this.sampler, this.image);

  final String id;
  final String prompt;
  final String nprompt;
  final String url;
  final int cfg;
  final int steps;
  final int seed;
  final int method;
  final int sampler;
  Image? image;

  @override
  int compareTo(Shot other) {
    if (prompt == other.prompt) {
      if (nprompt == other.nprompt) {
        if (seed == other.seed) {
          if (method == other.method) {
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
            return method.compareTo(other.method);
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
}
