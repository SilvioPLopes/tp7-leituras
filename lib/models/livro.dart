// Integrante: Silvio Lopes — TP7: App de Organização de Leituras.
enum StatusLeitura {
  queroLer('quero_ler', 'Quero ler'),
  lendo('lendo', 'Lendo'),
  concluido('concluido', 'Concluído');

  const StatusLeitura(this.codigo, this.rotulo);
  final String codigo;
  final String rotulo;
}

class Livro {
  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.status,
  });

  final String id;
  final String titulo;
  final String autor;
  final StatusLeitura status;

  Livro comStatus(StatusLeitura novoStatus) =>
      Livro(id: id, titulo: titulo, autor: autor, status: novoStatus);

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'autor': autor,
    'status': status.codigo,
  };

  factory Livro.fromJson(Map<String, dynamic> json) {
    for (final campo in ['id', 'titulo', 'autor', 'status']) {
      if (json[campo] is! String || (json[campo] as String).trim().isEmpty) {
        throw FormatException('Campo inválido: $campo.');
      }
    }
    final status = StatusLeitura.values.firstWhere(
      (item) => item.codigo == json['status'],
      orElse: () => throw const FormatException('Status de leitura inválido.'),
    );
    return Livro(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      status: status,
    );
  }
}
