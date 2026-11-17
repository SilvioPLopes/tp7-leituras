// Integrante: Silvio Lopes — TP7: App de Organização de Leituras.
import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/livros_storage.dart';
import 'cadastro_livro_page.dart';

class ListaLivrosPage extends StatefulWidget {
  const ListaLivrosPage({super.key, required this.storage});
  final LivrosStorage storage;

  @override
  State<ListaLivrosPage> createState() => _ListaLivrosPageState();
}

class _ListaLivrosPageState extends State<ListaLivrosPage> {
  List<Livro> _livros = [];
  bool _carregando = true;
  bool _ocupado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final livros = await widget.storage.carregar();
      if (!mounted) return;
      setState(() => _livros = livros);
    } catch (_) {
      if (!mounted) return;
      // Bloqueia alterações para não sobrescrever dados que falharam na leitura.
      setState(
        () =>
            _erro = 'Não foi possível recuperar seus livros. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _salvar(List<Livro> novaLista, String mensagem) async {
    try {
      // Confirma a gravação antes de atualizar a lista e anunciar sucesso.
      await widget.storage.salvar(novaLista);
      if (!mounted) return;
      setState(() => _livros = novaLista);
      _avisar(mensagem);
    } catch (_) {
      _avisar(
        'Não foi possível salvar. A lista anterior foi mantida. Tente novamente.',
      );
    }
  }

  Future<void> _adicionar() async {
    if (_ocupado || _carregando || _erro != null) return;
    setState(() => _ocupado = true);
    try {
      final livro = await Navigator.push<Livro>(
        context,
        MaterialPageRoute(builder: (_) => const CadastroLivroPage()),
      );
      if (!mounted || livro == null) return;
      await _salvar([..._livros, livro], 'Livro adicionado com sucesso.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _remover(Livro livro) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remover livro?'),
          content: Text('Deseja remover “${livro.titulo}” da sua lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        ),
      );
      if (!mounted || confirmou != true) return;
      await _salvar(
        _livros.where((item) => item.id != livro.id).toList(),
        'Livro removido com sucesso.',
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _mudarStatus(Livro livro, StatusLeitura? status) async {
    if (_ocupado || status == null || status == livro.status) return;
    setState(() => _ocupado = true);
    try {
      await _salvar(
        _livros
            .map((item) => item.id == livro.id ? item.comStatus(status) : item)
            .toList(),
        'Status atualizado com sucesso.',
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 16),
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    // A tela inicial sempre apresenta um ListView, inclusive quando está vazia.
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
      children: [
        Text(
          'Sua próxima história começa aqui',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('${_livros.length} livro(s) na sua estante'),
        const SizedBox(height: 24),
        if (_livros.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.auto_stories_outlined, size: 52),
                  SizedBox(height: 16),
                  Text('Sua lista está vazia.'),
                  SizedBox(height: 8),
                  Text(
                    'Toque em Novo livro para começar.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        for (final livro in _livros)
          Card(
            key: ValueKey(livro.id),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4, right: 12),
                        child: Icon(Icons.menu_book_outlined),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              livro.titulo,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(livro.autor),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remover ${livro.titulo}',
                        onPressed: _ocupado ? null : () => _remover(livro),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<StatusLeitura>(
                    key: ValueKey('status-${livro.id}'),
                    value: livro.status,
                    isExpanded: true,
                    items: StatusLeitura.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.rotulo),
                      );
                    }).toList(),
                    onChanged: _ocupado
                        ? null
                        : (status) => _mudarStatus(livro, status),
                  ),
                ],
              ),
            ),
          ),
      ],
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
            Text('Minhas leituras'),
            Text('Silvio Lopes', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _conteudo(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _carregando || _ocupado || _erro != null ? null : _adicionar,
        icon: const Icon(Icons.add),
        label: const Text('Novo livro'),
      ),
    );
  }
}
