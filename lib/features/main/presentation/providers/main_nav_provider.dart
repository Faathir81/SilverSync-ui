import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the global navigation index for the bottom navigation bar.
final mainNavProvider = StateProvider<int>((ref) => 0);
