// Integrante: Silvio Lopes — TP7: App de Organização de Leituras.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/livro.dart';

class LivrosStorage {
  LivrosStorage({Future<SharedPreferences> Function()? obterPreferencias})
    : _obterPreferencias = obterPreferencias ?? SharedPreferences.getInstance;

  static const chave = 'tp7_livros_v1';
  final Future<SharedPreferences> Function() _obterPreferencias;

  Future<List<Livro>> carregar() async {
    final prefs = await _obterPreferencias();
    final texto = prefs.getString(chave);
    if (texto == null) return [];
    final dynamic dados = jsonDecode(texto);
    if (dados is! List) {
      throw const FormatException('A coleção salva não é uma lista.');
    }
    final ids = <String>{};
    return dados.map((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Registro de livro inválido.');
      }
      final livro = Livro.fromJson(item);
      if (!ids.add(livro.id)) {
        throw const FormatException('Identificadores duplicados.');
      }
      return livro;
    }).toList();
  }

  Future<void> salvar(List<Livro> livros) async {
    final prefs = await _obterPreferencias();
    // SharedPreferences aceita valores simples. A coleção vira uma String JSON.
    final texto = jsonEncode(livros.map((livro) => livro.toJson()).toList());
    final sucesso = await prefs.setString(chave, texto);
    if (!sucesso) throw StateError('Não foi possível gravar a lista.');
  }
}
