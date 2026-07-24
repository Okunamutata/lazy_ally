import 'package:flutter/widgets.dart';

/// The Okabe-Ito palette: eight colors chosen to remain distinguishable under
/// the common forms of color vision deficiency (protanopia, deuteranopia,
/// tritanopia). Used as [LazyAllyController]'s default color-blind-safe set.
///
/// Source: Okabe, M. & Ito, K. (2008), "Color Universal Design (CUD)".
const List<Color> kOkabeItoPalette = <Color>[
  Color(0xFFE69F00), // orange
  Color(0xFF56B4E9), // sky blue
  Color(0xFF009E73), // bluish green
  Color(0xFFF0E442), // yellow
  Color(0xFF0072B2), // blue
  Color(0xFFD55E00), // vermillion
  Color(0xFFCC79A7), // reddish purple
  Color(0xFF999999), // grey
];
