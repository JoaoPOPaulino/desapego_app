class ItemModel {
  final String? id;
  final String nome;
  final String descricao;
  final String categoria;
  final double? preco;
  final String contato;
  final String? imagemUrl;
  final bool destaque;
  final DateTime criadoEm;

  ItemModel({
    this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    this.preco,
    required this.contato,
    this.imagemUrl,
    this.destaque = false,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  bool get isGratuito => preco == null || preco == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'preco': preco,
      'contato': contato,
      'imagemUrl': imagemUrl,
      'destaque': destaque,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      preco: (map['preco'] as num?)?.toDouble(),
      contato: map['contato'],
      imagemUrl: map['imagemUrl'],
      destaque: map['destaque'] ?? false,
      criadoEm: DateTime.parse(map['criadoEm']),
    );
  }
}
