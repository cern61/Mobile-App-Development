// ============================================================================
//  UNIVERSE OBSERVER SYSTEM  -  a Dart practice project for DartPad
// ============================================================================
//  Paste this whole file into https://dartpad.dev and press "Run".
//
//  Topics covered (look for the numbered section markers):
//   1. Hello World        6. Interfaces & abstract classes   11. Imports
//   2. Variables          7. Mixins                          12. Comments
//   3. Control flow       8. Inheritance                     13. Important
//   4. Functions          9. Async (Future / Stream)             concepts
//   5. Classes & Enums   10. Exceptions
//
//  Class hierarchy (inheritance = "what kind of object is it?"):
//
//   CelestialObject (abstract)
//    |-- Galaxy (abstract)      -> SpiralGalaxy, EllipticalGalaxy, IrregularGalaxy
//    |-- SolarSystem            (holds a Star and a list of bodies)
//    |-- Star (abstract)        -> RedDwarf, YellowDwarf, BlueGiant
//    |-- Planet (abstract)      -> RockyPlanet, GasGiant, IceGiant
//    |-- SmallBody (abstract)   -> Asteroid, Comet, Meteoroid
//    '-- Moon
//
//  Containment (composition = "what does it contain?"):
//   Universe -> Galaxy -> SolarSystem -> Star + Planets/SmallBodies -> Moons
//
//  NOTE: all astronomical values are rounded or illustrative. The
//  "Andromeda Alpha" system is fictional.
// ============================================================================

// ---------- 11. IMPORTS ----------
// 'dart:async' gives us Completer, Timer and TimeoutException.
// 'dart:math' gives us sqrt() and pow().
import 'dart:async';
import 'dart:math';

/* ---------- 12. COMMENTS ----------
   // single-line comment
   /* multi-line comment */
   /// documentation comment (shown by the IDE when you hover over the code)
*/

// ============================================================================
//  5. ENUMS (enhanced enums can hold fields, constructors and methods)
// ============================================================================

enum ObservationMethod {
  optical('Optical telescope', 3e6),
  infrared('Infrared telescope', 6e7),
  xray('X-ray telescope', 1e6),
  radio('Radio telescope', 1e10);

  final String label;
  final double maxRangeLightYears; // how far this instrument can "see"
  const ObservationMethod(this.label, this.maxRangeLightYears);
}

/// Harvard spectral classes. Listed from the hottest to the coolest star.
enum SpectralClass {
  o('O', 'Blue', 30000),
  b('B', 'Blue-white', 10000),
  a('A', 'White', 7500),
  f('F', 'Yellow-white', 6000),
  g('G', 'Yellow', 5200),
  k('K', 'Orange', 3700),
  m('M', 'Red', 2400);

  final String letter;
  final String color;
  final int minTemperatureK;
  const SpectralClass(this.letter, this.color, this.minTemperatureK);

  /// Static method inside an enum: finds the class for a temperature.
  static SpectralClass fromTemperature(int kelvin) => values.firstWhere(
        (c) => kelvin >= c.minTemperatureK,
        orElse: () => SpectralClass.m,
      );
}

// ============================================================================
//  10. EXCEPTIONS (a small custom exception hierarchy)
// ============================================================================

/// Base class for every problem the observatory can run into.
class ObservatoryException implements Exception {
  final String message;
  const ObservatoryException(this.message);

  @override
  String toString() => 'ObservatoryException: $message';
}

class TargetOutOfRangeException extends ObservatoryException {
  final double distanceLightYears;
  final ObservationMethod method;

  TargetOutOfRangeException(String target, this.distanceLightYears, this.method)
      : super('$target is ${distanceLightYears.asLightYears} away, but the '
            '${method.label} only reaches ${method.maxRangeLightYears.asLightYears}');
}

class InstrumentUnavailableException extends ObservatoryException {
  InstrumentUnavailableException(ObservationMethod method)
      : super('${method.label} is not installed at this observatory');
}

class ObjectNotFoundException extends ObservatoryException {
  ObjectNotFoundException(String query)
      : super('No object named "$query" exists in the catalog');
}

// ============================================================================
//  13. IMPORTANT CONCEPTS: extension methods and typedefs
// ============================================================================

/// Formats a distance: 2500000.0.asLightYears -> "2.5 million ly"
extension DistanceFormatting on double {
  String get asLightYears {
    if (this <= 0) return 'home (0 ly)';
    if (this >= 1e9) return '${(this / 1e9).toStringAsFixed(1)} billion ly';
    if (this >= 1e6) return '${(this / 1e6).toStringAsFixed(1)} million ly';
    if (this >= 1e3) return '${(this / 1e3).toStringAsFixed(1)} thousand ly';
    return '${toStringAsFixed(2)} ly';
  }
}

/// Short, readable numbers for big and small values.
extension NumberFormatting on double {
  String get compact {
    if (abs() >= 100) return toStringAsFixed(0);
    if (abs() >= 1) return toStringAsFixed(2);
    return toStringAsPrecision(2);
  }
}

/// A function type: decides whether an object passes a filter.
typedef ObjectFilter = bool Function(CelestialObject);

// ============================================================================
//  6. INTERFACES AND ABSTRACT CLASSES
// ============================================================================

/// Anything an observatory can point a telescope at.
abstract interface class Observable {
  String get designation;
  double get distanceLightYears;
  String observe(ObservationMethod method);
}

/// Anything that can appear in the star catalog.
abstract interface class Catalogable {
  String catalogEntry();
}

/// The root of our hierarchy. It is abstract, so you cannot write
/// `CelestialObject('x')` directly; you must create a concrete subclass.
abstract class CelestialObject implements Observable, Catalogable {
  static int _counter = 0; // shared by ALL objects (static)
  static int get totalCatalogued => _counter;

  final int id;
  final String name;

  @override
  double distanceLightYears; // not final: a system updates its bodies' distance

  CelestialObject(this.name, {this.distanceLightYears = 0}) : id = ++_counter;

  String get kind; // every subclass must provide this
  String describe(); // ...and this

  @override
  String get designation => 'OBJ-${id.toString().padLeft(4, '0')}';

  @override
  String observe(ObservationMethod method) =>
      '[${method.label}] $name - ${describe()}';

  @override
  String catalogEntry() => '$designation | ${kind.padRight(18)} | $name';
}

// ============================================================================
//  7. MIXINS (reusable behavior without deep inheritance)
// ============================================================================

/// For objects that shine on their own (stars).
mixin Luminous {
  double get luminositySuns; // 1.0 = as bright as our Sun
  bool get isBright => luminositySuns >= 1;

  String brightnessReport() =>
      'luminosity ${luminositySuns.compact} Suns (${isBright ? 'bright' : 'dim'})';
}

/// For objects that travel around something. Uses Kepler's third law:
/// T (years) = sqrt(a^3 / M), with a in AU and M in solar masses.
mixin Orbiting {
  double get orbitRadiusAu;
  double get hostMassSuns; // mass of the object being orbited

  double get orbitalPeriodDays =>
      sqrt(pow(orbitRadiusAu, 3) / hostMassSuns) * 365.25;

  String describeOrbit() =>
      'orbit ${orbitRadiusAu.compact} AU, period ${orbitalPeriodDays.compact} days';
}

/// For objects that spin.
mixin Rotating {
  double get rotationHours;

  String dayLength() => rotationHours >= 48
      ? '${(rotationHours / 24).toStringAsFixed(1)} Earth days'
      : '${rotationHours.toStringAsFixed(1)} hours';
}

/// For planets that own moons. A mixin can even hold state (a list).
mixin MoonBearer {
  final List<Moon> moons = [];

  void addMoon(Moon moon) => moons.add(moon);
}

// ============================================================================
//  8. INHERITANCE - GALAXIES
// ============================================================================

abstract class Galaxy extends CelestialObject {
  final double starCountBillions;
  final List<SolarSystem> systems = [];

  Galaxy(super.name, {required super.distanceLightYears, required this.starCountBillions});

  String get shape;

  void addSystem(SolarSystem system) => systems.add(system);

  @override
  String describe() =>
      '$shape galaxy, ~${starCountBillions.toStringAsFixed(0)} billion stars, '
      '${systems.length} catalogued system(s)';
}

class SpiralGalaxy extends Galaxy {
  final int armCount;

  SpiralGalaxy(
    super.name, {
    required super.distanceLightYears,
    required super.starCountBillions,
    required this.armCount,
  });

  @override
  String get kind => 'Spiral galaxy';
  @override
  String get shape => 'Spiral ($armCount arms)';
}

class EllipticalGalaxy extends Galaxy {
  EllipticalGalaxy(super.name,
      {required super.distanceLightYears, required super.starCountBillions});

  @override
  String get kind => 'Elliptical galaxy';
  @override
  String get shape => 'Elliptical';
}

class IrregularGalaxy extends Galaxy {
  IrregularGalaxy(super.name,
      {required super.distanceLightYears, required super.starCountBillions});

  @override
  String get kind => 'Irregular galaxy';
  @override
  String get shape => 'Irregular';
}

// ============================================================================
//  8. INHERITANCE - STARS
// ============================================================================

abstract class Star extends CelestialObject with Luminous {
  final SpectralClass spectralClass;
  final double massSuns;

  @override
  final double luminositySuns;

  Star(
    super.name, {
    required this.spectralClass,
    required this.massSuns,
    required this.luminositySuns,
  });

  @override
  String describe() =>
      '${spectralClass.color} ${spectralClass.letter}-class star, '
      '${massSuns.compact} solar masses, ${brightnessReport()}';
}

class RedDwarf extends Star {
  RedDwarf(super.name, {required super.massSuns, required super.luminositySuns})
      : super(spectralClass: SpectralClass.m);

  @override
  String get kind => 'Red dwarf';
}

class YellowDwarf extends Star {
  YellowDwarf(super.name, {required super.massSuns, required super.luminositySuns})
      : super(spectralClass: SpectralClass.g);

  @override
  String get kind => 'Yellow dwarf';
}

class BlueGiant extends Star {
  BlueGiant(super.name, {required super.massSuns, required super.luminositySuns})
      : super(spectralClass: SpectralClass.o);

  @override
  String get kind => 'Blue giant';
}

// ============================================================================
//  8. INHERITANCE - PLANETS AND MOONS
// ============================================================================

abstract class Planet extends CelestialObject with Orbiting, Rotating, MoonBearer {
  @override
  final double orbitRadiusAu;
  @override
  final double rotationHours;
  @override
  final double hostMassSuns;

  final double diameterKm;

  Planet(
    super.name, {
    required this.orbitRadiusAu,
    required this.rotationHours,
    required this.diameterKm,
    this.hostMassSuns = 1.0,
  });

  @override
  String describe() =>
      '$kind, ${diameterKm.toStringAsFixed(0)} km wide, ${describeOrbit()}, '
      'day = ${dayLength()}, ${moons.length} moon(s)';
}

class RockyPlanet extends Planet {
  final bool hasAtmosphere;

  RockyPlanet(
    super.name, {
    required super.orbitRadiusAu,
    required super.rotationHours,
    required super.diameterKm,
    super.hostMassSuns,
    this.hasAtmosphere = false,
  });

  @override
  String get kind => 'Rocky planet';
}

class GasGiant extends Planet {
  final bool hasRings;

  GasGiant(
    super.name, {
    required super.orbitRadiusAu,
    required super.rotationHours,
    required super.diameterKm,
    super.hostMassSuns,
    this.hasRings = false,
  });

  @override
  String get kind => 'Gas giant';
}

class IceGiant extends Planet {
  IceGiant(
    super.name, {
    required super.orbitRadiusAu,
    required super.rotationHours,
    required super.diameterKm,
    super.hostMassSuns,
  });

  @override
  String get kind => 'Ice giant';
}

class Moon extends CelestialObject with Orbiting {
  @override
  final double orbitRadiusAu;
  @override
  final double hostMassSuns; // the planet's mass, expressed in solar masses

  Moon(super.name, {required this.orbitRadiusAu, required this.hostMassSuns});

  @override
  String get kind => 'Moon';

  @override
  String describe() => 'natural satellite, ${describeOrbit()}';
}

// ============================================================================
//  8. INHERITANCE - SMALL BODIES (asteroids, comets, meteoroids)
// ============================================================================

abstract class SmallBody extends CelestialObject with Orbiting {
  @override
  final double orbitRadiusAu;
  @override
  final double hostMassSuns;

  SmallBody(super.name, {required this.orbitRadiusAu, this.hostMassSuns = 1.0});
}

class Asteroid extends SmallBody {
  final double diameterKm;

  Asteroid(super.name,
      {required super.orbitRadiusAu, super.hostMassSuns, required this.diameterKm});

  @override
  String get kind => 'Asteroid';
  @override
  String describe() => '${diameterKm.toStringAsFixed(0)} km wide, ${describeOrbit()}';
}

class Comet extends SmallBody {
  final double eccentricity; // 0 = circle, close to 1 = very stretched ellipse

  Comet(super.name,
      {required super.orbitRadiusAu, super.hostMassSuns, required this.eccentricity});

  @override
  String get kind => 'Comet';
  @override
  String describe() => 'eccentricity $eccentricity, ${describeOrbit()}';
}

class Meteoroid extends SmallBody {
  final double sizeMeters;

  Meteoroid(super.name,
      {required super.orbitRadiusAu, super.hostMassSuns, required this.sizeMeters});

  /// Small meteoroids burn up as meteors when they enter an atmosphere.
  bool get burnsInAtmosphere => sizeMeters < 10;

  @override
  String get kind => 'Meteoroid';
  @override
  String describe() =>
      '${sizeMeters.toStringAsFixed(1)} m across, ${burnsInAtmosphere ? 'burns up as a meteor' : 'may reach the ground'}';
}

// ============================================================================
//  5. CLASSES - SolarSystem, Universe, Watchlist, Observatory
// ============================================================================

class SolarSystem extends CelestialObject {
  final Star star;
  final List<CelestialObject> bodies = []; // planets and small bodies

  SolarSystem(super.name, {required super.distanceLightYears, required this.star}) {
    star.distanceLightYears = distanceLightYears; // the star lives here too
  }

  @override
  String get kind => 'Planetary system';

  void addBody(CelestialObject body) {
    body.distanceLightYears = distanceLightYears;
    bodies.add(body);
    if (body case final MoonBearer carrier) {
      for (final moon in carrier.moons) {
        moon.distanceLightYears = distanceLightYears;
      }
    }
  }

  /// A record with named fields: the "habitable zone" around the star.
  ({double inner, double outer}) get habitableZone {
    final l = star.luminositySuns;
    return (inner: sqrt(l / 1.1), outer: sqrt(l / 0.53));
  }

  /// Rocky planets orbiting inside the habitable zone.
  List<RockyPlanet> get habitableCandidates {
    final zone = habitableZone;
    return bodies
        .whereType<RockyPlanet>()
        .where((p) => p.orbitRadiusAu >= zone.inner && p.orbitRadiusAu <= zone.outer)
        .toList();
  }

  @override
  String describe() =>
      '${star.name} (${star.spectralClass.letter}-class) with ${bodies.length} orbiting bodies';
}

class Universe {
  final String name;
  final List<Galaxy> galaxies = [];

  Universe(this.name);

  /// Factory constructor: builds a ready-to-use demo universe.
  factory Universe.sample() {
    final universe = Universe('Observable Universe');

    // ----- Our own Solar System -----
    final earth = RockyPlanet('Earth',
        orbitRadiusAu: 1.0, rotationHours: 24, diameterKm: 12742, hasAtmosphere: true)
      ..addMoon(Moon('Moon', orbitRadiusAu: 0.00257, hostMassSuns: 3.003e-6));

    final mars = RockyPlanet('Mars',
        orbitRadiusAu: 1.524, rotationHours: 24.6, diameterKm: 6779, hasAtmosphere: true)
      ..addMoon(Moon('Phobos', orbitRadiusAu: 0.0000627, hostMassSuns: 3.227e-7))
      ..addMoon(Moon('Deimos', orbitRadiusAu: 0.000157, hostMassSuns: 3.227e-7));

    final jupiter = GasGiant('Jupiter',
        orbitRadiusAu: 5.2, rotationHours: 9.9, diameterKm: 139820, hasRings: true)
      ..addMoon(Moon('Io', orbitRadiusAu: 0.00282, hostMassSuns: 9.546e-4))
      ..addMoon(Moon('Europa', orbitRadiusAu: 0.00449, hostMassSuns: 9.546e-4));

    final solar = SolarSystem('Solar System',
        distanceLightYears: 0,
        star: YellowDwarf('Sun', massSuns: 1.0, luminositySuns: 1.0));
    solar
      ..addBody(RockyPlanet('Mercury',
          orbitRadiusAu: 0.387, rotationHours: 1407.6, diameterKm: 4879))
      ..addBody(earth)
      ..addBody(mars)
      ..addBody(jupiter)
      ..addBody(GasGiant('Saturn',
          orbitRadiusAu: 9.58, rotationHours: 10.7, diameterKm: 116460, hasRings: true))
      ..addBody(IceGiant('Uranus',
          orbitRadiusAu: 19.2, rotationHours: 17.2, diameterKm: 50724))
      ..addBody(Asteroid('Ceres', orbitRadiusAu: 2.77, diameterKm: 939))
      ..addBody(Comet('Halley', orbitRadiusAu: 17.8, eccentricity: 0.967))
      ..addBody(Meteoroid('Perseid Fragment', orbitRadiusAu: 2.0, sizeMeters: 0.4));

    // ----- Nearby systems -----
    final proxima = SolarSystem('Proxima Centauri System',
        distanceLightYears: 4.24,
        star: RedDwarf('Proxima Centauri', massSuns: 0.12, luminositySuns: 0.0017))
      ..addBody(RockyPlanet('Proxima b',
          orbitRadiusAu: 0.0485,
          rotationHours: 268.8,
          diameterKm: 14000,
          hostMassSuns: 0.12));

    final trappist = SolarSystem('TRAPPIST-1 System',
        distanceLightYears: 40.7,
        star: RedDwarf('TRAPPIST-1', massSuns: 0.09, luminositySuns: 0.00055))
      ..addBody(RockyPlanet('TRAPPIST-1e',
          orbitRadiusAu: 0.0292,
          rotationHours: 146,
          diameterKm: 11600,
          hostMassSuns: 0.09))
      ..addBody(RockyPlanet('TRAPPIST-1f',
          orbitRadiusAu: 0.0385,
          rotationHours: 221,
          diameterKm: 13300,
          hostMassSuns: 0.09));

    final kepler = SolarSystem('Kepler-452 System',
        distanceLightYears: 1402,
        star: YellowDwarf('Kepler-452', massSuns: 1.04, luminositySuns: 1.2))
      ..addBody(RockyPlanet('Kepler-452b',
          orbitRadiusAu: 1.046,
          rotationHours: 24,
          diameterKm: 20400,
          hostMassSuns: 1.04));

    final milkyWay = SpiralGalaxy('Milky Way',
        distanceLightYears: 0, starCountBillions: 200, armCount: 4)
      ..addSystem(solar)
      ..addSystem(proxima)
      ..addSystem(trappist)
      ..addSystem(kepler);

    // ----- Other galaxies -----
    final andromedaSystem = SolarSystem('Andromeda Alpha System', // fictional
        distanceLightYears: 2.5e6,
        star: BlueGiant('Alpha-X', massSuns: 20, luminositySuns: 50000))
      ..addBody(GasGiant('Alpha-X b',
          orbitRadiusAu: 8, rotationHours: 12, diameterKm: 150000, hostMassSuns: 20, hasRings: true));

    final andromeda = SpiralGalaxy('Andromeda',
        distanceLightYears: 2.5e6, starCountBillions: 1000, armCount: 2)
      ..addSystem(andromedaSystem);

    universe.galaxies.addAll([
      milkyWay,
      andromeda,
      EllipticalGalaxy('Messier 87', distanceLightYears: 5.35e7, starCountBillions: 1000),
      IrregularGalaxy('Large Magellanic Cloud',
          distanceLightYears: 160000, starCountBillions: 30),
    ]);
    return universe;
  }

  /// A GENERATOR: "sync*" produces values lazily, one at a time, with "yield".
  Iterable<CelestialObject> everything() sync* {
    for (final galaxy in galaxies) {
      yield galaxy;
      for (final system in galaxy.systems) {
        yield system;
        yield system.star;
        for (final body in system.bodies) {
          yield body;
          if (body case final MoonBearer carrier) {
            yield* carrier.moons; // yield* hands over a whole collection
          }
        }
      }
    }
  }

  /// Generic method: ofType<Planet>() or ofType<Star>() filters by type.
  List<T> ofType<T extends CelestialObject>() => everything().whereType<T>().toList();

  /// Throws when nothing matches.
  CelestialObject findByName(String query) => everything().firstWhere(
        (o) => o.name.toLowerCase() == query.toLowerCase(),
        orElse: () => throw ObjectNotFoundException(query),
      );

  /// Returns null instead of throwing (note the "?" nullable return type).
  CelestialObject? tryFind(String query) {
    for (final object in everything()) {
      if (object.name.toLowerCase() == query.toLowerCase()) return object;
    }
    return null;
  }

  ({int galaxies, int systems, int planets, int moons, int smallBodies}) census() => (
        galaxies: ofType<Galaxy>().length,
        systems: ofType<SolarSystem>().length,
        planets: ofType<Planet>().length,
        moons: ofType<Moon>().length,
        smallBodies: ofType<SmallBody>().length,
      );
}

/// A generic class: Watchlist<Star>, Watchlist<Planet>, ...
class Watchlist<T extends CelestialObject> {
  final String title;
  final List<T> _items = []; // private: the underscore hides it

  Watchlist(this.title);

  void add(T item) => _items.add(item);

  List<T> get items => List.unmodifiable(_items);

  /// Returns the item with the highest score, or null for an empty list.
  T? maxBy(double Function(T) score) {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => score(a) >= score(b) ? a : b);
  }
}

class Observatory {
  final String name;
  final Universe universe;
  final Set<ObservationMethod> instruments;
  final List<String> log = [];

  Observatory(this.name, this.universe, {required this.instruments});

  void _validate(CelestialObject target, ObservationMethod method) {
    if (!instruments.contains(method)) {
      throw InstrumentUnavailableException(method);
    }
    if (target.distanceLightYears > method.maxRangeLightYears) {
      throw TargetOutOfRangeException(target.name, target.distanceLightYears, method);
    }
  }

  // ---------- 9. ASYNC ----------

  /// A Future-returning function: the telescope needs time to collect light.
  Future<String> observe(CelestialObject target, ObservationMethod method) async {
    _validate(target, method); // may throw -> the Future completes with an error
    await Future.delayed(const Duration(milliseconds: 150));
    final report = target.observe(method);
    log.add(report);
    return report;
  }

  /// Observes many targets in parallel and never fails as a whole.
  Future<List<String>> observeMany(
      List<CelestialObject> targets, ObservationMethod method) {
    return Future.wait(targets.map((target) async {
      try {
        return await observe(target, method);
      } on TargetOutOfRangeException catch (e) {
        return 'FAILED: ${e.message}';
      }
    }));
  }

  /// Completer + Timer: the "manual" way to create a Future.
  Future<String> calibrate(ObservationMethod method) {
    final completer = Completer<String>();
    if (!instruments.contains(method)) {
      completer.completeError(InstrumentUnavailableException(method));
      return completer.future;
    }
    Timer(const Duration(milliseconds: 250), () {
      completer.complete('${method.label} calibrated and ready');
    });
    return completer.future;
  }

  /// A deliberately slow task, used to demonstrate timeouts.
  Future<String> longExposure(CelestialObject target) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'Long exposure of ${target.name} complete';
  }

  /// Logs the error, then passes it on to the caller with "rethrow".
  Future<String> observeOrEscalate(CelestialObject target, ObservationMethod method) async {
    try {
      return await observe(target, method);
    } catch (e) {
      log.add('ERROR: $e');
      rethrow;
    }
  }

  /// A Stream: "async*" + "yield" emit results one by one as they arrive.
  Stream<String> skySurvey(ObservationMethod method) async* {
    for (final galaxy in universe.galaxies) {
      try {
        yield await observe(galaxy, method);
      } on TargetOutOfRangeException catch (e) {
        yield 'SKIPPED: ${e.message}';
      }
    }
  }
}

// ============================================================================
//  4. FUNCTIONS
// ============================================================================

/// Optional POSITIONAL parameter with a default value.
String bar([int width = 60]) => '=' * width;

/// Prints a section title.
void section(String title) {
  print('\n${bar()}\n  $title\n${bar()}');
}

/// Optional NAMED parameters with default values.
String describeDistance(CelestialObject o, {bool showId = false, String prefix = '->'}) =>
    '$prefix ${showId ? '${o.designation} ' : ''}${o.name}: ${o.distanceLightYears.asLightYears}';

/// Switch EXPRESSION with relational patterns on a double.
String distanceCategory(double ly) => switch (ly) {
      <= 0.0 => 'Home galaxy',
      < 5e5 => 'Satellite neighbor',
      < 5e6 => 'Local Group',
      < 1e8 => 'Nearby cluster',
      _ => 'Deep space',
    };

/// Switch expression with OBJECT patterns: the first matching case wins,
/// so more specific patterns must come first.
String classify(CelestialObject o) => switch (o) {
      SpiralGalaxy(armCount: >= 4) => 'Grand-design spiral galaxy',
      SpiralGalaxy() => 'Spiral galaxy',
      Galaxy() => 'Non-spiral galaxy',
      SolarSystem() => 'Planetary system',
      Star(isBright: true) => 'Bright star',
      Star() => 'Dim star',
      GasGiant(hasRings: true) => 'Ringed gas giant',
      Planet() => 'Planet',
      Moon() => 'Natural satellite',
      SmallBody() => 'Small body',
      _ => 'Unknown',
    };

/// Takes a function as a parameter (higher-order function).
List<CelestialObject> select(Iterable<CelestialObject> source, ObjectFilter keep) =>
    source.where(keep).toList();

// ============================================================================
//  1. HELLO WORLD - every Dart program starts at main()
// ============================================================================

Future<void> main() async {
  print('Hello, Universe! Welcome to the Universe Observer System.');

  // --------------------------------------------------------------------------
  section('2. VARIABLES');
  // --------------------------------------------------------------------------
  const universeName = 'Observable Universe'; // compile-time constant
  final foundedYear = 1990; // assigned once, never changes
  var observationsRequested = 0; // type inferred (int), can change
  double budgetMillions = 12.5; // explicit type
  String? lastTarget; // nullable: can hold a String or null
  late final Universe universe; // assigned later, exactly once

  print('$universeName | observatory founded in $foundedYear | budget: $budgetMillions M');
  print('Last target: ${lastTarget ?? 'none yet'}'); // ?? = "if null, use this"

  universe = Universe.sample();
  lastTarget = 'Andromeda';
  observationsRequested += 1;
  print('Last target now: $lastTarget (${lastTarget.length} characters), '
      'requests so far: $observationsRequested');

  final observatory = Observatory(
    'Deep Sky Station',
    universe,
    instruments: {
      ObservationMethod.optical,
      ObservationMethod.infrared,
      ObservationMethod.radio,
    }, // a Set: no duplicates allowed
  );

  // --------------------------------------------------------------------------
  section('3. CONTROL FLOW');
  // --------------------------------------------------------------------------
  final census = universe.census();
  print('Census: ${census.galaxies} galaxies, ${census.systems} systems, '
      '${census.planets} planets, ${census.moons} moons, '
      '${census.smallBodies} small bodies');

  // classic switch statement on an int
  switch (census.galaxies) {
    case 0:
      print('No galaxies catalogued yet.');
    case 1:
    case 2:
      print('Just a few galaxies on the list.');
    default:
      print('A rich catalogue: ${census.galaxies} galaxies.');
  }

  // if / else if / else
  if (census.planets > census.moons) {
    print('More planets than moons in the catalogue.');
  } else if (census.planets < census.moons) {
    print('More moons than planets in the catalogue.');
  } else {
    print('Equal numbers of planets and moons.');
  }

  // for-in loop + switch expression
  print('\nGalaxies by distance:');
  for (final galaxy in universe.galaxies) {
    print('  ${galaxy.name.padRight(24)} ${distanceCategory(galaxy.distanceLightYears)}');
  }

  // for-in loop with break
  CelestialObject? firstRinged;
  for (final object in universe.everything()) {
    if (object is GasGiant && object.hasRings) {
      firstRinged = object;
      break; // stop as soon as we find one
    }
  }
  print('\nFirst ringed gas giant found: ${firstRinged?.name ?? 'none'}');

  // while loop with continue, using an iterator
  print('\nHabitable-zone search:');
  final systemIterator = universe.ofType<SolarSystem>().iterator;
  var checked = 0;
  while (systemIterator.moveNext()) {
    checked++;
    final system = systemIterator.current;
    final candidates = system.habitableCandidates;
    if (candidates.isEmpty) continue; // nothing here, next system
    final zone = system.habitableZone;
    print('  ${system.name}: zone ${zone.inner.compact}-${zone.outer.compact} AU '
        '-> ${candidates.map((p) => p.name).join(', ')}');
  }
  print('  ($checked systems checked)');

  // collection-if and collection-for build lists in one expression
  final highlights = [
    for (final galaxy in universe.galaxies)
      if (galaxy.systems.isNotEmpty) '${galaxy.name} (${galaxy.systems.length})' else galaxy.name,
  ];
  print('\nGalaxy list (systems in brackets): ${highlights.join(', ')}');

  // --------------------------------------------------------------------------
  section('5 & 8. CLASSES, ENUMS & INHERITANCE');
  // --------------------------------------------------------------------------
  print('Classification (object patterns):');
  for (final object in universe.everything().where((o) => o is! Moon)) {
    print('  ${object.name.padRight(26)} ${classify(object)}');
  }

  print('\nSpectral classes (enum values):');
  for (final c in SpectralClass.values) {
    print('  ${c.letter}  ${c.color.padRight(12)} from ${c.minTemperatureK} K');
  }
  print('The Sun (5772 K) is class ${SpectralClass.fromTemperature(5772).letter}');
  print('Total objects catalogued: ${CelestialObject.totalCatalogued}');

  print('\nFirst catalog entries:');
  for (final object in universe.everything().take(5)) {
    print('  ${object.catalogEntry()}');
  }

  // --------------------------------------------------------------------------
  section('7. MIXINS in action');
  // --------------------------------------------------------------------------
  print('Luminous mixin (stars):');
  for (final star in universe.ofType<Star>()) {
    print('  ${star.name.padRight(18)} ${star.brightnessReport()}');
  }

  final solar = universe.ofType<SolarSystem>().first;
  print('\nOrbiting + Rotating + MoonBearer mixins (Solar System planets):');
  for (final planet in solar.bodies.whereType<Planet>()) {
    print('  ${planet.name.padRight(8)} ${planet.describeOrbit()} | day: ${planet.dayLength()}');
    for (final moon in planet.moons) {
      print('      moon ${moon.name.padRight(7)} ${moon.describeOrbit()}');
    }
  }

  print('\nOrbiting mixin on small bodies:');
  for (final body in solar.bodies.whereType<SmallBody>()) {
    print('  ${body.kind.padRight(10)} ${body.name.padRight(18)} ${body.describe()}');
  }

  // --------------------------------------------------------------------------
  section('6. INTERFACES - everything is Observable');
  // --------------------------------------------------------------------------
  // Galaxies, stars, planets... are unrelated branches, but all implement
  // Observable, so they can live in one list.
  final List<Observable> targets = [
    universe.findByName('Andromeda'),
    universe.findByName('Proxima Centauri'),
    universe.findByName('Saturn'),
    universe.findByName('Halley'),
  ];
  targets.sort((a, b) => a.distanceLightYears.compareTo(b.distanceLightYears));
  for (final t in targets) {
    print('  ${t.designation}  ${t.distanceLightYears.asLightYears}');
  }

  // Higher-order function + closure + typedef'd filter
  final minDistance = 1000.0;
  ObjectFilter farAway = (o) => o.distanceLightYears > minDistance;
  final distant = select(universe.everything(), farAway);
  print('\nObjects farther than ${minDistance.toStringAsFixed(0)} ly: ${distant.length}');
  print(describeDistance(distant.first, showId: true, prefix: '*'));

  // --------------------------------------------------------------------------
  section('9. ASYNC - Future, Completer, Future.wait, Stream');
  // --------------------------------------------------------------------------
  // do-while: always runs at least once
  var countdown = 3;
  do {
    print('  T-minus $countdown...');
    countdown--;
  } while (countdown > 0);

  print('\nCalibrating instrument (Completer + Timer)...');
  print('  ${await observatory.calibrate(ObservationMethod.optical)}');

  print('\nSingle observation (await):');
  print('  ${await observatory.observe(universe.findByName('Proxima Centauri'), ObservationMethod.optical)}');

  print('\nFour galaxies at once (Future.wait, optical):');
  final results = await observatory.observeMany([
    universe.findByName('Milky Way'),
    universe.findByName('Andromeda'),
    universe.findByName('Messier 87'), // too far for optical!
    universe.findByName('Large Magellanic Cloud'),
  ], ObservationMethod.optical);
  for (final line in results) {
    print('  $line');
  }

  print('\nSky survey (Stream with optical):');
  await for (final line in observatory.skySurvey(ObservationMethod.optical)) {
    print('  $line');
  }

  // --------------------------------------------------------------------------
  section('10. EXCEPTIONS');
  // --------------------------------------------------------------------------
  final m87 = universe.findByName('Messier 87');

  // (a) Target too far away -> our own exception type
  try {
    await observatory.observe(m87, ObservationMethod.optical);
  } on TargetOutOfRangeException catch (e) {
    print('Caught (out of range): ${e.message}');
  }

  // (b) Instrument that is not installed
  try {
    await observatory.observe(universe.findByName('Milky Way'), ObservationMethod.xray);
  } on InstrumentUnavailableException catch (e) {
    print('Caught (no instrument): ${e.message}');
  }

  // (c) Unknown object: a catch-all for our base class
  try {
    universe.findByName('Planet Nine');
  } on ObservatoryException catch (e) {
    print('Caught (base class): $e');
  }

  // (d) Timeout from dart:async
  try {
    final report = await observatory
        .longExposure(universe.findByName('Sun'))
        .timeout(const Duration(milliseconds: 300));
    print(report);
  } on TimeoutException catch (e) {
    print('Caught (timeout): ${e.message ?? 'the exposure took too long'}');
  }

  // (e) rethrow + finally + stack trace
  try {
    await observatory.observeOrEscalate(m87, ObservationMethod.optical);
  } on ObservatoryException catch (e, stackTrace) {
    print('Escalated error: ${e.message}');
    print('  (stack trace has ${stackTrace.toString().split('\n').length} lines)');
  } finally {
    print('Finally block: the observatory log has ${observatory.log.length} entries.');
  }

  // (f) A null-safe lookup never throws
  final ghost = universe.tryFind('Unicorn Nebula');
  print('Unicorn Nebula found? ${ghost != null} -> ${ghost?.name ?? 'nothing'}');

  // --------------------------------------------------------------------------
  section('13. IMPORTANT CONCEPTS - quick recap');
  // --------------------------------------------------------------------------
  // Records and destructuring
  final farthest = universe.galaxies
      .reduce((a, b) => a.distanceLightYears >= b.distanceLightYears ? a : b);
  final (farName, farDistance) = (farthest.name, farthest.distanceLightYears);
  print('Farthest galaxy: $farName at ${farDistance.asLightYears}');

  // Generics with a bounded type parameter
  final starWatch = Watchlist<Star>('Stars to watch');
  for (final star in universe.ofType<Star>()) {
    starWatch.add(star);
  }
  final brightest = starWatch.maxBy((s) => s.luminositySuns);
  print('Brightest star on "${starWatch.title}": ${brightest?.name} '
      '(${brightest?.luminositySuns.compact} Suns)');

  // Map with update(): count objects per kind
  final kindCounts = <String, int>{};
  for (final object in universe.everything()) {
    kindCounts.update(object.kind, (count) => count + 1, ifAbsent: () => 1);
  }
  final ranking = kindCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // cascade operator (..)
  print('Most common object kinds:');
  for (final entry in ranking.take(3)) {
    print('  ${entry.key.padRight(14)} x${entry.value}');
  }

  // Cascade, null-aware assignment and spread
  String? note;
  note ??= 'Observation run complete'; // assign only if currently null
  final summary = <String>[
    note,
    ...ranking.take(2).map((e) => e.key), // spread operator
  ];
  print('Summary: ${summary.join(' | ')}');

  print('\nGoodbye from the ${observatory.name}!');
}