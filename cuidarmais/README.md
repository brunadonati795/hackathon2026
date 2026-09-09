# Cuidar+

Aplicação Flutter de agenda de cuidados compartilhada entre pessoas idosas e seus familiares/cuidadores. O projeto foi desenvolvido a partir do wireframe e do relatório de validação do Hackathon IFC Concórdia.

## O que está implementado

- login separado para idoso e cuidador/familiar;
- criação de conta e vínculo seguro por palavra-chave criada pelo idoso;
- tela inicial simplificada para o idoso, com próximo aviso, compromissos e contato rápido com o familiar;
- confirmação ou adiamento de medicamentos, consultas, refeições e atividades;
- painel do cuidador com situação do dia, inclusão de lembretes, histórico e alertas;
- alerta ao cuidador quando um item é adiado ou não confirmado;
- ajustes de tamanho de texto, brilho e alto contraste;
- layout responsivo para celular, web e desktop.

## Contas de demonstração

| Perfil | Login | Senha | Palavra-chave |
|---|---|---|---|
| Idoso | `maria@cuidar.app` | `123456` | `MARIA2026` |
| Cuidador | `romulo@cuidar.app` | `123456` | já vinculado a Maria |

## Executar

```bash
flutter pub get
flutter run
```

Para verificar o projeto:

```bash
flutter analyze
flutter test
```

## Observação sobre o protótipo

Os dados ficam em memória durante a execução. Para publicação, a próxima etapa é ligar o `AppState` a um backend autenticado (por exemplo, Firebase ou Supabase) e a notificações push, preservando as mesmas regras e telas já implementadas.
