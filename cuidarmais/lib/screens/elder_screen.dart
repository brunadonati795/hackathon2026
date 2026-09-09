import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'settings_screen.dart';

class ElderHomeScreen extends StatelessWidget {
  const ElderHomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final pending = state.reminders
        .where((r) => r.status == ReminderStatus.pending)
        .toList();
    final next = pending.isEmpty ? state.reminders.first : pending.first;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 22),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton.filled(
                key: const Key('settings-button'),
                tooltip: 'Configurações e acessibilidade',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.muted,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(state: state),
                  ),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Olá, ${state.elderName}!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Text('Hoje é', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 4),
            const Text(
              'quarta-feira, 9 de setembro',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 23),
            _HomeAction(
              key: const Key('next-reminder'),
              color: const Color(0xFFD5EBFF),
              iconColor: const Color(0xFF68A9ED),
              icon: _letterFor(next.type),
              eyebrow: 'Próximo aviso',
              title: '${next.title}\nàs ${next.time}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReminderDetailScreen(state: state, reminder: next),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _HomeAction(
              color: const Color(0xFFF8D5E3),
              iconColor: const Color(0xFFF27196),
              icon: 'C',
              title: 'Ver meus compromissos',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CommitmentsScreen(state: state),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _HomeAction(
              color: const Color(0xFFD5F0DC),
              iconColor: AppColors.green,
              icon: '☎',
              title: 'Falar com familiar',
              onTap: () => _callDialog(context),
            ),
            const SizedBox(height: 18),
            _AccessibilityCard(state: state),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Sempre com você',
                style: TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _letterFor(ReminderType type) => switch (type) {
    ReminderType.medicine => 'R',
    ReminderType.appointment => 'C',
    ReminderType.activity => 'A',
    ReminderType.meal => 'M',
  };

  void _callDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.phone_in_talk, size: 42, color: AppColors.green),
        title: const Text('Ligar para Rômulo?'),
        content: const Text('Ele é o familiar ligado à sua conta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('AGORA NÃO'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('LIGAR'),
          ),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    super.key,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.onTap,
    this.eyebrow,
  });
  final Color color;
  final Color iconColor;
  final String icon;
  final String title;
  final String? eyebrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconColor,
                child: Text(
                  icon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessibilityCard extends StatelessWidget {
  const _AccessibilityCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Acessibilidade',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tamanho do texto',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.setTextScale(.9),
                  child: const Text('A−'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.setTextScale(1),
                  child: const Text('100%'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton(
                  onPressed: () => state.setTextScale(1.18),
                  child: const Text('A+'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Brilho da tela',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.light_mode_outlined, color: Color(0xFFF2B526)),
              Expanded(
                child: Slider(
                  value: state.brightness,
                  onChanged: state.setBrightness,
                ),
              ),
              const Icon(Icons.light_mode, color: Color(0xFFF2B526)),
            ],
          ),
        ],
      ),
    );
  }
}

class CommitmentsScreen extends StatelessWidget {
  const CommitmentsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus compromissos'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: state.reminders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final reminder = state.reminders[index];
          return Card(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                child: Text(ElderHomeScreen._letterFor(reminder.type)),
              ),
              title: Text(
                reminder.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              subtitle: Text('${reminder.time} • ${reminder.instructions}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReminderDetailScreen(state: state, reminder: reminder),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({
    super.key,
    required this.state,
    required this.reminder,
  });
  final AppState state;
  final CareReminder reminder;

  @override
  Widget build(BuildContext context) {
    final done = reminder.status == ReminderStatus.confirmed;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: done
                  ? const Color(0xFFDDF3E7)
                  : const Color(0xFFEFEAFF),
              child: Icon(
                done ? Icons.check : Icons.notifications_active_outlined,
                size: 42,
                color: done ? AppColors.green : AppColors.purple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              done ? 'Tudo certo!' : 'Está na hora',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              reminder.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'às ${reminder.time}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                color: AppColors.purple,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                reminder.instructions,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Spacer(),
            if (!done) ...[
              FilledButton.icon(
                key: const Key('confirm-reminder'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.green),
                onPressed: () {
                  state.confirm(reminder);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('JÁ FIZ'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  state.postpone(reminder);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tudo bem. Vamos lembrar você de novo em 10 minutos.',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('LEMBRAR DE NOVO'),
              ),
            ] else
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('VOLTAR PARA O INÍCIO'),
              ),
          ],
        ),
      ),
    );
  }
}
