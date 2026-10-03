// ignore_for_file: avoid_print
// ============================================================
//  🛒 SIMPLE SHOPPING CART APPLICATION  -  Dart Homework
//  Topics: Variables, if-else, while loop, Classes (OOP)
//  Run with:  dart run shopping_cart.dart
// ============================================================

import 'dart:io';

// ------------------------------------------------------------
//  🎨 Small helpers for colorful output
// ------------------------------------------------------------
const String reset = '\x1B[0m';
const String bold = '\x1B[1m';
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String blue = '\x1B[34m';
const String magenta = '\x1B[35m';
const String cyan = '\x1B[36m';
const String gray = '\x1B[90m';

String paint(String text, String color) => '$color$text$reset';

String ask(String question) {
  stdout.write(paint('  ➜ $question ', yellow));
  return (stdin.readLineSync() ?? '').trim();
}

/// Keeps asking until the user types a valid whole number in range.
int readInt(String question, {required int min, required int max}) {
  while (true) {
    final value = int.tryParse(ask(question));
    if (value != null && value >= min && value <= max) return value;
    print(paint('  ✘ Please enter a whole number between $min and $max.', red));
  }
}

/// Keeps asking until the user types a valid positive price.
double readPrice(String question) {
  while (true) {
    // Accept both "12.5" and "12,5"
    final value = double.tryParse(ask(question).replaceAll(',', '.'));
    if (value != null && value > 0) return value;
    print(paint('  ✘ Please enter a valid price greater than 0.', red));
  }
}

String money(double value) => '${value.toStringAsFixed(2)} ₺';

// ------------------------------------------------------------
//  📦 PRODUCT  (name + price, encapsulated)
// ------------------------------------------------------------
class Product {
  final String _name;
  final double _price;

  Product(this._name, this._price);

  String get name => _name;
  double get price => _price;
}

// ------------------------------------------------------------
//  🛒 SHOPPING CART  (list of products + total price)
// ------------------------------------------------------------
class ShoppingCart {
  final List<Product> _products = [];
  double _totalPrice = 0;

  /// Read-only views, so outside code cannot change the data directly.
  List<Product> get products => List.unmodifiable(_products);
  double get totalPrice => _totalPrice;
  bool get isEmpty => _products.isEmpty;

  /// Adds a product to the cart and refreshes the total.
  void addProduct(Product product) {
    _products.add(product);
    calculateTotal();
  }

  /// Calculates the total price of all products in the cart.
  double calculateTotal() {
    _totalPrice = 0;
    for (final product in _products) {
      _totalPrice += product.price;
    }
    return _totalPrice;
  }
}

// ------------------------------------------------------------
//  🖨️ Display functions
// ------------------------------------------------------------
void printBanner() {
  print(paint('╔══════════════════════════════════════════════╗', blue));
  print(paint('║', blue) +
      paint('          🛒  SIMPLE SHOPPING CART  🛒         ', bold + cyan) +
      paint('║', blue));
  print(paint('╚══════════════════════════════════════════════╝', blue));
}

void printCart(ShoppingCart cart) {
  final line = paint('  ${'─' * 44}', gray);
  print('\n${paint('  🛒 YOUR CART', bold + cyan)}');
  print(line);
  final items = cart.products;
  for (var i = 0; i < items.length; i++) {
    var name = items[i].name;
    if (name.length > 22) name = '${name.substring(0, 21)}…';
    print('  ${(i + 1).toString().padLeft(2)}. ${name.padRight(22)}'
        '${items[i].price.toStringAsFixed(2).padLeft(14)} ₺');
  }
  print(line);
  print(paint(
      '  ${'TOTAL'.padRight(26)}${cart.totalPrice.toStringAsFixed(2).padLeft(14)} ₺',
      bold + green));
  print('');
}

// ------------------------------------------------------------
//  🚀 MAIN
// ------------------------------------------------------------
void main() {
  print('\x1B[2J\x1B[H'); // clear the screen
  printBanner();

  // ----- 1. VARIABLES -----------------------------------------
  print(paint('\n  👤 Customer information', bold));
  int age = readInt('Enter your age:', min: 1, max: 120);
  int customerNumber = readInt('Enter your customer number:', min: 1, max: 999999);
  double totalAmount = 0; // total shopping amount

  // ----- 2. LOOP (while) --------------------------------------
  final cart = ShoppingCart();

  print(paint('\n  ➕ Add products to your cart', bold));
  print(paint("  (type 'q' as the product name to finish shopping)\n", gray));

  while (true) {
    final name = ask('Product name:');

    if (name.toLowerCase() == 'q') {
      break; // user finished shopping
    }
    if (name.isEmpty) {
      print(paint('  ✘ Product name cannot be empty.', red));
      continue;
    }

    final price = readPrice('Price of "$name":');

    // Add through the cart class, total is calculated by the cart method
    cart.addProduct(Product(name, price));
    totalAmount = cart.calculateTotal();

    print(paint('\n  ✔ "$name" added!', green));
    printCart(cart); // show ALL products added so far
  }

  // ----- 3. EMPTY CART CHECK ----------------------------------
  if (cart.isEmpty) {
    print(paint('\n  Your cart is empty. See you next time! 👋\n', yellow));
    return;
  }

  // ----- 4. DECISION STRUCTURE (if-else) ----------------------
  double discountRate;
  String category;

  if (age < 18) {
    discountRate = 0.10; // under 18  -> 10%
    category = 'Under 18';
  } else if (age <= 60) {
    discountRate = 0.05; // 18-60     -> 5%
    category = '18 - 60';
  } else {
    discountRate = 0.15; // over 60   -> 15%
    category = 'Over 60';
  }

  final discountAmount = totalAmount * discountRate;
  final finalAmount = totalAmount - discountAmount;

  // ----- 5. RECEIPT -------------------------------------------
  const width = 44;
  print(paint('\n  ${'═' * width}', magenta));
  print(paint('  🧾 RECEIPT', bold + magenta));
  print(paint('  ${'═' * width}', magenta));
  print('  Customer No     : ${paint('#$customerNumber', cyan)}');
  print('  Age             : $age  ${paint('($category)', gray)}');
  print('  Items           : ${cart.products.length}');
  print('  Subtotal        : ${money(totalAmount)}');
  print('  Discount        : ${paint('-${money(discountAmount)}  '
      '(${(discountRate * 100).toStringAsFixed(0)}%)', yellow)}');
  print(paint('  ${'─' * width}', gray));
  print(paint('  AMOUNT TO PAY   : ${money(finalAmount)}', bold + green));
  print(paint('\n  Thank you for shopping with us! 🎉\n', cyan));
}