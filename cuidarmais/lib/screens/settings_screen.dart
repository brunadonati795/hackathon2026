import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
        children: [
          _section(
            context,
            title: 'Acessibilidade',
            children: [
              const Text(
                'Tamanho do texto',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => state.setTextScale(.9),
                      child: const Text('A−'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => state.setTextScale(1),
                      child: const Text('100%'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => state.setTextScale(1.18),
                      child: const Text('A+'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Brilho da tela',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.light_mode_outlined,
                    color: Color(0xFFF2B526),
                  ),
                  Expanded(
                    child: Slider(
                      value: state.brightness,
                      onChanged: state.setBrightness,
                    ),
                  ),
                  const Icon(Icons.light_mode, color: Color(0xFFF2B526)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Contraste mais forte',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Deixa textos e botões mais fáceis de enxergar.',
                ),
                value: state.highContrast,
                onChanged: state.setHighContrast,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _section(
            context,
            title: 'Minha conta',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(state.currentAccount?.name ?? ''),
                subtitle: Text(state.currentAccount?.contact ?? ''),
              ),
              if (state.currentAccount?.linkKey != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('Minha palavra-chave'),
                  subtitle: Text(
                    state.currentAccount!.linkKey!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  state.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('SAIR DA CONTA'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Cuidar+ • Sempre com você',
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.purple),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
