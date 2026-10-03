import 'dart:io';

// ============================================================
// 3. OOP: Product class
// ============================================================
class Product {
  final String name; // Product name
  final double price; // Product price

  Product(this.name, this.price);

  @override
  String toString() => '$name - \$${price.toStringAsFixed(2)}';
}

// ============================================================
// 3. OOP: ShoppingCart class
// ============================================================
class ShoppingCart {
  final List<Product> products = []; // List of Product objects
  double totalPrice = 0; // Total price of the cart

  // Adds a product to the cart and updates the total automatically
  void addProduct(Product product) {
    products.add(product);
    calculateTotal();
  }

  // Calculates the total price of all products in the cart
  double calculateTotal() {
    totalPrice = 0;
    for (final product in products) {
      totalPrice += product.price;
    }
    return totalPrice;
  }

  // Displays all products added so far as a list
  void showProducts() {
    print('\n--- Your Cart ---');
    for (int i = 0; i < products.length; i++) {
      print('${i + 1}. ${products[i]}');
    }
    print('Total: \$${totalPrice.toStringAsFixed(2)}');
    print('-----------------');
  }
}

void main() {
  // ==========================================================
  // 1. Variables
  // ==========================================================
  int age = 0; // User's age
  int customerNo = 0; // Customer number
  double totalAmount = 0; // Total shopping amount

  // Ask for age (repeat until a valid value is entered)
  while (true) {
    stdout.write('Enter your age: ');
    final input = int.tryParse(stdin.readLineSync() ?? '');
    if (input != null && input > 0) {
      age = input;
      break;
    }
    print('Invalid age, please try again.');
  }

  // Ask for customer number (repeat until a valid value is entered)
  while (true) {
    stdout.write('Enter your customer number: ');
    final input = int.tryParse(stdin.readLineSync() ?? '');
    if (input != null && input > 0) {
      customerNo = input;
      break;
    }
    print('Invalid customer number, please try again.');
  }

  // ==========================================================
  // 2. Loop: add products until the user types 'q'
  // ==========================================================
  final cart = ShoppingCart();

  print('\nEnter product details. Type "q" as the product name to finish.');

  while (true) {
    stdout.write('\nProduct name (q to quit): ');
    final name = (stdin.readLineSync() ?? '').trim();

    if (name.toLowerCase() == 'q') {
      break; // Exit the loop
    }
    if (name.isEmpty) {
      print('Product name cannot be empty.');
      continue;
    }

    stdout.write('Product price: ');
    final price = double.tryParse((stdin.readLineSync() ?? '').replaceAll(',', '.'));

    if (price == null || price < 0) {
      print('Invalid price, product was not added.');
      continue;
    }

    // Product is added through the ShoppingCart class
    cart.addProduct(Product(name, price));

    // Total is calculated by the ShoppingCart method
    totalAmount = cart.calculateTotal();

    // Show all products added so far after each addition
    cart.showProducts();
  }

  // ==========================================================
  // 1. Decision structure: age-based discount (if-else)
  // ==========================================================
  double discountRate;

  if (age < 18) {
    discountRate = 0.10; // 10% discount
  } else if (age <= 60) {
    discountRate = 0.05; // 5% discount (ages 18-60)
  } else {
    discountRate = 0.15; // 15% discount (over 60)
  }

  final discountAmount = totalAmount * discountRate;
  final finalAmount = totalAmount - discountAmount;

  // ==========================================================
  // Order summary
  // ==========================================================
  print('\n========== ORDER SUMMARY ==========');
  print('Customer No     : $customerNo');
  print('Age             : $age');
  print('Number of items : ${cart.products.length}');
  print('Subtotal        : \$${totalAmount.toStringAsFixed(2)}');
  print('Discount rate   : ${(discountRate * 100).toStringAsFixed(0)}%');
  print('Discount amount : \$${discountAmount.toStringAsFixed(2)}');
  print('Amount to pay   : \$${finalAmount.toStringAsFixed(2)}');
  print('===================================');
}