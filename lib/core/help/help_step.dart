import 'package:flutter/material.dart';

enum HelpCardPosition { auto, top, bottom, center }

class HelpStep {
  /// Short bold title shown in the card header.
  final String title;

  /// Longer explanation shown in the card body.
  final String description;

  /// Optional emoji or icon displayed alongside the title.
  final String? emoji;

  /// A [GlobalKey] attached to the widget you want to spotlight.
  /// If null the card is shown in the centre with no spotlight.
  final GlobalKey? targetKey;

  /// Extra space added around the target widget's bounds.
  final EdgeInsets padding;

  /// Whether the spotlight hole is circular (good for icon buttons)
  /// or rounded-rect (good for cards/sections).
  final bool circleSpotlight;

  /// Override where the help card appears relative to the spotlight.
  final HelpCardPosition cardPosition;

  const HelpStep({
    required this.title,
    required this.description,
    this.emoji,
    this.targetKey,
    this.padding = const EdgeInsets.all(10),
    this.circleSpotlight = false,
    this.cardPosition = HelpCardPosition.auto,
  });
}
