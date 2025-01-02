import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';

class RegistrationFormState {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String country;
  final String state;
  final String city;
  final Map<String, String?> errors;
  final bool isValid;
  final bool isLoading;

  RegistrationFormState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.country = '',
    this.state = '',
    this.city = '',
    this.errors = const {},
    this.isValid = false,
    this.isLoading = false,
  });

  RegistrationFormState copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? country,
    String? state,
    String? city,
    Map<String, String?>? errors,
    bool? isValid,
    bool? isLoading,
  }) {
    return RegistrationFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

abstract class FormEvent {}

class UpdateField extends FormEvent {
  final String field;
  final String value;
  UpdateField(this.field, this.value);
}

class SubmitForm extends FormEvent {}

class FormBloc extends Bloc<FormEvent, RegistrationFormState> {
  FormBloc() : super(RegistrationFormState()) {
    on<UpdateField>(_onUpdateField);
    on<SubmitForm>(_onSubmitForm);
  }

  void _onUpdateField(UpdateField event, Emitter<RegistrationFormState> emit) {
    final newState = _updateField(event.field, event.value);
    emit(newState);
  }

  void _onSubmitForm(SubmitForm event, Emitter<RegistrationFormState> emit) {
    final validatedState = _validateAll();
    if (validatedState.isValid) {
      // Handle form submission
      print('Form submitted with data:');
      print('Name: ${validatedState.name}');
      print('Email: ${validatedState.email}');
      print('Phone: ${validatedState.phone}');
      print('Gender: ${validatedState.gender}');
      print('Country: ${validatedState.country}');
      print('State: ${validatedState.state}');
      print('City: ${validatedState.city}');
    }
    emit(validatedState);
  }

  RegistrationFormState _updateField(String field, String value) {
    final Map<String, String?> errors = Map.from(state.errors);
    errors[field] = _validateField(field, value);

    return state.copyWith(
      name: field == 'name' ? value : state.name,
      email: field == 'email' ? value : state.email,
      phone: field == 'phone' ? value : state.phone,
      gender: field == 'gender' ? value : state.gender,
      country: field == 'country' ? value : state.country,
      state: field == 'state' ? value : state.state,
      city: field == 'city' ? value : state.city,
      errors: errors,
      isValid: !errors.values.any((error) => error != null),
    );
  }

  String? _validateField(String field, String value) {
    switch (field) {
      case 'name':
        if (value.isEmpty) return 'Name is required';
        if (value.length < 2) return 'Name must be at least 2 characters';
        return null;
      case 'email':
        if (value.isEmpty) return 'Email is required';
        if (!EmailValidator.validate(value)) return 'Invalid email format';
        return null;
      case 'phone':
        if (value.isEmpty) return 'Phone is required';
        if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Invalid phone number';
        return null;
      case 'gender':
        if (value.isEmpty) return 'Gender is required';
        return null;
      case 'country':
        if (value.isEmpty) return 'Country is required';
        return null;
      case 'state':
        if (value.isEmpty) return 'State is required';
        return null;
      case 'city':
        if (value.isEmpty) return 'City is required';
        return null;
      default:
        return null;
    }
  }

  RegistrationFormState _validateAll() {
    final Map<String, String?> errors = {
      'name': _validateField('name', state.name),
      'email': _validateField('email', state.email),
      'phone': _validateField('phone', state.phone),
      'gender': _validateField('gender', state.gender),
      'country': _validateField('country', state.country),
      'state': _validateField('state', state.state),
      'city': _validateField('city', state.city),
    };

    return state.copyWith(
      errors: errors,
      isValid: !errors.values.any((error) => error != null),
    );
  }
}
