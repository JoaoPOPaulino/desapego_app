import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/item_model.dart';
import 'firebase_database_service.dart';

class ItemService {
  static final FirebaseDatabaseService _database = FirebaseDatabaseService();

  static Future<String?> _imagemParaBase64(File imagem) async {
    final comprimida = await FlutterImageCompress.compressWithFile(
      imagem.absolute.path,
      minWidth: 600,
      minHeight: 600,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (comprimida == null) return null;

    if (comprimida.lengthInBytes > 900 * 1024) {
      throw Exception('Imagem muito grande. Tente uma foto menor.');
    }

    return base64Encode(comprimida);
  }

  static Future<String?> _bytesParaBase64(Uint8List bytes) async {
    if (bytes.lengthInBytes > 900 * 1024) {
      throw Exception('Imagem muito grande. Tente uma foto menor.');
    }

    return base64Encode(bytes);
  }

  static Future<void> salvar(
    ItemModel item, {
    File? imagem,
    Uint8List? imagemBytes,
  }) async {
    final id = item.id ?? _database.gerarNovoId();

    String? imagemBase64;

    if (kIsWeb && imagemBytes != null) {
      imagemBase64 = await _bytesParaBase64(imagemBytes);
    } else if (!kIsWeb && imagem != null) {
      imagemBase64 = await _imagemParaBase64(imagem);
    }

    final itemFinal = ItemModel(
      id: id,
      uid: item.uid,
      nome: item.nome,
      descricao: item.descricao,
      categoria: item.categoria,
      qualidade: item.qualidade,
      preco: item.preco,
      nomeContato: item.nomeContato,
      contato: item.contato,
      imagemUrl: item.imagemUrl,
      imagemAsset: item.imagemAsset,
      imagemBase64: imagemBase64,
      destaque: item.destaque,
      criadoEm: item.criadoEm,
    );

    await _database.salvarItem(itemFinal);
  }

  static Stream<List<ItemModel>> listarTodos() {
    return _database.listarItens();
  }

  static Stream<List<ItemModel>> listarDestaques() {
    return _database.listarDestaques();
  }

  static Future<void> deletar(String id) {
    return _database.deletarItem(id);
  }

  static Stream<List<ItemModel>> listarMeusAnuncios(String uid) {
    return _database.listarItensDoUsuario(uid);
  }
}
