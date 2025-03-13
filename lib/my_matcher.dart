import 'package:conway/conway.dart';
import 'package:matcher/matcher.dart';

class _Endure extends Matcher {
  const _Endure();

  @override
  Description describe(Description description) {
    return description.add('Endures');
  }

  @override
  bool matches(dynamic pickle, Map matchState) {
    WorldState world;
    try {
      world = WorldState.fromFixture(pickle as String);
    } catch (e) {
      matchState['parseError'] = e;
      return false;
    }
    final nextWorld = next(world)!;
    final nextFixture = nextWorld.toFixture();
    matchState['next world'] = nextFixture;
    return pickle == nextFixture;
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState.containsKey('parseError')) {
      return mismatchDescription.add(matchState['parseError'].toString());
    }
    return mismatchDescription.add(
      '$item-- evolved to -->\n${matchState["nextWorld"]}',
    );
  }
}

const Matcher endures = _Endure();

class _EvolvesTo extends Matcher {
  const _EvolvesTo(this.targetFixture);
  final String targetFixture;
  @override
  Description describe(Description description) {
    return description.add('evolves to\n$targetFixture');
  }

  @override
  bool matches(dynamic pickle, Map matchState) {
    WorldState world;
    try {
      world = WorldState.fromFixture(pickle as String);
    } catch (e) {
      matchState['parseError'] = e;
      return false;
    }

    final nextWorld = next(world)!;
    final nextFixture = nextWorld.toFixture();
    matchState['nextWorld'] = nextFixture;
    return targetFixture == nextFixture;
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState.containsKey('parseError')) {
      return mismatchDescription.add(matchState['parseError'].toString());
    }

    return mismatchDescription.add(
      '$item-- evolved to -->\n${matchState["nextWorld"]}',
    );
  }
}

Matcher evolvesTo(String targetFixture) => _EvolvesTo(targetFixture);
