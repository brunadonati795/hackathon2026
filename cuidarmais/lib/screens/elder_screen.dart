import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'notifications_screen.dart';
import 'reminder_media_widgets.dart';
import 'settings_screen.dart';

class ElderHomeScreen extends StatelessWidget {
  const ElderHomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final pending = state.reminders
        .where((r) => r.status == ReminderStatus.pending)
        .toList();

    final next = pending.firstOrNull ?? state.reminders.firstOrNull;
    final todayLabel = _formatDate(DateTime.now());

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(state.textScale)),
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(30, 16, 30, 22),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      IconButton.filled(
                        key: const Key('notifications-button'),
                        tooltip: 'Notificações',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(52, 52),
                        ),
                        onPressed: () {
                          state.markNotificationsAsRead();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NotificationsScreen(state: state),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      if (state.unreadNotificationsCount > 0)
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Container(
                            key: const Key('notifications-badge'),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.unreadNotificationsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('settings-button'),
                    tooltip: 'Configurações e acessibilidade',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(52, 52),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(state: state),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Olá, ${state.elderName}!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 4),

              const Text(
                'Hoje é',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),

              const SizedBox(height: 4),

              Text(
                todayLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 23),

              if (next != null)
                _HomeAction(
                  key: const Key('next-reminder'),
                  color: const Color(0xFF9DCCF5),
                  iconColor: const Color(0xFF2678C9),
                  icon: _letterFor(next.type),
                  eyebrow: 'Próximo aviso',
                  title: '${next.title}\n${next.formattedDate} às ${next.time}',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ReminderDetailScreen(state: state, reminder: next),
                    ),
                  ),
                )
              else
                Container(
                  key: const Key('empty-reminders'),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5EBFF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF68A9ED),
                        child: Icon(Icons.check, color: Colors.white, size: 27),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Nenhum aviso por enquanto',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              _HomeAction(
                color: const Color(0xFFF29FBE),
                iconColor: const Color(0xFFD83D6C),
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
                color: const Color(0xFF9DDEB0),
                iconColor: const Color(0xFF29964B),
                icon: '☎',
                title: 'Falar com familiar',
                onTap: () => _callDialog(context),
              ),

              if (state.currentAccount?.linkKey != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.purple, width: 2),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFEFEAFF),
                        child: Icon(
                          Icons.key,
                          color: AppColors.purple,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seu Código de Conexão',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              state.currentAccount!.linkKey!,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: AppColors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copiar código',
                        constraints: const BoxConstraints(
                          minWidth: 52,
                          minHeight: 52,
                        ),
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
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              _AccessibilityCard(state: state),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Sempre com você',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _letterFor(ReminderType type) => switch (type) {
    ReminderType.medicine => 'R',
    ReminderType.appointment => 'C',
    ReminderType.activity => 'A',
    ReminderType.meal => 'M',
    ReminderType.other => 'O',
  };

  static String _formatDate(DateTime date) {
    const weekdays = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  void _callDialog(BuildContext context) {
    final caregiverName = state.linkedCaregiverName;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.phone_in_talk, size: 42, color: AppColors.green),
        title: Text(
          caregiverName == null
              ? 'Nenhum familiar conectado'
              : 'Ligar para $caregiverName?',
        ),
        content: Text(
          caregiverName == null
              ? 'Compartilhe seu Código de Conexão para vincular um familiar.'
              : '$caregiverName é o familiar ligado à sua conta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('AGORA NÃO'),
          ),
          if (caregiverName != null)
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: iconColor,
                child: Text(
                  icon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.black, size: 30),
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
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final scaleOptions = [
          (1.0, 'Normal'),
          (1.25, 'Grande'),
          (1.50, 'M. Grande'),
          (1.75, 'Gigante'),
        ];

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
              const Text(
                'Acessibilidade',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.purple,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Tamanho do texto',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(state.textScale * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: scaleOptions.map((opt) {
                  final selected = (state.textScale - opt.$1).abs() < 0.05;

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 120) / 2,
                    child: selected
                        ? FilledButton(
                            key: Key('scale-${opt.$1}'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => state.setTextScale(opt.$1),
                            child: Text(
                              opt.$2,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                        : OutlinedButton(
                            key: Key('scale-${opt.$1}'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => state.setTextScale(opt.$1),
                            child: Text(
                              opt.$2,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 13),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Brilho da tela',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(state.brightness * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 16,
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
                    size: 26,
                  ),
                  Expanded(
                    child: Slider(
                      min: 0.3,
                      max: 1.0,
                      value: state.brightness,
                      onChanged: state.setBrightness,
                    ),
                  ),
                  const Icon(
                    Icons.light_mode,
                    color: Color(0xFFF2B526),
                    size: 26,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommitmentsScreen extends StatelessWidget {
  const CommitmentsScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(state.textScale)),
      child: Scaffold(
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
                contentPadding: const EdgeInsets.all(16),

                leading: CircleAvatar(
                  radius: 25,
                  child: Text(
                    ElderHomeScreen._letterFor(reminder.type),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                title: Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),

                subtitle: Text(
                  '${reminder.formattedDate} às ${reminder.time} • ${reminder.instructions}',
                  style: const TextStyle(fontSize: 16),
                ),

                trailing: const Icon(Icons.chevron_right, size: 30),

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
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(state.textScale)),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: done
                    ? const Color(0xFFDDF3E7)
                    : const Color(0xFFEFEAFF),
                child: Icon(
                  done ? Icons.check : Icons.notifications_active_outlined,
                  size: 44,
                  color: done ? AppColors.green : AppColors.purple,
                ),
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
              '${reminder.formattedDate} às ${reminder.time}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                color: AppColors.purple,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            if (reminder.photoPath != null) ...[
              ReminderPhotoAttachment(path: reminder.photoPath!),
              const SizedBox(height: 14),
            ],
            if (reminder.audioPath != null) ...[
              ReminderAudioAttachment(path: reminder.audioPath!),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                reminder.instructions,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19),
              ),
            ),
            const SizedBox(height: 32),
            if (!done) ...[
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  key: const Key('confirm-reminder'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  onPressed: () {
                    state.confirm(reminder);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'JÁ FIZ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton(
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
                  child: const Text(
                    'LEMBRAR DE NOVO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ] else
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'VOLTAR PARA O INÍCIO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
