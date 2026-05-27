import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirebaseDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colecao = 'itens';

  String gerarNovoId() {
    return _db.collection(_colecao).doc().id;
  }

  Future<void> salvarItem(ItemModel item) async {
    if (item.id == null) {
      throw Exception('O item precisa ter um ID para ser salvo.');
    }

    await _db.collection(_colecao).doc(item.id).set(item.toMap());
  }

  Stream<List<ItemModel>> listarItens() {
    return _db
        .collection(_colecao)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<ItemModel>> listarDestaques() {
    return _db
        .collection(_colecao)
        .where('destaque', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> deletarItem(String id) async {
    await _db.collection(_colecao).doc(id).delete();
  }

  Stream<List<ItemModel>> listarItensDoUsuario(String uid) {
    return _db
        .collection(_colecao)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
