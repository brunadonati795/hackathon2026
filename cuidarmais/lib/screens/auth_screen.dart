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

  void signIn() {
    setState(() => error = widget.state.signIn(contact.text, password.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 42, 28, 24),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                key: const Key('app-logo'),
                width: 220,
                height: 190,
                fit: BoxFit.contain,
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
                onSubmitted: (_) => signIn(),
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
              FilledButton(
                key: const Key('sign-in-elder'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                ),
                onPressed: signIn,
                child: const Text('ENTRAR NA MINHA CONTA'),
              ),
              const SizedBox(height: 20),
              const Text(
                'O app detecta automaticamente se é idoso ou familiar.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
                textAlign: TextAlign.center,
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
  void initState() {
    super.initState();
    _generateElderCodeIfNeeded();
  }

  void _generateElderCodeIfNeeded() {
    if (role == UserRole.elder && keyWord.text.trim().isEmpty) {
      keyWord.text = widget.state.generateUniqueLinkKey();
    }
  }

  @override
  void dispose() {
    name.dispose();
    contact.dispose();
    password.dispose();
    keyWord.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final result = await widget.state.createAccountAndSave(
      name: name.text,
      contact: contact.text,
      password: password.text,
      role: role,
      key: keyWord.text,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => error = result);
      return;
    }
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
                  if (role == UserRole.elder) {
                    _generateElderCodeIfNeeded();
                  } else {
                    keyWord.clear();
                  }
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('register-name'),
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Como você quer ser chamado?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('register-contact'),
                controller: contact,
                decoration: const InputDecoration(
                  labelText: 'E-mail ou telefone',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('register-password'),
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
                          ? 'Seu código automático de conexão'
                          : 'Código do idoso',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role == UserRole.elder
                          ? 'Geramos um código automático para você. Basta passar esse código para o seu familiar.'
                          : 'Digite o código automático gerado na conta do idoso para vincular.',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    if (role == UserRole.elder) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.purple,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                keyWord.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: AppColors.purple,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: 'Gerar outro código',
                            onPressed: () {
                              setState(() {
                                keyWord.text = widget.state
                                    .generateUniqueLinkKey();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ] else
                      TextField(
                        key: const Key('register-link-code'),
                        controller: keyWord,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Ex.: CD-8492 ou MARIA2026',
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
                key: const Key('register-submit'),
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
