import '../models/item_model.dart';

class MockData {
  static final List<ItemModel> itens = [
    ItemModel(
      id: '1',
      nome: 'Notebook Dell i5',
      descricao: 'Funcionando perfeitamente, 8GB RAM',
      categoria: 'Eletrônicos',
      preco: 1200,
      nomeContato: 'João Silva',
      contato: '(63) 9 9999-0000',
      imagemAsset: 'assets/images/notebook.png',
      destaque: true,
      criadoEm: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ItemModel(
      id: '2',
      nome: 'Mesa de escritório',
      descricao: 'Madeira maciça, 1.20m',
      categoria: 'Móveis',
      preco: 180,
      nomeContato: 'Maria Souza',
      contato: '(63) 9 8888-0000',
      imagemAsset: 'assets/images/mesa_escritorio.jpg',
      destaque: true,
      criadoEm: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ItemModel(
      id: '3',
      nome: 'Camisas masculinas',
      descricao: '3 camisas tamanho M',
      categoria: 'Roupas',
      preco: null,
      nomeContato: 'Pedro Lima',
      contato: '(63) 9 7777-0000',
      imagemAsset: 'assets/images/camisas.png',
      destaque: true,
      criadoEm: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
}