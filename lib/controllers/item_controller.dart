import 'dart:io';
import 'dart:typed_data';

import 'package:desapego/services/auth_service.dart';
import 'package:desapego/services/ia_service.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemController {
  static Stream<List<ItemModel>> listarTodos() {
    return ItemService.listarTodos();
  }

  static Stream<List<ItemModel>> listarDestaques() {
    return ItemService.listarDestaques();
  }

  static Future<void> publicarItem({
    required String nome,
    required String descricao,
    required String categoria,
    required String qualidade,
    required double? preco,
    required String nomeContato,
    required String contato,
    File? imagem,
    Uint8List? imagemBytes,
  }) async {
    final usuario = AuthService.usuarioAtual;

    final novoItem = ItemModel(
      uid: usuario?.uid,
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      qualidade: qualidade,
      preco: preco,
      nomeContato: nomeContato,
      contato: contato,
      criadoEm: DateTime.now(),
    );

    await ItemService.salvar(
      novoItem,
      imagem: imagem,
      imagemBytes: imagemBytes,
    );
  }

  static List<ItemModel> filtrarItens({
    required List<ItemModel> itens,
    required String categoriaSelecionada,
    required String busca,
  }) {
    return itens.where((item) {
      final categoriaOk =
          categoriaSelecionada == 'Todos' ||
          item.categoria == categoriaSelecionada;

      final buscaOk =
          busca.isEmpty ||
          item.nome.toLowerCase().contains(busca.toLowerCase()) ||
          item.descricao.toLowerCase().contains(busca.toLowerCase());

      return categoriaOk && buscaOk;
    }).toList();
  }

  static Future<void> deletarItem(String id) {
    return ItemService.deletar(id);
  }

  static Stream<List<ItemModel>> listarMeusAnuncios(String uid) {
  return ItemService.listarMeusAnuncios(uid);
}

static Future<Map<String, dynamic>> sugerirDadosComIA({
  required String nome,
  required String descricao,
  required String qualidade,
}) {
  return IaService.sugerirAnuncio(
    nome: nome,
    descricao: descricao,
    qualidade: qualidade,
  );
}
}
