import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.state});
  final AppState state;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final contact = TextEditingController();
  final password = TextEditingController();
  bool hidePassword = true;
  String? error;

  @override
  void dispose() {
    contact.dispose();
    password.dispose();
    super.dispose();
  }

  void signIn(UserRole role) {
    setState(
      () => error = widget.state.signIn(contact.text, password.text, role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 42, 28, 24),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEAFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Cuidar+',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: AppColors.purple,
                ),
              ),
              const Text(
                'Cuidado simples, perto de quem importa.',
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              const SizedBox(height: 38),
              TextField(
                key: const Key('login-contact'),
                controller: contact,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'E-mail ou telefone',
                ),
              ),
              const SizedBox(height: 13),
              TextField(
                key: const Key('login-password'),
                controller: password,
                obscureText: hidePassword,
                onSubmitted: (_) => signIn(UserRole.elder),
                decoration: InputDecoration(
                  hintText: 'Senha',
                  suffixIcon: IconButton(
                    tooltip: hidePassword ? 'Mostrar senha' : 'Esconder senha',
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text(
                'Escolha como deseja entrar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('sign-in-elder'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.green),
                onPressed: () => signIn(UserRole.elder),
                child: const Text('ENTRAR COMO IDOSO'),
              ),
              const SizedBox(height: 13),
              FilledButton(
                key: const Key('sign-in-caregiver'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                onPressed: () => signIn(UserRole.caregiver),
                child: const Text('CUIDADOR / FAMILIAR'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cada perfil abre uma experiência diferente.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 13),
              OutlinedButton(
                onPressed: () => _showMessage(
                  context,
                  'Peça ajuda a um familiar para recuperar sua senha.',
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Esqueci minha senha'),
              ),
              TextButton(
                key: const Key('create-account'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegistrationScreen(state: widget.state),
                  ),
                ),
                child: const Text(
                  'Primeiro acesso? Criar minha conta',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Teste: maria@cuidar.app ou romulo@cuidar.app • senha 123456',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.state});
  final AppState state;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final name = TextEditingController();
  final contact = TextEditingController();
  final password = TextEditingController();
  final keyWord = TextEditingController();
  UserRole role = UserRole.elder;
  String? error;

  @override
  void dispose() {
    name.dispose();
    contact.dispose();
    password.dispose();
    keyWord.dispose();
    super.dispose();
  }

  void submit() {
    final result = widget.state.createAccount(
      name: name.text,
      contact: contact.text,
      password: password.text,
      role: role,
      key: keyWord.text,
    );
    if (result != null) {
      setState(() => error = result);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vamos começar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              const Text(
                'São poucos passos e você pode pedir ajuda a alguém de confiança.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              SegmentedButton<UserRole>(
                segments: const [
                  ButtonSegment(
                    value: UserRole.elder,
                    label: Text('Sou idoso'),
                    icon: Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: UserRole.caregiver,
                    label: Text('Sou familiar'),
                    icon: Icon(Icons.favorite_outline),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (value) => setState(() {
                  role = value.first;
                  error = null;
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Como você quer ser chamado?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contact,
                decoration: const InputDecoration(
                  labelText: 'E-mail ou telefone',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Crie uma senha',
                  helperText: 'Use pelo menos 6 números ou letras',
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == UserRole.elder
                          ? 'Crie sua palavra-chave'
                          : 'Palavra-chave do idoso',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role == UserRole.elder
                          ? 'Diga esta palavra apenas ao familiar que cuidará dos seus lembretes.'
                          : 'Digite a palavra que o idoso criou. Assim, as duas contas ficam ligadas.',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keyWord,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Ex.: MARIA2026',
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: submit,
                child: const Text('CRIAR CONTA E CONTINUAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Tudo bem'),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ENTENDI'),
        ),
      ],
    ),
  );
}
