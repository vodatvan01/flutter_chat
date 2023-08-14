// ScaffoldMessenger.of(context).clearSnackBars();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(wasAdded
//                         ? 'Meal added as a favorite.'
//                         : 'Meal removed.'),
//                   ),
//                 );

import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiKeyProvider = StateProvider<String?>((ref) => null);
