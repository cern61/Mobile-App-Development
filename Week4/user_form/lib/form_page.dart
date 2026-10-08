import 'package:flutter/material.dart';

/// Page 2: user registration form.
class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  String? gender;
  DateTime? birthDate;
  int? age;

  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthDate = pickedDate;
        age = calculateAge(pickedDate);
      });
    }
  }

  /// Calculates age; subtracts one year if the birthday has not happened yet.
  int calculateAge(DateTime birth) {
    final DateTime today = DateTime.now();

    int calculatedAge = today.year - birth.year;

    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      calculatedAge--;
    }

    return calculatedAge;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    final String digits = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return RegExp(r'^\d{10,15}$').hasMatch(digits);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void clearForm() {
    setState(() {
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      emailController.clear();
      cityController.clear();
      gender = null;
      birthDate = null;
      age = null;
    });
  }

  Future<void> register() async {
    if (gender == null ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        birthDate == null ||
        cityController.text.trim().isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (!isValidPhone(phoneController.text.trim())) {
      showMessage('Please enter a valid phone number.');
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      showMessage('Please enter a valid email address.');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: Text(
            'Registered!\n\n'
            'Name: ${firstNameController.text.trim()} ${lastNameController.text.trim()}\n'
            'Age: $age\n'
            'Gender: $gender\n'
            'Phone: ${phoneController.text.trim()}\n'
            'Email: ${emailController.text.trim()}\n'
            'City: ${cityController.text.trim()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // After the popup is closed, go back to the home page.
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: genderOptions
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  gender = value;
                });
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: Colors.grey),
              ),
              title: Text(
                birthDate == null
                    ? 'Select birth date'
                    : '${birthDate!.day}.${birthDate!.month}.${birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: pickDate,
            ),
            const SizedBox(height: 15),
            if (age != null)
              Text(
                'Age: $age',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (age != null) const SizedBox(height: 15),
            TextField(
              controller: cityController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City of Residence',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: clearForm,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
