import 'package:flutter/material.dart';

class Criteria {
  String label;
  RangeValues values;
  double min;
  double max;
  double? target;
  int divisions;
  String? description;

  Criteria({
    required this.label,
    required this.values,
    required this.min,
    required this.max,
    required this.divisions,
    this.target,
    this.description,
  });
}

final trackRequestCriterias = [
  Criteria(
    label: 'Popularity',
    values: const RangeValues(0, 100),
    min: 0,
    max: 100,
    divisions: 100,
    description:
        'The popularity of the track. The value will be between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.',
  ),
  Criteria(
    label: 'Acousticness',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic.',
  ),
  Criteria(
    label: 'Danceability',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.',
  ),
  Criteria(
    label: 'Energy',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy.',
  ),
  Criteria(
    label: 'Valence',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g., happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g., sad, depressed, angry).',
  ),
  Criteria(
    label: 'Instrumentalness',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'Predicts whether a track contains no vocals. “Ooh” and “aah” sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly “vocal”. The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content.',
  ),
  Criteria(
    label: 'Speechiness',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g., talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words.',
  ),
  Criteria(
    label: 'Tempo',
    values: const RangeValues(0, 200),
    min: 0,
    max: 200,
    divisions: 200,
    description:
        'The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.',
  ),
  Criteria(
    label: 'Liveness',
    values: const RangeValues(0, 1),
    min: 0,
    max: 1,
    divisions: 100,
    description:
        'Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.',
  ),
  Criteria(
    label: 'Loudness',
    values: const RangeValues(-60, 0),
    min: -60,
    max: 0,
    divisions: 120,
    description:
        'The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude).',
  ),
];
