import 'package:yaml/yaml.dart';

/// A single chore.
class Chore {
  /// Creates a new [Chore].
  Chore({
    required this.name,
    required this.description,
    required this.days,
    required this.daysBetween,
    required this.rotation,
    required this.party,
  });

  /// Creates a new [Chore] from a [YamlDocument].
  factory Chore.fromYAML(YamlMap document) {
    return Chore(
      name: document['name'] as String,
      description: document['description'] as String,
      days: (document['days'] as YamlList).toSet().cast(),
      daysBetween: document['daysBetween'] as int,
      rotation: document['rotation'] as bool,
      party: (document['party'] as YamlList).toList().cast(),
    );
  }

  /// The chore name.
  final String name;

  /// The chore description.
  final String description;

  /// The days of the week for this chore.
  final Set<String> days;

  /// The minimum number of days between this chore.
  final int daysBetween;

  /// Whether to rotate between party members or use everybody.
  final bool rotation;

  /// The chore's responsible party.
  final List<String> party;
}
