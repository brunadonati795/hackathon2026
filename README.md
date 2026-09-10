# Cuidar+

Aplicativo de cuidado compartilhado e incentivo à convivência para pessoas idosas, familiares e cuidadores.

O projeto foi desenvolvido como MVP para o 2º Hackathon do IFC Concórdia. Ele reúne agenda de cuidados, lembretes e atividades comunitárias em uma interface acessível.

## Funcionalidades

### Contas e vínculo familiar

- criação de conta para pessoa idosa ou familiar/cuidador;
- geração automática de um código de vínculo para a pessoa idosa;
- conexão do cuidador a uma conta de idoso por meio desse código;
- login persistente após fechar e abrir o aplicativo;
- separação dos dados conforme a pessoa idosa vinculada;
- opção para sair da conta nas configurações.

### Experiência da pessoa idosa

- interface com textos grandes, botões destacados e navegação simplificada;
- visualização do próximo lembrete e dos compromissos do dia;
- confirmação de que uma tarefa foi realizada;
- adiamento de um lembrete por dez minutos;
- acesso ao histórico de compromissos;
- central de notificações dentro do aplicativo;
- acesso às atividades comunitárias;
- exibição e cópia do código usado para vincular um cuidador;
- atalho de contato com o familiar responsável.

### Experiência do familiar ou cuidador

- painel com a situação da pessoa idosa e a agenda vinculada;
- criação de lembretes para remédios, consultas, atividades, refeições ou um tipo personalizado;
- escolha do dia e do horário;
- configuração como lembrete único ou diário;
- escolha entre notificação comum e alarme;
- inclusão opcional de instruções;
- inclusão de foto pela câmera ou galeria;
- gravação e reprodução de mensagem de voz;
- visualização imediata do lembrete criado;
- histórico de lembretes;
- alertas quando um compromisso é confirmado, adiado ou resolvido.

### Atividades comunitárias

- catálogo inicial de atividades presenciais em Concórdia, Santa Catarina;
- categorias como convivência, bem-estar, cultura, movimento e aprendizado;
- informações de público, horário, local, preço e acessibilidade;
- acesso ao telefone da instituição;
- abertura da localização no aplicativo de mapas;
- acesso à página oficial da atividade;'
- inclusão da atividade na agenda como notificação ou alarme;
- prevenção de lembretes duplicados para a mesma atividade;
- cálculo automático da próxima data válida da atividade.

O catálogo inicial contém atividades do Sesc Concórdia consultadas em páginas oficiais:

- [Conecta 60+](https://www.sesc-sc.com.br/servicos/trabalho-com-grupos/conecta-60%2B?u=34)
- [SimplesMente 60+](https://www.sesc-sc.com.br/servicos/cuidado-terapeutico/simplesmente-60?u=25)

Como horários, valores e disponibilidade podem mudar, esses dados devem ser revisados antes de utilizar o catálogo.

### Cadastro por instituições

- formulário para instituições sugerirem novas atividades;
- validação dos campos obrigatórios;
- geração de protocolo no formato `CM-0001`;
- armazenamento local da solicitação e de seu status.

No MVP offline, o envio institucional é uma simulação funcional: a solicitação e o protocolo ficam salvos no próprio aparelho, mas não são transmitidos para uma equipe de análise.

### Acessibilidade

- três opções de tamanho de texto;
- ajuste de brilho da interface;
- modo de alto contraste;
- componentes grandes e áreas de toque destacadas;
- uso combinado de texto, cor e ícones para comunicar estados.

### Notificações e alarmes

O responsável escolhe como cada lembrete será apresentado:

- **Notificação:** aviso comum do sistema, com som e vibração conforme as configurações do aparelho;
- **Alarme:** aviso mais insistente no Android, com repetição de áudio, vibração, tela de alarme e volume configurado no nível máximo pelo aplicativo.

Ao tocar em uma notificação, o aplicativo abre diretamente os detalhes do lembrete correspondente. Alarmes diários são programados com antecedência e reagendados quando necessário.

O comportamento final depende das permissões e das restrições do sistema operacional. No Android, o usuário deve autorizar notificações e alarmes exatos quando solicitado. Modos como “Não perturbe”, restrições de bateria e personalizações do fabricante podem interferir no funcionamento, por isso a validação em aparelho físico é indispensável.

## Funcionamento offline

Esta versão não depende de servidor, conta em nuvem ou serviço externo de notificações. Contas, vínculos, lembretes, preferências, alertas e solicitações de atividades são armazenados localmente com `SharedPreferences`.

Isso permite demonstrar todo o fluxo em um único aparelho sem conexão contínua com a internet. Ligações, mapas e páginas oficiais exigem que o dispositivo tenha um aplicativo compatível e, quando necessário, acesso à internet.

### Limitações do modo offline

- dados criados em um celular não aparecem automaticamente em outro;
- cuidador e pessoa idosa precisam utilizar o mesmo aparelho para compartilhar o estado do MVP;
- não há notificações push entre dispositivos;
- o cadastro de uma instituição não chega a uma central remota de aprovação;
- não existe recuperação de senha por e-mail ou telefone;
- as credenciais locais ainda não usam a infraestrutura de segurança necessária para produção;
- remover os dados do aplicativo ou desinstalá-lo pode apagar as informações salvas.

## Tecnologias

- Flutter 3.44.2;
- Dart 3.12.2;
- Material Design;
- `shared_preferences` para persistência local;
- `flutter_local_notifications` e `timezone` para notificações agendadas;
- `alarm` para alarmes no Android;
- `image_picker` para fotos;
- `record` e `audioplayers` para mensagens de voz;
- `path_provider` e `path` para arquivos locais;
- `url_launcher` para telefone, mapas e páginas oficiais.

## Estrutura do projeto

```text
cuidarmais/
├── android/                         Configuração da aplicação Android
├── assets/
│   └── imagens/
│       └── logo.png                 Logo e ícone do aplicativo
├── lib/
│   ├── telas/                       Telas e componentes visuais
│   │   ├── tela_autenticacao.dart
│   │   ├── tela_cuidador.dart
│   │   ├── tela_atividades_comunitarias.dart
│   │   ├── tela_idoso.dart
│   │   ├── tela_notificacoes.dart
│   │   ├── componentes_midia_lembrete.dart
│   │   └── tela_configuracoes.dart
│   ├── estado_app.dart              Regras, estado e ações do aplicativo
│   ├── armazenamento_app.dart       Persistência local
│   ├── dados_atividades_comunitarias.dart
│   │                                Catálogo inicial de atividades
│   ├── main.dart                    Inicialização e navegação principal
│   ├── models.dart                  Modelos de domínio
│   ├── servico_notificacoes.dart    Notificações e alarmes
│   ├── servico_midia_lembrete.dart  Fotos e gravações de voz
│   └── tema.dart                    Tema e acessibilidade visual
├── test/
│   ├── estado_app_test.dart
│   ├── atividade_comunitaria_test.dart
│   └── interface_test.dart
└── pubspec.yaml                     Dependências e recursos
```

## Pré-requisitos

- Flutter SDK compatível com Dart `^3.12.2`;
- Android Studio ou outra instalação com o Android SDK;
- Java 17 para a compilação Android;
- um emulador ou aparelho Android para executar o aplicativo.

Confira a instalação do ambiente com:

```bash
flutter doctor
```

## Instalação e execução

Na pasta do projeto, instale as dependências:

```bash
flutter pub get
```

Execute no dispositivo selecionado:

```bash
flutter run
```

O aplicativo inicia sem contas de demonstração. Na primeira utilização:

1. selecione `Criar uma conta`;
2. escolha o perfil de pessoa idosa ou familiar;
3. preencha nome, contato e senha;
4. para um familiar, informe o código de vínculo gerado na conta da pessoa idosa;
5. conclua o cadastro e autorize as permissões solicitadas pelo Android.

## Geração do APK

Para criar um APK de teste:

```bash
flutter build apk --debug
```

O arquivo será criado em:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Testes e qualidade

Execute a análise estática:

```bash
flutter analyze
```

Execute os testes automatizados:

```bash
flutter test
```

A suíte atual possui 23 testes cobrindo, entre outros pontos:

- criação de contas e geração de códigos únicos;
- vínculo entre pessoa idosa e cuidador;
- persistência do login e dos dados após reiniciar o aplicativo;
- separação de lembretes por vínculo;
- criação, confirmação e adiamento de lembretes;
- solicitação de agendamento ao serviço de notificações;
- navegação a partir de uma notificação;
- atualização imediata do painel do cuidador;
- configurações de acessibilidade;
- cálculo de datas das atividades comunitárias;
- prevenção de atividades duplicadas na agenda;
- geração e persistência de protocolos institucionais;
- principais fluxos das interfaces.

Para validar o comportamento real de recursos dependentes do sistema, também é necessário testar manualmente em um aparelho Android:

- autorização e entrega de notificações;
- disparo de alarmes com o aplicativo fechado;
- comportamento com a tela bloqueada e diferentes volumes;
- reagendamento após reiniciar o aparelho;
- câmera, galeria, gravação e reprodução de áudio;
- abertura de telefone, mapas e páginas externas.
