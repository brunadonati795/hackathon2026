import 'models.dart';

final List<CommunityActivity> verifiedCommunityActivities = List.unmodifiable([
  CommunityActivity(
    id: 'sesc-conecta-60-concordia-2026',
    title: 'Conecta 60+',
    organizer: 'Sesc Concórdia',
    description:
        'Encontro presencial para convivência, participação social e fortalecimento de vínculos entre pessoas idosas.',
    category: CommunityActivityCategory.social,
    address: 'Rua Romano Anselmo, 620, Centro, Concórdia - SC',
    phone: '(49) 3442-0303',
    scheduleLabel: 'Todas as quintas-feiras, das 13h30 às 15h',
    weekday: DateTime.thursday,
    hour: 13,
    minute: 30,
    audience: 'Pessoas com 60 anos ou mais',
    priceLabel: 'Atividade gratuita',
    accessibilityLabel: 'Confirme recursos de acessibilidade com a unidade',
    verifiedAt: DateTime(2026, 9, 9),
    endDate: DateTime(2026, 12, 31, 23, 59),
    sourceUrl:
        'https://www.sesc-sc.com.br/servicos/trabalho-com-grupos/conecta-60%2B?u=34',
  ),
  CommunityActivity(
    id: 'sesc-simplesmente-60-concordia-2026',
    title: 'SimplesMente 60+',
    organizer: 'Sesc Concórdia',
    description:
        'Encontros terapêuticos em grupo conduzidos por psicóloga, com foco em saúde mental, escuta e fortalecimento de vínculos.',
    category: CommunityActivityCategory.wellbeing,
    address:
        'Sala de Grupos, 4º andar — Rua Romano Anselmo, 620, Centro, Concórdia - SC',
    phone: '(49) 3442-0303',
    scheduleLabel: 'Terças-feiras, das 8h30 às 10h',
    weekday: DateTime.tuesday,
    hour: 8,
    minute: 30,
    audience: 'Pessoas com 55 anos ou mais',
    priceLabel: 'R\$ 55,00 por mês',
    accessibilityLabel: 'Vagas limitadas; confirme acessibilidade na inscrição',
    verifiedAt: DateTime(2026, 9, 9),
    startDate: DateTime(2026, 9, 15, 8, 30),
    endDate: DateTime(2026, 12, 1, 23, 59),
    sourceUrl:
        'https://www.sesc-sc.com.br/servicos/cuidado-terapeutico/simplesmente-60?u=25',
  ),
]);
