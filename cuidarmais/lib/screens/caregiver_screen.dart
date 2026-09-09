import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final delayed = state.reminders
        .where(
          (r) =>
              r.status == ReminderStatus.delayed ||
              r.status == ReminderStatus.missed,
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const Text(
                  'Cuidar+',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      tooltip: 'Notificações',
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
                        right: 6,
                        top: 6,
                        child: Container(
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
                IconButton(
                  tooltip: 'Configurações',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(state: state),
                    ),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Text(
              'Olá, ${state.currentAccount?.name ?? 'Familiar'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Acompanhando ${state.elderName}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: delayed.isEmpty
                        ? const Color(0xFFE5F6ED)
                        : const Color(0xFFFFE8E8),
                    child: Icon(
                      delayed.isEmpty ? Icons.check : Icons.warning_amber,
                      color: delayed.isEmpty ? AppColors.green : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delayed.isEmpty
                              ? 'Tudo bem por aqui'
                              : '${delayed.length} aviso precisa de atenção',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          delayed.isEmpty
                              ? 'Última confirmação: 08:03'
                              : 'Veja o que ainda não foi confirmado.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'HOJE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            ...state.reminders
                .take(3)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReminderTile(reminder: r),
                  ),
                ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const Key('add-reminder'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF376DD2),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewReminderScreen(state: state),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('ADICIONAR LEMBRETE'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(state: state),
                      ),
                    ),
                    child: const Text('VER HISTÓRICO'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlertsScreen(state: state),
                      ),
                    ),
                    child: const Text('VER ALERTAS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});
  final CareReminder reminder;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (reminder.status) {
      ReminderStatus.confirmed => (AppColors.green, 'FEITO'),
      ReminderStatus.delayed => (const Color(0xFFE58A22), 'ATRASADO'),
      ReminderStatus.missed => (AppColors.red, 'NÃO CONFIRMADO'),
      ReminderStatus.pending => (AppColors.blue, 'PENDENTE'),
    };
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(
              reminder.type == ReminderType.medicine
                  ? Icons.medication_outlined
                  : Icons.event_outlined,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  reminder.instructions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                Text(
                  reminder.time,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewReminderScreen extends StatefulWidget {
  const NewReminderScreen({super.key, required this.state});
  final AppState state;

  @override
  State<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  final title = TextEditingController();
  final instructions = TextEditingController();
  ReminderType type = ReminderType.medicine;
  TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
  bool daily = true;
  String? error;

  @override
  void dispose() {
    title.dispose();
    instructions.dispose();
    super.dispose();
  }

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void save() {
    if (title.text.trim().isEmpty) {
      setState(() => error = 'Dê um nome ao lembrete.');
      return;
    }
    widget.state.addReminder(
      title: title.text.trim(),
      time: formattedTime,
      type: type,
      instructions: instructions.text.trim().isEmpty
          ? 'Sem instrução adicional'
          : instructions.text.trim(),
      isDaily: daily,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo lembrete'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const Text(
            'O lembrete aparecerá para você e será compartilhado com o idoso.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          const Text(
            'TIPO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            children: [
              ChoiceChip(
                label: const Text('REMÉDIO'),
                selected: type == ReminderType.medicine,
                onSelected: (_) => setState(() => type = ReminderType.medicine),
              ),
              ChoiceChip(
                label: const Text('CONSULTA'),
                selected: type == ReminderType.appointment,
                onSelected: (_) =>
                    setState(() => type = ReminderType.appointment),
              ),
              ChoiceChip(
                label: const Text('ATIVIDADE'),
                selected: type == ReminderType.activity,
                onSelected: (_) => setState(() => type = ReminderType.activity),
              ),
              ChoiceChip(
                label: const Text('REFEIÇÃO'),
                selected: type == ReminderType.meal,
                onSelected: (_) => setState(() => type = ReminderType.meal),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            key: const Key('reminder-title'),
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ex.: Losartana',
            ),
          ),
          const SizedBox(height: 15),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: time,
                helpText: 'Escolha o horário',
              );
              if (selected != null) setState(() => time = selected);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Horário',
                suffixIcon: Icon(Icons.schedule),
              ),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Repetir todos os dias',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            value: daily,
            onChanged: (value) => setState(() => daily = value),
          ),
          TextField(
            controller: instructions,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Instrução opcional',
              hintText: 'Ex.: 1 comprimido com água',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Se não confirmar em 30 min, o familiar verá um alerta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3065C6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 28),
          FilledButton(
            key: const Key('save-reminder'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF376DD2),
            ),
            onPressed: save,
            child: const Text('SALVAR LEMBRETE'),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Confirmações recentes',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ...state.reminders.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReminderTile(reminder: r),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'O histórico ajuda a perceber esquecimentos recorrentes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final alerts = state.reminders
        .where(
          (r) =>
              r.status == ReminderStatus.delayed ||
              r.status == ReminderStatus.missed,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: alerts.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: AppColors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tudo certo por aqui',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Nenhum lembrete precisa de atenção.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView(
                children: alerts
                    .map((r) => _AlertCard(state: state, reminder: r))
                    .toList(),
              ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.state, required this.reminder});
  final AppState state;
  final CareReminder reminder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFFFFE8E8),
          child: Icon(Icons.priority_high, size: 40, color: AppColors.red),
        ),
        const SizedBox(height: 18),
        const Text(
          'Lembrete não confirmado',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '${state.elderName} ainda não confirmou este lembrete.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('Horário: ${reminder.time}'),
              const Text(
                'Tempo sem confirmação: 35 min',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Iniciando ligação para ${state.elderName}...'),
            ),
          ),
          icon: const Icon(Icons.phone),
          label: Text('LIGAR PARA ${state.elderName.toUpperCase()}'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
          onPressed: () {
            state.resolve(reminder);
            Navigator.pop(context);
          },
          child: const Text('MARCAR COMO RESOLVIDO'),
        ),
      ],
    );
  }
}
