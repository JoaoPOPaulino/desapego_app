import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String? id;
  final String? uid;
  final String nome;
  final String descricao;
  final String categoria;
  final String qualidade;
  final double? preco;
  final String? nomeContato;
  final String contato;
  final String? imagemUrl;
  final String? imagemAsset;
  final String? imagemBase64;
  final bool destaque;
  final DateTime criadoEm;

  ItemModel({
    this.id,
    this.uid,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.qualidade,
    this.preco,
    this.nomeContato,
    required this.contato,
    this.imagemUrl,
    this.imagemAsset,
    this.imagemBase64,
    this.destaque = false,
    required this.criadoEm,
  });

  bool get isGratuito => preco == null || preco == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'qualidade': qualidade,
      'preco': preco,
      'nomeContato': nomeContato,
      'contato': contato,
      'imagemUrl': imagemUrl,
      'imagemBase64': imagemBase64,
      'destaque': destaque,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    final criadoEmValor = map['criadoEm'];

    DateTime dataCriacao;
    if (criadoEmValor is Timestamp) {
      dataCriacao = criadoEmValor.toDate();
    } else if (criadoEmValor is String) {
      dataCriacao = DateTime.parse(criadoEmValor);
    } else {
      dataCriacao = DateTime.now();
    }

    return ItemModel(
      id: map['id'],
      uid: map['uid'],
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      categoria: map['categoria'] ?? 'Outros',
      preco: map['preco'] == null ? null : (map['preco'] as num).toDouble(),
      nomeContato: map['nomeContato'],
      contato: map['contato'] ?? '',
      imagemUrl: map['imagemUrl'],
      imagemBase64: map['imagemBase64'],
      qualidade: map['qualidade'] ?? 'Bom',
      destaque: map['destaque'] == true || map['destaque'] == 1,
      criadoEm: dataCriacao,
    );
  }
}
