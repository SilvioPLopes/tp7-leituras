import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp7_leituras/models/livro.dart';
import 'package:tp7_leituras/services/livros_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('primeira abertura retorna lista vazia', () async {
    expect(await LivrosStorage().carregar(), isEmpty);
  });

  test(
    'salva e recupera coleção com os três status e caracteres especiais',
    () async {
      final livros = [
        for (final status in StatusLeitura.values)
          Livro(
            id: status.codigo,
            titulo: 'Ação & Memória',
            autor: 'João "Silva"',
            status: status,
          ),
      ];
      await LivrosStorage().salvar(livros);
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString(LivrosStorage.chave)!), isA<List>());
      // Outra instância usa a coleção já armazenada, não a lista em memória.
      final restaurados = await LivrosStorage().carregar();
      expect(
        restaurados.map((livro) => livro.toJson()).toList(),
        livros.map((livro) => livro.toJson()).toList(),
      );
    },
  );

  test('remover último livro persiste uma coleção vazia', () async {
    await LivrosStorage().salvar([
      const Livro(
        id: '1',
        titulo: 'Dom Casmurro',
        autor: 'Machado de Assis',
        status: StatusLeitura.lendo,
      ),
    ]);
    await LivrosStorage().salvar([]);
    expect(await LivrosStorage().carregar(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LivrosStorage.chave), '[]');
  });

  test('JSON corrompido gera erro sem apagar a preferência', () async {
    SharedPreferences.setMockInitialValues({LivrosStorage.chave: '{inválido'});
    await expectLater(LivrosStorage().carregar(), throwsFormatException);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LivrosStorage.chave), '{inválido');
  });

  test('status desconhecido não é aceito silenciosamente', () async {
    SharedPreferences.setMockInitialValues({
      LivrosStorage.chave:
          '[{"id":"1","titulo":"Livro","autor":"Autor","status":"invalido"}]',
    });
    await expectLater(LivrosStorage().carregar(), throwsFormatException);
  });

  test('falha ao acessar preferências é propagada', () async {
    final storage = LivrosStorage(
      obterPreferencias: () async {
        throw StateError('Armazenamento indisponível');
      },
    );
    await expectLater(storage.salvar([]), throwsStateError);
  });
}
