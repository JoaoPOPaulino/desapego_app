import 'package:desapego/models/item_model.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

 static final List<ItemModel> _destaques = [
    ItemModel(
      id: '1',
      nome: 'Notebook Dell i5',
      descricao: 'Funcionando perfeitamente, 8GB RAM',
      categoria: 'Eletrônicos',
      preco: 1200,
      contato: '(63) 9 9999-0000',
      destaque: true,
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '2',
      nome: 'Mesa de escritório',
      descricao: 'Madeira maciça, 1.20m',
      categoria: 'Móveis',
      preco: 180,
      contato: '(63) 9 8888-0000',
      destaque: true,
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '3',
      nome: 'Camisas masculinas',
      descricao: '3 camisas tamanho M',
      categoria: 'Roupas',
      preco: null, // gratuito
      contato: '(63) 9 7777-0000',
      destaque: true,
      criadoEm: DateTime.now(),
    ),
  ];

  static final List<ItemModel> _recentes = [
    ItemModel(
      id: '4',
      nome: 'Mesa de escritório',
      descricao: 'Madeira, 1.20m, ótimo estado',
      categoria: 'Móveis',
      preco: 180,
      contato: '(63) 9 9999-1111',
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '5',
      nome: 'Camisas masculinas',
      descricao: '3 camisas tamanho M',
      categoria: 'Roupas',
      preco: null,
      contato: '(63) 9 9999-2222',
      criadoEm: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildCarousel(context),
                  const SizedBox(height: 20),
                  _buildRecenteHeader(context),
                ],
              ),
            ))
        ],
      ),
}