import 'package:flutter/foundation.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _accounts.addAll([
      Account(
        name: 'Maria',
        contact: 'maria@cuidar.app',
        password: '123456',
        role: UserRole.elder,
        linkKey: 'MARIA2026',
      ),
      Account(
        name: 'Rômulo',
        contact: 'romulo@cuidar.app',
        password: '123456',
        role: UserRole.caregiver,
        linkedElderKey: 'MARIA2026',
      ),
    ]);
  }

  final List<Account> _accounts = [];
  final List<CareReminder> reminders = [
    CareReminder(
      id: 1,
      title: 'Losartana',
      time: '08:00',
      type: ReminderType.medicine,
      instructions: '1 comprimido com água',
      createdBy: 'Rômulo',
      status: ReminderStatus.confirmed,
      isDaily: true,
    ),
    CareReminder(
      id: 2,
      title: 'Remédio da pressão',
      time: '10:00',
      type: ReminderType.medicine,
      instructions: 'Tomar depois do café',
      createdBy: 'Rômulo',
      isDaily: true,
    ),
    CareReminder(
      id: 3,
      title: 'Consulta médica',
      time: '14:30',
      type: ReminderType.appointment,
      instructions: 'Clínica São Lucas',
      createdBy: 'Rômulo',
    ),
  ];

  Account? currentAccount;
  double textScale = 1;
  double brightness = .72;
  bool highContrast = false;
  int _nextId = 4;

  String get elderName {
    if (currentAccount?.role == UserRole.elder) return currentAccount!.name;
    final key = currentAccount?.linkedElderKey;
    return _accounts
            .where((a) => a.role == UserRole.elder && a.linkKey == key)
            .map((a) => a.name)
            .firstOrNull ??
        'Maria';
  }

  String? signIn(String contact, String password, UserRole role) {
    final normalized = contact.trim().toLowerCase();
    final matches = _accounts.where(
      (a) =>
          a.contact.toLowerCase() == normalized &&
          a.password == password &&
          a.role == role,
    );
    if (matches.isEmpty) {
      return 'Confira seu e-mail, senha e o tipo de acesso.';
    }
    currentAccount = matches.first;
    notifyListeners();
    return null;
  }

  String? createAccount({
    required String name,
    required String contact,
    required String password,
    required UserRole role,
    required String key,
  }) {
    if ([name, contact, password, key].any((value) => value.trim().isEmpty)) {
      return 'Preencha todos os campos para continuar.';
    }
    if (password.length < 6) {
      return 'A senha precisa ter pelo menos 6 números ou letras.';
    }
    if (_accounts.any(
      (a) => a.contact.toLowerCase() == contact.trim().toLowerCase(),
    )) {
      return 'Já existe uma conta com este e-mail ou telefone.';
    }
    final normalizedKey = key.trim().toUpperCase();
    if (role == UserRole.elder &&
        _accounts.any((a) => a.linkKey == normalizedKey)) {
      return 'Essa palavra-chave já está em uso. Escolha outra.';
    }
    if (role == UserRole.caregiver &&
        !_accounts.any(
          (a) => a.role == UserRole.elder && a.linkKey == normalizedKey,
        )) {
      return 'Não encontramos um idoso com essa palavra-chave.';
    }
    final account = Account(
      name: name.trim(),
      contact: contact.trim(),
      password: password,
      role: role,
      linkKey: role == UserRole.elder ? normalizedKey : null,
      linkedElderKey: role == UserRole.caregiver ? normalizedKey : null,
    );
    _accounts.add(account);
    currentAccount = account;
    notifyListeners();
    return null;
  }

  void addReminder({
    required String title,
    required String time,
    required ReminderType type,
    required String instructions,
    required bool isDaily,
  }) {
    reminders.insert(
      0,
      CareReminder(
        id: _nextId++,
        title: title,
        time: time,
        type: type,
        instructions: instructions,
        createdBy: currentAccount?.name ?? 'Familiar',
        isDaily: isDaily,
      ),
    );
    notifyListeners();
  }

  void confirm(CareReminder reminder) {
    reminder.status = ReminderStatus.confirmed;
    notifyListeners();
  }

  void postpone(CareReminder reminder) {
    reminder.status = ReminderStatus.delayed;
    notifyListeners();
  }

  void resolve(CareReminder reminder) {
    reminder.status = ReminderStatus.confirmed;
    notifyListeners();
  }

  void setTextScale(double value) {
    textScale = value;
    notifyListeners();
  }

  void setBrightness(double value) {
    brightness = value;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    highContrast = value;
    notifyListeners();
  }

  void signOut() {
    currentAccount = null;
    notifyListeners();
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
