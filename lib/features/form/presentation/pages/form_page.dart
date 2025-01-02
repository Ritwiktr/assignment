import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csc_picker/csc_picker.dart';
import '../bloc/form_bloc.dart';

class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D3250),
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF2D3250),
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider(
        create: (context) => FormBloc(),
        child: const FormContent(),
      ),
    );
  }
}

class FormContent extends StatelessWidget {
  const FormContent({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8F3FF),
            const Color(0xFFF5F7FF),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: BlocBuilder<FormBloc, RegistrationFormState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: screenHeight * 0.03),
                  ..._buildFormFields(context, state),
                  SizedBox(height: screenHeight * 0.04),
                  _buildSubmitButton(context, state),
                ],
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenWidth * 0.015,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF7077A1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rocket_launch,
                color: const Color(0xFF7077A1),
                size: screenWidth * 0.045,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Quick Registration',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7077A1),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
        ).animate().scale(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
            ),
        SizedBox(height: screenWidth * 0.04),
        Text(
          'Join Us Today!',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3250),
          ),
        ).animate().slideX(
              begin: -0.2,
              end: 0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
            ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          'Fill in your details to get started',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04,
            color: const Color(0xFF424769),
          ),
        ).animate().slideX(
              begin: -0.2,
              end: 0,
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  List<Widget> _buildFormFields(
      BuildContext context, RegistrationFormState state) {
    return [
      _buildAnimatedField(
        child: _buildTextField(
          context,
          'name',
          'Full Name',
          state.name,
          state.errors['name'],
          Icons.person_outline,
        ),
        delay: 0,
      ),
      _buildAnimatedField(
        child: _buildTextField(
          context,
          'email',
          'Email Address',
          state.email,
          state.errors['email'],
          Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        delay: 1,
      ),
      _buildAnimatedField(
        child: _buildTextField(
          context,
          'phone',
          'Phone Number',
          state.phone,
          state.errors['phone'],
          Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        delay: 2,
      ),
      _buildAnimatedField(
        child: _buildEnhancedGenderDropdown(
          context,
          'gender',
          'Gender',
          state.gender,
          state.errors['gender'],
        ),
        delay: 3,
      ),
      _buildAnimatedField(
        child: _buildLocationPicker(context, state),
        delay: 4,
      ),
    ];
  }

  Widget _buildEnhancedGenderDropdown(
    BuildContext context,
    String field,
    String label,
    String value,
    String? error,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    IconData getGenderIcon(String value) {
      switch (value) {
        case 'Male':
          return Icons.male;
        case 'Female':
          return Icons.female;
        default:
          return Icons.people_outline;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE8F3FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7077A1).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            prefixIcon: Icon(
              getGenderIcon(value),
              color: const Color(0xFF7077A1),
              size: screenWidth * 0.06,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.04,
            ),
          ),
          items: [
            _buildGenderMenuItem('Male', Icons.male),
            _buildGenderMenuItem('Female', Icons.female),
            _buildGenderMenuItem('Other', Icons.people_outline),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<FormBloc>().add(UpdateField(field, value));
            }
          },
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildGenderMenuItem(String value, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7077A1)),
          const SizedBox(width: 12),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Widget _buildLocationPicker(
      BuildContext context, RegistrationFormState state) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFE8F3FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7077A1).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: CSCPicker(
          layout: Layout.vertical,
          flagState: CountryFlag.ENABLE,
          onCountryChanged: (country) {
            context.read<FormBloc>().add(UpdateField('country', country));
          },
          onStateChanged: (state) {
            context.read<FormBloc>().add(
                  UpdateField('state', state ?? ''),
                );
          },
          onCityChanged: (city) {
            context.read<FormBloc>().add(
                  UpdateField('city', city ?? ''),
                );
          },
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          defaultCountry: CscCountry.United_States,
          disabledDropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          selectedItemStyle: GoogleFonts.poppins(
            color: const Color(0xFF2D3250),
            fontSize: screenWidth * 0.035,
          ),
          dropdownHeadingStyle: GoogleFonts.poppins(
            color: const Color(0xFF2D3250),
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
          dropdownItemStyle: GoogleFonts.poppins(
            color: const Color(0xFF2D3250),
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({
    required Widget child,
    required int delay,
  }) {
    return child
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * delay),
          duration: const Duration(milliseconds: 500),
        )
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 100 * delay),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
  }

  Widget _buildTextField(
    BuildContext context,
    String field,
    String label,
    String value,
    String? error,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFE8F3FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7077A1).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          initialValue: value,
          onChanged: (value) {
            context.read<FormBloc>().add(UpdateField(field, value));
          },
          keyboardType: keyboardType,
          style: TextStyle(fontSize: screenWidth * 0.04),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: screenWidth * 0.04),
            errorText: error,
            errorStyle: TextStyle(fontSize: screenWidth * 0.035),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF7077A1),
              size: screenWidth * 0.06,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.04,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, RegistrationFormState state) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7077A1),
            const Color(0xFF2D3250),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7077A1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state.isValid
            ? () {
                context.read<FormBloc>().add(SubmitForm());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Registration Successful!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back to homepage after successful registration
                Navigator.pushReplacementNamed(context, '/home');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: state.isValid ? Colors.white : Colors.white70,
              ),
            ),
            if (state.isValid) ...[
              SizedBox(width: screenWidth * 0.02),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(
          delay: const Duration(milliseconds: 800),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }
}
