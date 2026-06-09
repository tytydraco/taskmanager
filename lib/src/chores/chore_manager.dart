import 'dart:io';

import 'package:intl/intl.dart';
import 'package:taskmanager/src/chores/chore.dart';
import 'package:yaml/yaml.dart';

/// Chore scheduling and assignment.
class ChoreManager {
  /// Creates a new [ChoreManager].
  ChoreManager() {
    final choreString = choreYamlFile.readAsStringSync();
    _choreYaml = loadYamlDocument(choreString);
  }

  /// The path to the chores YAML file.
  static const choreYamlPath = 'chores.yaml';

  /// The chores YAML file.
  late final choreYamlFile = File(choreYamlPath);

  /// The reference day for the start of a chore's history.
  final referenceDay = DateTime(2026);

  /// Today's date.
  final today = DateTime.now();

  late final YamlDocument _choreYaml;

  Set<Chore> _parseChores() {
    final contents = _choreYaml.contents.value as YamlMap;
    final chores = contents['chores'] as YamlList;
    return chores.map((e) => Chore.fromYAML(e as YamlMap)).toSet();
  }

  bool _matchesInterval(Chore chore, int daysSinceRef) {
    if (chore.daysBetween == 0) return true;

    // Weekly chores tied to specific weekdays use week-based intervals.
    // Day-based modulo from referenceDay only aligns with the reference
    // weekday, so e.g. Tuesday + daysBetween: 7 would never match.
    if (chore.daysBetween % 7 == 0 && chore.days.length < 7) {
      final weeksBetween = chore.daysBetween ~/ 7;
      return (daysSinceRef ~/ 7) % weeksBetween == 0;
    }

    return daysSinceRef % chore.daysBetween == 0;
  }

  /// Return a set of [Chore]s for today's date.
  Set<Chore> getTodaysChores() {
    final chores = _parseChores();
    final weekday = DateFormat.EEEE().format(today);
    final daysSinceRef = today.difference(referenceDay).inDays;

    return chores.where((chore) {
      if (!chore.days.contains(weekday)) return false;
      return _matchesInterval(chore, daysSinceRef);
    }).toSet();
  }

  /// Determine the guilty party for a chosen chore.
  List<String> guiltyPartyForChore(Chore chore) {
    if (!chore.rotation) return chore.party;
    final daysSinceRef = today.difference(referenceDay).inDays;
    final occurrenceIndex = daysSinceRef ~/ chore.daysBetween;
    final responsiblePerson = chore.party[occurrenceIndex % chore.party.length];
    return [responsiblePerson];
  }
}
