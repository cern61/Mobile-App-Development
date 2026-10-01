// ============================================================================
//  BIG FARM MANAGEMENT SYSTEM  -  a Dart practice project for DartPad
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
//  Class hierarchy:
//
//   LivingBeing (abstract)
//    |-- Animal (abstract)
//    |    |-- Poultry (abstract)          -> Chicken, Duck
//    |    |-- LargeLivestock (abstract)   -> Cattle, Horse
//    |    '-- SmallLivestock (abstract)   -> Sheep, Goat
//    '-- Plant (abstract)
//         |-- Fruit (abstract)            -> Apple, Strawberry
//         |-- Vegetable (abstract)        -> Tomato, Carrot
//         '-- Mushroom (abstract)         -> ButtonMushroom, ShiitakeMushroom
// ============================================================================

// ---------- 11. IMPORTS ----------
// 'dart:async' gives us Future and Stream helpers, 'dart:math' gives Random.
import 'dart:async';
import 'dart:math';

/* ---------- 12. COMMENTS ----------
   This is a multi-line comment.
   // is a single-line comment, and /// is a documentation comment
   (shown by the IDE when you hover over the code it describes).
*/

// ============================================================================
//  5. ENUMS (enhanced enums can hold fields and constructors)
// ============================================================================

enum HealthStatus { healthy, sick, recovering }

enum Season {
  spring('Spring', 3),
  summer('Summer', 6),
  autumn('Autumn', 9),
  winter('Winter', 12);

  final String label;
  final int startMonth;
  const Season(this.label, this.startMonth);
}

enum FeedType {
  grain(2.5),
  hay(1.2),
  mixed(1.8);

  final double pricePerKg; // USD per kilogram
  const FeedType(this.pricePerKg);
}

// ============================================================================
//  10. EXCEPTIONS (custom exception classes)
// ============================================================================

/// Base class for every problem that can happen on our farm.
class FarmException implements Exception {
  final String message;
  const FarmException(this.message);

  @override
  String toString() => 'FarmException: $message';
}

class InsufficientFeedException extends FarmException {
  final double missingKg;

  InsufficientFeedException(this.missingKg)
      : super('Not enough feed in stock. Missing ${missingKg.toStringAsFixed(1)} kg');
}

class NotReadyForHarvestException extends FarmException {
  NotReadyForHarvestException(String plantName)
      : super('$plantName is not ready for harvest yet');
}

// ============================================================================
//  13. IMPORTANT CONCEPTS: extension methods and typedefs
// ============================================================================

/// Adds a handy getter to every double: 12.5.asKg -> "12.5 kg"
extension WeightFormatting on double {
  String get asKg => '${toStringAsFixed(1)} kg';
}

/// A function type: takes a price, returns a new price.
typedef PriceRule = double Function(double);

// ============================================================================
//  6. INTERFACES AND ABSTRACT CLASSES
// ============================================================================

/// Anything that can be sold at the farm market.
abstract interface class Sellable {
  double get marketValue;
  String describeForSale();
}

/// Anything that can print a status line.
abstract interface class Reportable {
  String report();
}

/// The root of our hierarchy: every animal and plant is a living being.
abstract class LivingBeing implements Reportable {
  static int _counter = 0; // shared by ALL living beings (static)
  static int get totalCreated => _counter;

  final int id;
  final String name;
  HealthStatus health;

  LivingBeing(this.name, {this.health = HealthStatus.healthy}) : id = ++_counter;

  String get kind; // every subclass must provide this
  void ageOneDay(); // ...and this

  @override
  String report() => '#$id $name ($kind) - ${health.name}';
}

// ============================================================================
//  7. MIXINS (reusable behavior without deep inheritance)
// ============================================================================

/// Behavior for anything that eats.
mixin Feedable {
  double get dailyFeedKg;
  FeedType get feedType;

  double dailyFeedCost() => dailyFeedKg * feedType.pricePerKg;
}

/// Behavior for animals that give a product (eggs, milk, wool).
mixin Producer {
  String get name;
  String get productName;
  String get unit;
  double get dailyOutput;

  double produceFor(int days) => dailyOutput * days;

  String describeProduction(int days) =>
      '$productName: ${produceFor(days).toStringAsFixed(1)} $unit in $days days';
}

/// Behavior for plants that can be harvested.
/// "on Plant" means only Plant subclasses can use this mixin.
mixin Harvestable on Plant {
  bool get isReady => daysPlanted >= growthDays;

  double harvest() {
    if (!isReady) throw NotReadyForHarvestException(name);
    daysPlanted = 0; // the plant starts growing again
    return expectedYieldKg;
  }
}

/// Behavior for plants that need watering.
mixin Irrigable on Plant {
  double get waterLitersPerDay;

  String irrigationPlan() => '$name needs $waterLitersPerDay L of water per day';
}

// ============================================================================
//  8. INHERITANCE - ANIMALS
// ============================================================================

abstract class Animal extends LivingBeing with Feedable implements Sellable {
  double weightKg;
  int ageMonths;

  @override
  final FeedType feedType;

  Animal(
    super.name, {
    required this.weightKg,
    required this.ageMonths,
    this.feedType = FeedType.mixed,
    super.health,
  });

  String get sound;
  double get livePricePerKg;

  @override
  double get dailyFeedKg => weightKg * 0.03; // 3% of body weight

  @override
  double get marketValue => weightKg * livePricePerKg;

  @override
  String describeForSale() =>
      '$name ($kind, ${weightKg.asKg}) - ${marketValue.toStringAsFixed(2)} USD';

  String makeSound() => '$name says "$sound!"';

  @override
  void ageOneDay() => weightKg += 0.02;

  @override
  String report() => '${super.report()} | ${weightKg.asKg}'; // extends parent's report
}

// ---- Poultry ----
abstract class Poultry extends Animal {
  Poultry(super.name, {required super.weightKg, required super.ageMonths, super.health})
      : super(feedType: FeedType.grain);

  @override
  double get livePricePerKg => 4.5;

  bool get canFly => false;
}

class Chicken extends Poultry with Producer {
  Chicken(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Chicken';
  @override
  String get sound => 'Cluck';
  @override
  String get productName => 'Eggs';
  @override
  String get unit => 'eggs';
  @override
  double get dailyOutput => 0.9;
}

class Duck extends Poultry with Producer {
  Duck(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Duck';
  @override
  String get sound => 'Quack';
  @override
  bool get canFly => true; // overrides the default from Poultry
  @override
  String get productName => 'Duck eggs';
  @override
  String get unit => 'eggs';
  @override
  double get dailyOutput => 0.6;
}

// ---- Large livestock ----
abstract class LargeLivestock extends Animal {
  LargeLivestock(super.name, {required super.weightKg, required super.ageMonths, super.health})
      : super(feedType: FeedType.hay);

  @override
  double get livePricePerKg => 6.0;

  @override
  double get dailyFeedKg => weightKg * 0.025; // big animals eat a smaller share
}

class Cattle extends LargeLivestock with Producer {
  Cattle(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Cattle';
  @override
  String get sound => 'Moo';
  @override
  String get productName => 'Milk';
  @override
  String get unit => 'liters';
  @override
  double get dailyOutput => 22.0;
}

class Horse extends LargeLivestock {
  Horse(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Horse';
  @override
  String get sound => 'Neigh';
}

// ---- Small livestock ----
abstract class SmallLivestock extends Animal {
  SmallLivestock(super.name, {required super.weightKg, required super.ageMonths, super.health})
      : super(feedType: FeedType.mixed);

  @override
  double get livePricePerKg => 7.5;
}

class Sheep extends SmallLivestock with Producer {
  Sheep(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Sheep';
  @override
  String get sound => 'Baa';
  @override
  String get productName => 'Wool';
  @override
  String get unit => 'kg';
  @override
  double get dailyOutput => 0.012;
}

class Goat extends SmallLivestock with Producer {
  Goat(super.name, {required super.weightKg, required super.ageMonths, super.health});

  @override
  String get kind => 'Goat';
  @override
  String get sound => 'Meh';
  @override
  String get productName => 'Goat milk';
  @override
  String get unit => 'liters';
  @override
  double get dailyOutput => 3.0;
}

// ============================================================================
//  8. INHERITANCE - PLANTS
// ============================================================================

abstract class Plant extends LivingBeing implements Sellable {
  int daysPlanted;
  final Season plantingSeason;

  Plant(super.name, {this.daysPlanted = 0, required this.plantingSeason, super.health});

  int get growthDays; // days needed until harvest
  double get expectedYieldKg;
  double get pricePerKg;

  @override
  double get marketValue => expectedYieldKg * pricePerKg;

  @override
  String describeForSale() =>
      '$name ($kind) - ${expectedYieldKg.asKg} at $pricePerKg USD/kg';

  @override
  void ageOneDay() => daysPlanted++;
}

// ---- Fruits ----
abstract class Fruit extends Plant with Harvestable, Irrigable {
  Fruit(super.name, {super.daysPlanted, required super.plantingSeason, super.health});

  bool get isPerennial => true; // fruit trees keep producing for years

  @override
  double get pricePerKg => 3.0;
}

class Apple extends Fruit {
  Apple(super.name, {super.daysPlanted, super.health}) : super(plantingSeason: Season.spring);

  @override
  String get kind => 'Apple';
  @override
  int get growthDays => 180;
  @override
  double get expectedYieldKg => 40;
  @override
  double get waterLitersPerDay => 15;
}

class Strawberry extends Fruit {
  Strawberry(super.name, {super.daysPlanted, super.health})
      : super(plantingSeason: Season.spring);

  @override
  String get kind => 'Strawberry';
  @override
  bool get isPerennial => false;
  @override
  int get growthDays => 60;
  @override
  double get expectedYieldKg => 6;
  @override
  double get waterLitersPerDay => 3;
  @override
  double get pricePerKg => 4.5;
}

// ---- Vegetables ----
abstract class Vegetable extends Plant with Harvestable, Irrigable {
  Vegetable(super.name, {super.daysPlanted, required super.plantingSeason, super.health});

  bool get isRootVegetable => false;

  @override
  double get pricePerKg => 1.5;
}

class Tomato extends Vegetable {
  Tomato(super.name, {super.daysPlanted, super.health}) : super(plantingSeason: Season.spring);

  @override
  String get kind => 'Tomato';
  @override
  int get growthDays => 90;
  @override
  double get expectedYieldKg => 12;
  @override
  double get waterLitersPerDay => 2.5;
}

class Carrot extends Vegetable {
  Carrot(super.name, {super.daysPlanted, super.health}) : super(plantingSeason: Season.autumn);

  @override
  String get kind => 'Carrot';
  @override
  bool get isRootVegetable => true;
  @override
  int get growthDays => 75;
  @override
  double get expectedYieldKg => 8;
  @override
  double get waterLitersPerDay => 1.2;
}

// ---- Mushrooms (harvestable, but they do not use the Irrigable mixin) ----
abstract class Mushroom extends Plant with Harvestable {
  Mushroom(super.name, {super.daysPlanted, required super.plantingSeason, super.health});

  String get substrate; // what the mushroom grows on

  @override
  double get pricePerKg => 8.0;
}

class ButtonMushroom extends Mushroom {
  ButtonMushroom(super.name, {super.daysPlanted, super.health})
      : super(plantingSeason: Season.autumn);

  @override
  String get kind => 'Button mushroom';
  @override
  String get substrate => 'compost';
  @override
  int get growthDays => 21;
  @override
  double get expectedYieldKg => 5;
}

class ShiitakeMushroom extends Mushroom {
  ShiitakeMushroom(super.name, {super.daysPlanted, super.health})
      : super(plantingSeason: Season.autumn);

  @override
  String get kind => 'Shiitake mushroom';
  @override
  String get substrate => 'oak logs';
  @override
  int get growthDays => 60;
  @override
  double get expectedYieldKg => 3;
  @override
  double get pricePerKg => 15.0; // premium price
}

// ============================================================================
//  5. CLASSES - the Farm itself
// ============================================================================

class Farm {
  final String name;
  double feedStockKg;
  final List<LivingBeing> _beings = []; // private: the underscore hides it
  final Map<String, double> harvestLog = {};

  Farm(this.name, {this.feedStockKg = 0}) : assert(feedStockKg >= 0);

  /// Factory constructor: builds a ready-to-use demo farm.
  factory Farm.sample({required String name, double feedStockKg = 50}) {
    final farm = Farm(name, feedStockKg: feedStockKg);
    farm
      ..register(Chicken('Henrietta', weightKg: 2.5, ageMonths: 14))
      ..register(Chicken('Cluckers', weightKg: 2.2, ageMonths: 9))
      ..register(Duck('Donald', weightKg: 3.0, ageMonths: 12))
      ..register(Cattle('Bella', weightKg: 650, ageMonths: 48))
      ..register(Horse('Thunder', weightKg: 520, ageMonths: 70))
      ..register(Sheep('Dolly', weightKg: 75, ageMonths: 30))
      ..register(Goat('Billy', weightKg: 55, ageMonths: 20))
      ..register(Apple('Golden Apple Tree', daysPlanted: 200))
      ..register(Strawberry('Strawberry Patch', daysPlanted: 30))
      ..register(Tomato('Tomato Row A', daysPlanted: 95))
      ..register(Carrot('Carrot Field', daysPlanted: 40))
      ..register(ButtonMushroom('Mushroom Shed 1', daysPlanted: 21))
      ..register(ShiitakeMushroom('Shiitake Logs', daysPlanted: 10));
    return farm;
  }

  void register(LivingBeing being) {
    if (findByName(being.name) != null) {
      throw FarmException('"${being.name}" is already registered');
    }
    _beings.add(being);
  }

  // ignore: unintended_html_in_doc_comment
  /// Generic method: ofType<Animal>() or ofType<Plant>() filters by type.
  List<T> ofType<T extends LivingBeing>() => _beings.whereType<T>().toList();

  /// Returns null when nothing matches (note the "?" nullable return type).
  LivingBeing? findByName(String query) {
    for (final being in _beings) {
      if (being.name.toLowerCase() == query.toLowerCase()) return being;
    }
    return null;
  }

  /// A record with named fields.
  ({int animals, int plants}) census() =>
      (animals: ofType<Animal>().length, plants: ofType<Plant>().length);

  /// Feeds every animal for one day. Throws if the stock is too low.
  double feedAnimals() {
    final animals = ofType<Animal>();
    final needed = animals.fold<double>(0, (sum, a) => sum + a.dailyFeedKg);
    if (needed > feedStockKg) {
      throw InsufficientFeedException(needed - feedStockKg);
    }
    feedStockKg -= needed;
    return needed;
  }

  void restock(double kg) => feedStockKg += kg;

  double dailyFeedCost() =>
      ofType<Animal>().fold<double>(0, (sum, a) => sum + a.dailyFeedCost());

  // ---------- 9. ASYNC ----------

  /// Simulates a vet visit that takes time.
  Future<void> vetCheck(Random rng) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final animal in ofType<Animal>()) {
      animal.health =
          rng.nextDouble() < 0.25 ? HealthStatus.sick : HealthStatus.healthy;
    }
    print('  [vet] Health check finished.');
  }

  Future<void> soilCheck() async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('  [soil] Analysis finished: pH 6.5, nitrogen level OK.');
  }

  /// Harvests every ready crop; returns the total kilograms collected.
  Future<double> harvestAll() async {
    var total = 0.0;
    var attempts = 0;

    for (final plant in ofType<Plant>()) {
      // Pattern matching: is this plant Harvestable? If so, bind it to "crop".
      if (plant case final Harvestable crop) {
        await Future.delayed(const Duration(milliseconds: 150));
        try {
          final kg = crop.harvest();
          total += kg;
          harvestLog[plant.name] = (harvestLog[plant.name] ?? 0) + kg;
          print('  [OK]   Harvested ${plant.name}: ${kg.asKg}');
        } on NotReadyForHarvestException catch (e) {
          print('  [WAIT] ${e.message} (${plant.daysPlanted}/${plant.growthDays} days)');
        } finally {
          attempts++; // runs whether or not an exception happened
        }
      }
    }
    print('  Harvest attempts: $attempts');
    return total;
  }

  /// A Stream emits values over time. "async*" + "yield" create one.
  Stream<String> dailyReports(int days) async* {
    for (var day = 1; day <= days; day++) {
      await Future.delayed(const Duration(milliseconds: 150));
      for (final being in _beings) {
        being.ageOneDay();
      }
      final ready = ofType<Plant>()
          .whereType<Harvestable>()
          .where((crop) => crop.isReady)
          .length;
      final herdWeight =
          ofType<Animal>().fold<double>(0, (sum, a) => sum + a.weightKg);
      yield 'Day $day | herd weight: ${herdWeight.asKg} | crops ready: $ready';
    }
  }
}

// ============================================================================
//  4. FUNCTIONS
// ============================================================================

/// Prints a section title. Parameters: one required positional.
void section(String title) {
  final bar = '=' * 56;
  print('\n$bar\n  $title\n$bar');
}

// ignore: unintended_html_in_doc_comment
/// Arrow function (single expression) with a generic Iterable<Sellable>.
double totalValue(Iterable<Sellable> items) =>
    items.fold(0.0, (sum, item) => sum + item.marketValue);

/// Function with OPTIONAL NAMED parameters and default values.
String priceTag(double value, {String currency = 'USD', int decimals = 2}) =>
    '${value.toStringAsFixed(decimals)} $currency';

/// Switch EXPRESSION on an enum (the compiler checks every case is covered).
String seasonAdvice(Season season) => switch (season) {
      Season.spring => 'Plant seedlings and vaccinate newborn animals.',
      Season.summer => 'Increase irrigation and give livestock shade.',
      Season.autumn => 'Harvest crops and store hay for the winter.',
      Season.winter => 'Keep barns warm and check the feed stock weekly.',
    };

/// Switch expression with TYPE patterns - order matters, first match wins.
String classify(LivingBeing being) => switch (being) {
      Poultry() => 'Poultry (small birds)',
      LargeLivestock() => 'Large livestock',
      SmallLivestock() => 'Small livestock',
      Fruit() => 'Fruit',
      Vegetable() => 'Vegetable',
      Mushroom() => 'Mushroom',
      _ => 'Unknown',
    };

// ============================================================================
//  1. HELLO WORLD - every Dart program starts at main()
// ============================================================================

Future<void> main() async {
  print('Hello, World! Welcome to the Big Farm Management System.');

  // --------------------------------------------------------------------------
  section('2. VARIABLES');
  // --------------------------------------------------------------------------
  const farmName = 'Green Valley Farm'; // compile-time constant
  final foundedYear = 2015; // assigned once, never changes
  var feedStock = 50.0; // type inferred (double), can change
  int workers = 8; // explicit type
  String? manager; // nullable: can hold a String or null
  late final Farm farm; // assigned later, exactly once

  print('Farm: $farmName (founded $foundedYear, $workers workers)');
  print('Manager: ${manager ?? 'not assigned yet'}'); // ?? = "if null, use this"
  manager = 'Maria';
  print('Manager now: $manager (${manager.length} characters)');

  farm = Farm.sample(name: farmName, feedStockKg: feedStock);
  final animals = farm.ofType<Animal>();
  final plants = farm.ofType<Plant>();

  // --------------------------------------------------------------------------
  section('3. CONTROL FLOW');
  // --------------------------------------------------------------------------
  final census = farm.census();
  print('Census -> animals: ${census.animals}, plants: ${census.plants}');

  // if / else if / else
  if (census.animals > census.plants) {
    print('This is mainly a livestock farm.');
  } else if (census.animals < census.plants) {
    print('This is mainly a crop farm.');
  } else {
    print('A perfectly balanced farm!');
  }

  // Season from the current month, then a switch expression
  final month = DateTime.now().month;
  final season = Season.values.lastWhere(
    (s) => month >= s.startMonth,
    orElse: () => Season.winter,
  );
  print('Season: ${season.label} -> ${seasonAdvice(season)}');

  // for-in loop with continue
  print('Barn sounds:');
  for (final animal in animals) {
    if (animal is Horse) continue; // the horse is out in the field
    print('  ${animal.makeSound()}');
  }

  // while loop with try/catch (feeding for 3 days) -> see section 10 too
  var day = 1;
  while (day <= 3) {
    try {
      final used = farm.feedAnimals();
      print('Day $day: fed all animals with ${used.asKg}. '
          'Stock left: ${farm.feedStockKg.asKg}');
    } on InsufficientFeedException catch (e) {
      print('Day $day: ${e.message}');
      farm.restock(100); // emergency delivery
      print('         Restocked 100 kg. Stock: ${farm.feedStockKg.asKg}');
    }
    day++;
  }

  // Collection-if and collection-for build lists in one expression
  final labels = [
    for (final a in animals)
      if (a.weightKg > 100) '${a.name} (heavy)' else a.name,
  ];
  print('Animal labels: ${labels.join(', ')}');

  // --------------------------------------------------------------------------
  section('5. CLASSES & ENUMS - classification');
  // --------------------------------------------------------------------------
  for (final being in [...animals, ...plants]) {
    print('  ${being.name.padRight(20)} -> ${classify(being)}');
  }
  print('Seasons: ${Season.values.map((s) => s.label).join(' | ')}');
  print('Feed types: ${FeedType.values.map((f) => '${f.name} (${f.pricePerKg}/kg)').join(', ')}');
  print('Total living beings created: ${LivingBeing.totalCreated}');

  // --------------------------------------------------------------------------
  section('7. MIXINS in action');
  // --------------------------------------------------------------------------
  print('Weekly production (Producer mixin):');
  for (final p in animals.whereType<Producer>()) {
    print('  ${p.name.padRight(10)} ${p.describeProduction(7)}');
  }
  print('Irrigation plans (Irrigable mixin):');
  for (final p in plants.whereType<Irrigable>()) {
    print('  ${p.irrigationPlan()}');
  }
  print('Daily feed cost (Feedable mixin): ${priceTag(farm.dailyFeedCost())}');

  // --------------------------------------------------------------------------
  section('6. INTERFACES - the Sellable catalog');
  // --------------------------------------------------------------------------
  // Animals AND plants are Sellable, so they can live in one list.
  final List<Sellable> catalog = [...animals, ...plants];
  catalog.sort((a, b) => b.marketValue.compareTo(a.marketValue)); // high -> low

  print('Top 3 items by value:');
  for (final item in catalog.take(3)) {
    print('  ${item.describeForSale()}');
  }

  // Closures stored in a typedef'd variable
  PriceRule seasonalDiscount = (value) => value * 0.9;
  final discounted = seasonalDiscount(totalValue(catalog));
  print('Total market value: ${priceTag(totalValue(catalog), decimals: 0)}');
  print('With 10% discount : ${priceTag(discounted, currency: 'EUR', decimals: 0)}');

  // --------------------------------------------------------------------------
  section('9. ASYNC - Future, Future.wait, Stream');
  // --------------------------------------------------------------------------
  final rng = Random(7); // fixed seed -> same output on every run
  print('Starting vet visit and soil analysis in parallel...');
  await Future.wait([farm.vetCheck(rng), farm.soilCheck()]);

  final sick = [
    for (final a in animals)
      if (a.health == HealthStatus.sick) a.name,
  ];
  print('Sick animals: ${sick.isEmpty ? 'none' : sick.join(', ')}');

  print('\nHarvest time (sequential awaits):');
  final harvested = await farm.harvestAll();
  print('Total harvested: ${harvested.asKg}');

  print('\nSimulating 3 days with a Stream:');
  await for (final report in farm.dailyReports(3)) {
    print('  $report');
  }

  // --------------------------------------------------------------------------
  section('10. EXCEPTIONS');
  // --------------------------------------------------------------------------
  // (a) Duplicate name -> our own FarmException
  try {
    farm.register(Chicken('Henrietta', weightKg: 2.0, ageMonths: 3));
  } on FarmException catch (e) {
    print('Caught: $e');
  }

  // (b) Harvesting too early -> specific exception type
  try {
    final carrot = farm.findByName('Carrot Field')!; // "!" = I know it is not null
    if (carrot case final Harvestable crop) crop.harvest();
  } on NotReadyForHarvestException catch (e) {
    print('Caught: ${e.message}');
  }

  // (c) A generic catch with stack trace, and finally
  try {
    farm.restock(-500);
    farm.feedStockKg = -1; // allowed by the language, but let's validate
    throw StateError('Negative feed stock is impossible!');
  } on StateError catch (e, stackTrace) {
    print('Caught StateError: ${e.message}');
    print('  (stack trace has ${stackTrace.toString().split('\n').length} lines)');
  } catch (e) {
    print('Caught something unexpected: $e');
  } finally {
    farm.feedStockKg = 100; // always runs: reset to a safe value
    print('Cleanup done. Feed stock reset to ${farm.feedStockKg.asKg}');
  }

  // (d) Looking up a missing animal returns null instead of crashing
  final ghost = farm.findByName('Unicorn');
  print('Unicorn found? ${ghost != null}  ->  ${ghost?.report() ?? 'no such animal'}');

  // --------------------------------------------------------------------------
  section('13. IMPORTANT CONCEPTS - quick recap');
  // --------------------------------------------------------------------------
  // Records and destructuring
  final (animalCount, plantCount) = (census.animals, census.plants);
  print('Destructured record: $animalCount animals, $plantCount plants');

  // Cascade operator (..) and null-aware access (?.)
  final newFarm = Farm('Tiny Farm')
    ..restock(10)
    ..register(Goat('Gizmo', weightKg: 30, ageMonths: 6));
  print('Cascade result: ${newFarm.name} has ${newFarm.ofType<Animal>().length} animal(s)');
  print('Null-aware: ${newFarm.findByName('nobody')?.name ?? 'nobody'}');

  // Generics + higher-order functions: map / where / fold / sort
  final heavyAnimals = animals.where((a) => a.weightKg > 50).map((a) => a.name).toList();
  print('Animals over 50 kg: $heavyAnimals');

  // Extension method and string interpolation
  print('Herd weight: ${animals.fold<double>(0, (s, a) => s + a.weightKg).asKg}');

  // Harvest log (a Map)
  print('Harvest log:');
  farm.harvestLog.forEach((plant, kg) => print('  $plant -> ${kg.asKg}'));

  print('\nGoodbye from $farmName!');
}