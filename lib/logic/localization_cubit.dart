import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class LocalizationState {
  final Locale locale;
  const LocalizationState(this.locale);
}

// Cubit
class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit() : super(const LocalizationState(Locale('ar'))); // Default Arabic

  void switchLanguage(String languageCode) {
    emit(LocalizationState(Locale(languageCode)));
  }

  void toggleLanguage() {
    if (state.locale.languageCode == 'ar') {
      emit(const LocalizationState(Locale('fr')));
    } else {
      emit(const LocalizationState(Locale('ar')));
    }
  }
}
