import 'package:flutter/material.dart';

import '../estado_app.dart';
import '../tema.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final brightnessPercent = (state.brightness * 100).round();

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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tamanho do texto',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${(state.textScale * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _scaleButton(state, 1.0, 'Normal')),
                          const SizedBox(width: 8),
                          Expanded(child: _scaleButton(state, 1.25, 'Grande')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _scaleButton(state, 1.50, 'M. Grande'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _scaleButton(state, 1.75, 'Gigante')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Brilho da tela',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '$brightnessPercent%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.light_mode_outlined,
                        color: Color(0xFFF2B526),
                      ),
                      Expanded(
                        child: Slider(
                          min: 0.3,
                          max: 1.0,
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
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(state.currentAccount?.name ?? ''),
                    subtitle: Text(state.currentAccount?.contact ?? ''),
                  ),
                  if (state.currentAccount?.linkKey != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEAFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.key_outlined,
                            color: AppColors.purple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Código de Conexão',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  state.currentAccount!.linkKey!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copiar código',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Código ${state.currentAccount!.linkKey!} copiado!',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.copy,
                              color: AppColors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                    ),
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
      },
    );
  }

  Widget _scaleButton(AppState state, double targetScale, String label) {
    final selected = (state.textScale - targetScale).abs() < 0.05;
    return selected
        ? FilledButton(
            key: Key('scale-$targetScale'),
            onPressed: () => state.setTextScale(targetScale),
            child: Text(label),
          )
        : OutlinedButton(
            key: Key('scale-$targetScale'),
            onPressed: () => state.setTextScale(targetScale),
            child: Text(label),
          );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
      ),
    );
  }
}
