// Validate Name
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null; // Return null if valid
}

//Email validations
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null; // Return null if valid
}

// Validate Password
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null; // Return null if valid
}

// Validate Password with strong security standard
String? validatePasswordNewStandard(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter password';
  }

  if (value.length < 6) {
    return 'Min. 6 characters';
  }

  final hasUppercase = RegExp(r'[A-Z]');
  final hasLowercase = RegExp(r'[a-z]');
  final hasDigit = RegExp(r'\d');
  final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  final hasNoSpace = !RegExp(r'\s').hasMatch(value);

  if (!hasUppercase.hasMatch(value)) {
    return 'Add uppercase letter';
  }
  if (!hasLowercase.hasMatch(value)) {
    return 'Add lowercase letter';
  }
  if (!hasDigit.hasMatch(value)) {
    return 'Add number';
  }
  if (!hasSpecialChar.hasMatch(value)) {
    return 'Add special character';
  }
  if (!hasNoSpace) {
    return 'No spaces allowed';
  }

  return null; // Password is valid
}

//Validate phone
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  }
  final regex = RegExp(r'^\+?[0-9]{10,15}$'); // Adjust regex for phone format
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid phone number';
  }
  return null; // Return null if valid
}

// Validate Location (if required)
String? validateLocation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please press the location icon';
  }
  return null; // Return null if valid
}

// Validate Location in the Add New Address
String? validateLocationNewAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an address';
  }
  return null; // Return null if valid
}


