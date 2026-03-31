import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/item_model.dart';

class ItemService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'itens';

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
    // Na web não tem compressão nativa — já vem comprimido pelo image_picker
    if (bytes.lengthInBytes > 900 * 1024) {
      throw Exception('Imagem muito grande. Tente uma foto menor.');
    }
    return base64Encode(bytes);
  }

  static Future<void> salvar(
    ItemModel item, {
    File? imagem, // mobile/desktop
    Uint8List? imagemBytes, // web
  }) async {
    final docRef = _db.collection(_col).doc();

    String? imagemBase64;
    if (kIsWeb && imagemBytes != null) {
      imagemBase64 = await _bytesParaBase64(imagemBytes);
    } else if (!kIsWeb && imagem != null) {
      imagemBase64 = await _imagemParaBase64(imagem);
    }

    final itemFinal = ItemModel(
      id: docRef.id,
      nome: item.nome,
      descricao: item.descricao,
      categoria: item.categoria,
      preco: item.preco,
      nomeContato: item.nomeContato,
      contato: item.contato,
      imagemBase64: imagemBase64,
      destaque: item.destaque,
      criadoEm: item.criadoEm,
    );

    await docRef.set(itemFinal.toMap());
  }

  static Stream<List<ItemModel>> listarTodos() {
    return _db
        .collection(_col)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ItemModel.fromMap(d.data())).toList(),
        );
  }

  static Stream<List<ItemModel>> listarDestaques() {
    return _db
        .collection(_col)
        .where('destaque', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ItemModel.fromMap(d.data())).toList(),
        );
  }
}
