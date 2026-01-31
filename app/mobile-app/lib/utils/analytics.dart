import 'package:app/utils/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void logUserEvent(
  String name, [
  Map<String, Object?> otherParameters = const {},
]) {
  final userId = currentUserId();

  final parameters = Map<String, Object?>.from(otherParameters);
  parameters['user'] = userId;

  // Convert parameters to Map<String, Object> by removing null values
  final filteredParameters = <String, Object>{};
  parameters.forEach((key, value) {
    if (value != null) {
      filteredParameters[key] = value;
    }
  });

  FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: filteredParameters,
  );
}
