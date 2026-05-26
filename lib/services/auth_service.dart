import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get usuarioAtual => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Stream<UsuarioModel?> usuarioAtualStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _db.collection('usuarios').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return UsuarioModel.fromMap(data);
    });
  }

  static Future<UsuarioModel?> buscarUsuarioAtual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('usuarios').doc(user.uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;

    return UsuarioModel.fromMap(data);
  }

  static Future<void> cadastrarUsuario({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
    required String telefone,
    required String cep,
    required String logradouro,
    required String numero,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    if (senha.length < 6) {
      throw Exception('A senha deve ter no minimo 6 caracteres');
    }

    UserCredential credencial;

    try {
      credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensagemAuth(e));
    }

    final usuario = UsuarioModel(
      uid: credencial.user!.uid,
      nome: nome,
      cpf: cpf,
      email: email,
      telefone: telefone,
      cep: cep,
      logradouro: logradouro,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
      criadoEm: DateTime.now(),
    );

    try {
      await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
    } on FirebaseException catch (e) {
      await credencial.user?.delete();
      throw Exception(_mensagemFirestore(e));
    } catch (_) {
      await credencial.user?.delete();
      throw Exception('Nao foi possivel salvar os dados do usuario.');
    }
  }

  static Future<void> login({
    required String login,
    required String senha,
  }) async {
    String email = login.trim();

    final somenteNumeros = login.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      if (!email.contains('@')) {
        final resultado = await _db
            .collection('usuarios')
            .where('cpf', isEqualTo: somenteNumeros)
            .limit(1)
            .get();

        if (resultado.docs.isEmpty) {
          throw Exception('CPF nao encontrado');
        }

        email = resultado.docs.first.data()['email'];
      }

      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensagemAuth(e));
    } on FirebaseException catch (e) {
      throw Exception(_mensagemFirestore(e));
    }
  }

  static Future<void> sair() {
    return _auth.signOut();
  }

  static String _mensagemAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Ative o login por E-mail/senha no Firebase Authentication.';
      case 'email-already-in-use':
        return 'Este e-mail ja esta cadastrado.';
      case 'invalid-email':
        return 'E-mail invalido.';
      case 'weak-password':
        return 'A senha deve ter no minimo 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Login ou senha incorretos.';
      case 'network-request-failed':
        return 'Sem conexao com a internet.';
      default:
        return e.message ?? 'Erro de autenticacao: ${e.code}';
    }
  }

  static String _mensagemFirestore(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Sem permissao no Firestore. Verifique as regras do banco.';
    }

    return e.message ?? 'Erro no Firestore: ${e.code}';
  }
}
