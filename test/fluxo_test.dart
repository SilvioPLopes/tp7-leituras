import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp7_leituras/main.dart';
import 'package:tp7_leituras/models/livro.dart';
import 'package:tp7_leituras/services/livros_storage.dart';

class FalhaAoSalvar extends LivrosStorage {
  @override
  Future<void> salvar(List<Livro> livros) async =>
      throw StateError('Falha simulada');
}

const livroInicial = Livro(
  id: '1',
  titulo: 'Dom Casmurro',
  autor: 'Machado de Assis',
  status: StatusLeitura.lendo,
);

Future<void> abrirCadastro(WidgetTester tester) async {
  await tester.tap(find.text('Novo livro'));
  await tester.pumpAndSettle();
}

Future<void> preencherCadastro(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('titulo')),
    '  O Pequeno Príncipe  ',
  );
  await tester.enterText(
    find.byKey(const Key('autor')),
    '  Antoine de Saint-Exupéry  ',
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('cadastro valida campos sem criar registros vazios', (
    tester,
  ) async {
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Silvio Lopes'), findsOneWidget);
    await abrirCadastro(tester);
    await tester.tap(find.text('Salvar livro'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o título do livro.'), findsOneWidget);
    expect(find.text('Informe o autor do livro.'), findsOneWidget);
    expect(await LivrosStorage().carregar(), isEmpty);
  });

  testWidgets(
    'navega, cadastra, seleciona status e recupera após recriar app',
    (tester) async {
      await tester.pumpWidget(const LeiturasApp());
      await tester.pumpAndSettle();
      await abrirCadastro(tester);
      await preencherCadastro(tester);
      await tester.tap(find.byKey(const Key('status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluído').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar livro'));
      await tester.pumpAndSettle();
      expect(find.text('O Pequeno Príncipe'), findsOneWidget);
      expect(find.text('Livro adicionado com sucesso.'), findsOneWidget);
      final salvos = await LivrosStorage().carregar();
      expect(salvos.single.status, StatusLeitura.concluido);
      expect(salvos.single.autor, 'Antoine de Saint-Exupéry');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const LeiturasApp());
      await tester.pumpAndSettle();
      expect(find.text('O Pequeno Príncipe'), findsOneWidget);
      expect(find.text('Concluído'), findsOneWidget);
    },
  );

  testWidgets('voltar do cadastro não adiciona livro', (tester) async {
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    await abrirCadastro(tester);
    await preencherCadastro(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sua lista está vazia.'), findsOneWidget);
    expect(await LivrosStorage().carregar(), isEmpty);
  });

  testWidgets('cancelar remoção preserva; confirmar persiste a remoção', (
    tester,
  ) async {
    await LivrosStorage().salvar([livroInicial]);
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remover Dom Casmurro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await LivrosStorage().carregar(), hasLength(1));
    await tester.tap(find.byTooltip('Remover Dom Casmurro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover', skipOffstage: false));
    await tester.pumpAndSettle();
    expect(find.text('Livro removido com sucesso.'), findsOneWidget);
    expect(await LivrosStorage().carregar(), isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    expect(find.text('Sua lista está vazia.'), findsOneWidget);
  });

  testWidgets('alteração de status na lista é persistida', (tester) async {
    await LivrosStorage().salvar([livroInicial]);
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('status-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluído').last);
    await tester.pumpAndSettle();
    expect(find.text('Status atualizado com sucesso.'), findsOneWidget);
    expect(
      (await LivrosStorage().carregar()).single.status,
      StatusLeitura.concluido,
    );
  });

  testWidgets('falha de leitura bloqueia cadastro e preserva dados originais', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({LivrosStorage.chave: '{quebrado'});
    await tester.pumpWidget(const LeiturasApp());
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    final botao = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(botao.onPressed, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LivrosStorage.chave), '{quebrado');
  });

  testWidgets(
    'falha ao salvar não mostra sucesso nem adiciona livro na lista',
    (tester) async {
      await tester.pumpWidget(LeiturasApp(storage: FalhaAoSalvar()));
      await tester.pumpAndSettle();
      await abrirCadastro(tester);
      await preencherCadastro(tester);
      await tester.tap(find.text('Salvar livro'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('A lista anterior foi mantida'),
        findsOneWidget,
      );
      expect(find.text('O Pequeno Príncipe'), findsNothing);
      expect(find.text('Sua lista está vazia.'), findsOneWidget);
    },
  );
}
