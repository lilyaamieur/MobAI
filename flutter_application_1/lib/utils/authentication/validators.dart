class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Please enter a valid full name';
    }
    return null; //valid fullname
  }

  static String? validateEmailORphone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or Phone number is required';
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (emailRegex.hasMatch(value)) {
      return null; //valid email
    }
    // regex for valid phone numbers:
    //  starts with +213 followed by 9 digits
    //  starts with 05, 06, or 07 followed by 8 digits
    final phoneRegex =
        RegExp(r"^(?:\+213(?:5[0-9]|6[0-9]|7[0-9])\d{7}|(05|06|07)\d{8})$");
    if (phoneRegex.hasMatch(value)) {
      return null; //valid phone number
    }
    return 'Please Enter a Valid Phone Number or Email';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final capitalLetterRegex = RegExp(r'[A-Z]');
    if (!capitalLetterRegex.hasMatch(value)) {
      return 'Password should have at least one capital letter';
    }
    if (value.length < 8) {
      return 'Password should be at least 8 characters long';
    }
    return null;
  }
}
