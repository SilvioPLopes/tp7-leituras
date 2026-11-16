# TP7 — App de Organização de Leituras

Aplicativo Flutter/Dart para organizar uma lista pessoal de livros. Possui duas telas, cadastro, remoção, atualização de status e armazenamento persistente no aparelho com `shared_preferences`.

**Integrante:** Silvio Lopes. O nome aparece nas duas AppBars e em comentário na primeira linha de cada arquivo em `lib/`. Confira se precisa acrescentar sobrenomes ou incluir o segundo integrante antes da entrega.

## Executar

Use Flutter estável 3.35 ou superior, Dart 3.9 ou superior e Android ou Chrome configurado. Para Android, use JDK 17 e Android SDK; o pacote requer Android API 24 ou superior.

```bash
git clone --branch tp7-leituras https://github.com/SilvioPLopes/tp7-leituras.git
cd tp7-leituras
flutter pub get
flutter run
```

Para Web, execute `flutter run -d chrome`. O projeto inclui a estrutura Android e Web. O `pubspec.lock` é gerado no primeiro `flutter pub get`; inclua-o no próximo commit após instalar as dependências.

## Usar

1. Na tela inicial, toque em **Novo livro**.
2. Preencha título e autor.
3. Escolha **Quero ler**, **Lendo** ou **Concluído** no `DropdownButton`.
4. Toque em **Salvar livro** para voltar à lista.
5. Altere o status pelo seletor no cartão do livro, se desejar.
6. Para excluir, toque na lixeira e confirme em **Remover**.

Campos vazios ou apenas com espaços são recusados. Adições, remoções e mudanças de status bem-sucedidas são confirmadas com `SnackBar`. Falhas ao salvar mostram uma mensagem e mantêm a lista anterior. Uma falha de leitura bloqueia alterações para não sobrescrever registros que não puderam ser recuperados.

## Como a coleção é armazenada

`SharedPreferences` é um armazenamento chave-valor que aceita tipos simples, não objetos Dart diretamente. O aplicativo converte cada livro em um mapa com `id`, `titulo`, `autor` e `status`, transforma a lista em uma `String` JSON usando `jsonEncode` e a salva na chave `tp7_livros_v1` com `setString`.

Na inicialização da tela, `initState` chama `carregar()`. O serviço lê `getString`, usa `jsonDecode`, reconstrói os objetos e a tela usa `setState` para apresentar os dados. Ao adicionar, remover ou alterar status, a coleção inteira é regravada. As operações de alteração são serializadas pela interface para evitar sobrescritas concorrentes. A mensagem de sucesso só aparece depois de a gravação ser confirmada pela API do pacote.

Os códigos persistidos dos status são `quero_ler`, `lendo` e `concluido`, separados dos rótulos exibidos. Não há SQLite, banco externo, login ou chamada a API remota.

Este projeto usa a API clássica `SharedPreferences`, ainda disponibilizada pelo pacote, para demonstrar diretamente `getInstance`, `getString` e `setString`. A documentação também apresenta as APIs mais recentes `SharedPreferencesAsync` e `SharedPreferencesWithCache`.

Preferências são adequadas a coleções pequenas e não substituem um banco de dados ou backup. Fechar e reabrir o app preserva os registros no mesmo aparelho. Desinstalar o aplicativo ou limpar seus dados pode removê-los. No navegador, use a mesma origem (incluindo porta) e perfil; evite navegação anônima. Para testar a reabertura Web com endereço fixo, use `flutter run -d chrome --web-port=7357`.

## Estrutura

| Arquivo | Responsabilidade |
| --- | --- |
| `lib/main.dart` | Inicialização, tema e tela inicial |
| `lib/models/livro.dart` | Livro, status e conversão JSON |
| `lib/services/livros_storage.dart` | Leitura e gravação com SharedPreferences |
| `lib/pages/lista_livros_page.dart` | Lista, carregamento, remoção e status |
| `lib/pages/cadastro_livro_page.dart` | Cadastro com TextField e DropdownButton |
| `test/persistencia_test.dart` | Persistência, três status, exclusão e dados inválidos |
| `test/fluxo_test.dart` | Navegação, validação, cadastro, remoção e recuperação |

## Requisitos atendidos

| Requisito | Implementação |
| --- | --- |
| Tela inicial com livros | `ListView` com título, autor e status |
| Segunda tela de cadastro | Dois `TextField` para título e autor |
| Seleção de status | `DropdownButton<StatusLeitura>` |
| Adicionar e remover | Cadastro e exclusão com confirmação |
| Navegação | `Navigator.push`, `MaterialPageRoute` e `Navigator.pop` |
| Atualização de estado | `StatefulWidget` e `setState` nas duas telas |
| Persistência | `shared_preferences` e coleção JSON |
| Recuperação automática | Carregamento em `initState` |
| Confirmações | `ScaffoldMessenger` e `SnackBar` |
| Identificação | Silvio Lopes nas AppBars e comentários iniciais |

## Verificação

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```

O workflow `.github/workflows/flutter.yml` executa formatação, análise, testes e compilação Web no GitHub Actions. Os testes utilizam o armazenamento simulado do próprio pacote e recriam o aplicativo para verificar a recuperação dos registros.

A execução local do Flutter neste ambiente de preparação não está disponível devido ao bloqueio de segurança relatado no TP6. O formatador Dart e a validação estrutural podem ser executados localmente; consulte a aba Actions para o resultado efetivo dos testes e da compilação. A presença dos testes não significa que passaram.

Checklist manual no aparelho:

- Cadastrar pelo menos um livro em cada um dos três status.
- Fechar completamente e reabrir o aplicativo: conferir os mesmos títulos, autores e status.
- Alterar um status, reabrir e conferir a alteração.
- Remover um livro, reabrir e confirmar que não voltou.
- Cancelar uma remoção e conferir que o livro permanece.
- Voltar do cadastro sem salvar: nenhum livro deve ser adicionado.
- Tentar salvar título ou autor em branco.

## Entrega

Projeto: https://github.com/SilvioPLopes/tp7-leituras/tree/tp7-leituras

O desenvolvimento é dividido em três commits relevantes: configuração Flutter Android/Web; modelo e persistência; telas, navegação, testes e documentação. Os commits usam as datas reais de criação.

Prazo informado no enunciado: **21/11 às 23h59**. Envie o link na plataforma da professora. O repositório foi criado como privado; antes da entrega, conceda acesso à professora ou autorize a mudança para público. Nenhum envio à plataforma da professora é realizado pelo aplicativo.

## Referências

- Shared Preferences: https://pub.dev/packages/shared_preferences
- Navegação Flutter: https://docs.flutter.dev/cookbook/navigation/navigation-basics
