// Integrante: Silvio Lopes — TP7: App de Organização de Leituras.
import 'package:flutter/material.dart';

import '../models/livro.dart';

class CadastroLivroPage extends StatefulWidget {
  const CadastroLivroPage({super.key});

  @override
  State<CadastroLivroPage> createState() => _CadastroLivroPageState();
}

class _CadastroLivroPageState extends State<CadastroLivroPage> {
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  StatusLeitura _status = StatusLeitura.queroLer;
  String? _erroTitulo;
  String? _erroAutor;
  bool _enviado = false;

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    super.dispose();
  }

  void _cadastrar() {
    if (_enviado) return;
    setState(() {
      _erroTitulo = _titulo.text.trim().isEmpty
          ? 'Informe o título do livro.'
          : null;
      _erroAutor = _autor.text.trim().isEmpty
          ? 'Informe o autor do livro.'
          : null;
    });
    if (_erroTitulo != null || _erroAutor != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha título e autor para continuar.'),
        ),
      );
      return;
    }
    _enviado = true;
    // Retorna o livro à tela inicial, que cuida da gravação persistente.
    Navigator.pop(
      context,
      Livro(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cadastrar livro'),
            Text('Silvio Lopes', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Uma nova história na sua lista',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe os dados do livro e escolha o status da leitura.',
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('titulo'),
                  controller: _titulo,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                    errorText: _erroTitulo,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('autor'),
                  controller: _autor,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Autor',
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _erroAutor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Status da leitura'),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.bookmark_border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<StatusLeitura>(
                      key: const Key('status'),
                      value: _status,
                      isExpanded: true,
                      isDense: true,
                      items: StatusLeitura.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.rotulo),
                        );
                      }).toList(),
                      onChanged: (status) {
                        if (status != null) setState(() => _status = status);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _cadastrar,
                  icon: const Icon(Icons.add),
                  label: const Text('Salvar livro'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
