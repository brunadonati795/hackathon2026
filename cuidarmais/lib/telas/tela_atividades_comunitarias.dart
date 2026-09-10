import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados_atividades_comunitarias.dart';
import '../estado_app.dart';
import '../models.dart';
import '../tema.dart';

class CommunityActivitiesScreen extends StatelessWidget {
  const CommunityActivitiesScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(state.textScale)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atividades em Concórdia'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              key: const Key('institution-area'),
              tooltip: 'Cadastrar atividade de uma instituição',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      InstitutionActivitySubmissionScreen(state: state),
                ),
              ),
              icon: const Icon(Icons.apartment_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(
              'ENCONTRE UMA ATIVIDADE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ...verifiedCommunityActivities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CommunityActivityCard(
                  activity: activity,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommunityActivityDetailScreen(
                        state: state,
                        activity: activity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              key: const Key('submit-community-activity'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      InstitutionActivitySubmissionScreen(state: state),
                ),
              ),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('CADASTRAR ATIVIDADE DA INSTITUIÇÃO'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityActivityCard extends StatelessWidget {
  const _CommunityActivityCard({required this.activity, required this.onTap});

  final CommunityActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = activity.nextOccurrence() != null;
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        key: Key('community-activity-${activity.id}'),
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activity.categoryLabel.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    available ? Icons.verified : Icons.event_busy_outlined,
                    color: available ? AppColors.green : AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activity.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                activity.organizer,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _ActivityLine(
                icon: Icons.schedule_outlined,
                text: activity.scheduleLabel,
              ),
              _ActivityLine(
                icon: Icons.location_on_outlined,
                text: activity.address,
              ),
              _ActivityLine(
                icon: Icons.payments_outlined,
                text: activity.priceLabel,
              ),
              const SizedBox(height: 8),
              Text(
                available ? 'VER DETALHES' : 'EDIÇÃO ENCERRADA',
                style: TextStyle(
                  color: available ? AppColors.blue : AppColors.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityActivityDetailScreen extends StatefulWidget {
  const CommunityActivityDetailScreen({
    super.key,
    required this.state,
    required this.activity,
  });

  final AppState state;
  final CommunityActivity activity;

  @override
  State<CommunityActivityDetailScreen> createState() =>
      _CommunityActivityDetailScreenState();
}

class _CommunityActivityDetailScreenState
    extends State<CommunityActivityDetailScreen> {
  Future<void> _open(Uri uri, String failureMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _addToAgenda() async {
    final mode = await showDialog<ReminderAlertMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como deseja ser lembrado?'),
        content: const Text(
          'A atividade será adicionada à agenda na próxima data disponível.',
        ),
        actions: [
          TextButton(
            key: const Key('activity-reminder-notification'),
            onPressed: () =>
                Navigator.pop(context, ReminderAlertMode.notification),
            child: const Text('NOTIFICAÇÃO'),
          ),
          FilledButton(
            key: const Key('activity-reminder-alarm'),
            onPressed: () => Navigator.pop(context, ReminderAlertMode.alarm),
            child: const Text('ALARME'),
          ),
        ],
      ),
    );
    if (mode == null || !mounted) return;
    final added = widget.state.addCommunityActivityReminder(
      widget.activity,
      alertMode: mode,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Atividade adicionada à agenda.'
              : 'Esta atividade já está na agenda.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final occurrence = activity.nextOccurrence();
    final saved = widget.state.hasCommunityActivityReminder(activity.id);
    final phoneDigits = activity.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': activity.address,
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da atividade'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
        children: [
          Text(
            activity.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.green, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${activity.organizer} • verificado em ${activity.formattedVerifiedAt}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(activity.description, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 20),
          _DetailBox(
            children: [
              _ActivityLine(
                icon: Icons.schedule_outlined,
                text: activity.scheduleLabel,
              ),
              _ActivityLine(
                icon: Icons.location_on_outlined,
                text: activity.address,
              ),
              _ActivityLine(
                icon: Icons.groups_outlined,
                text: activity.audience,
              ),
              _ActivityLine(
                icon: Icons.payments_outlined,
                text: activity.priceLabel,
              ),
              _ActivityLine(
                icon: Icons.accessible_outlined,
                text: activity.accessibilityLabel,
              ),
              _ActivityLine(
                icon: Icons.app_registration_outlined,
                text: activity.requiresRegistration
                    ? 'Confirme a inscrição antes de participar'
                    : 'Não exige inscrição',
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('add-activity-to-agenda'),
            onPressed: occurrence == null || saved ? null : _addToAgenda,
            icon: Icon(saved ? Icons.check : Icons.event_available_outlined),
            label: Text(
              occurrence == null
                  ? 'EDIÇÃO ENCERRADA'
                  : saved
                  ? 'JÁ ESTÁ NA AGENDA'
                  : 'QUERO PARTICIPAR',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('call-activity-organizer'),
            onPressed: () => _open(
              Uri(scheme: 'tel', path: phoneDigits),
              'Não foi possível abrir o telefone.',
            ),
            icon: const Icon(Icons.phone_outlined),
            label: Text('LIGAR: ${activity.phone}'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('open-activity-map'),
            onPressed: () => _open(mapsUri, 'Não foi possível abrir o mapa.'),
            icon: const Icon(Icons.map_outlined),
            label: const Text('COMO CHEGAR'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            key: const Key('open-activity-source'),
            onPressed: () => _open(
              Uri.parse(activity.sourceUrl),
              'Não foi possível abrir a fonte oficial.',
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('VER FONTE OFICIAL'),
          ),
        ],
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: AppColors.purple),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class InstitutionActivitySubmissionScreen extends StatefulWidget {
  const InstitutionActivitySubmissionScreen({super.key, required this.state});

  final AppState state;

  @override
  State<InstitutionActivitySubmissionScreen> createState() =>
      _InstitutionActivitySubmissionScreenState();
}

class _InstitutionActivitySubmissionScreenState
    extends State<InstitutionActivitySubmissionScreen> {
  final organizer = TextEditingController();
  final contact = TextEditingController();
  final title = TextEditingController();
  final schedule = TextEditingController();
  final address = TextEditingController();
  final description = TextEditingController();
  String? error;
  String? protocol;

  @override
  void dispose() {
    organizer.dispose();
    contact.dispose();
    title.dispose();
    schedule.dispose();
    address.dispose();
    description.dispose();
    super.dispose();
  }

  void submit() {
    if ([
      organizer,
      contact,
      title,
      schedule,
      address,
      description,
    ].any((controller) => controller.text.trim().isEmpty)) {
      setState(() => error = 'Preencha todos os campos para enviar.');
      return;
    }
    setState(() {
      error = null;
      protocol = widget.state.submitCommunityActivity(
        organizer: organizer.text,
        contact: contact.text,
        title: title.text,
        schedule: schedule.text,
        address: address.text,
        description: description.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (protocol != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fact_check_outlined,
                  size: 72,
                  color: AppColors.green,
                ),
                const SizedBox(height: 20),
                Text(
                  'Atividade recebida',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'A publicação ficará pendente até a instituição e as informações serem verificadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 18),
                Text(
                  'Protocolo $protocol',
                  key: const Key('activity-submission-protocol'),
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CONCLUIR'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar atividade'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
        children: [
          const Text(
            'Para instituições e projetos comunitários',
            style: TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'As informações passam por verificação antes de aparecerem para idosos e familiares.',
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('submission-organizer'),
            controller: organizer,
            decoration: const InputDecoration(labelText: 'Instituição'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('submission-contact'),
            controller: contact,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone ou e-mail responsável',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('submission-title'),
            controller: title,
            decoration: const InputDecoration(labelText: 'Nome da atividade'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('submission-schedule'),
            controller: schedule,
            decoration: const InputDecoration(
              labelText: 'Dias, horários e período',
              hintText: 'Ex.: quintas, das 14h às 15h, até dezembro',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('submission-address'),
            controller: address,
            decoration: const InputDecoration(labelText: 'Endereço completo'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('submission-description'),
            controller: description,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Descrição, público, valor e acessibilidade',
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('submit-institution-activity'),
            onPressed: submit,
            icon: const Icon(Icons.send_outlined),
            label: const Text('ENVIAR PARA VERIFICAÇÃO'),
          ),
        ],
      ),
    );
  }
}
