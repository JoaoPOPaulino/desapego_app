import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;
  final DateTime? criadoEm;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'criadoEm': (criadoEm ?? DateTime.now()).toIso8601String(),
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    final criadoEmValor = map['criadoEm'];

    DateTime? dataCriacao;
    if (criadoEmValor is Timestamp) {
      dataCriacao = criadoEmValor.toDate();
    } else if (criadoEmValor is String) {
      dataCriacao = DateTime.tryParse(criadoEmValor);
    }

    return UsuarioModel(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      cep: map['cep'] ?? '',
      logradouro: map['logradouro'] ?? '',
      numero: map['numero'] ?? '',
      bairro: map['bairro'] ?? '',
      cidade: map['cidade'] ?? '',
      uf: map['uf'] ?? '',
      criadoEm: dataCriacao,
    );
  }
}
