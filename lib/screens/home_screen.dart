import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/widgets/carousel_widget.dart';
import 'package:desapego/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<ItemModel> _destaques = [
    ItemModel(
      id: '1',
      nome: 'Notebook Dell i5',
      descricao: 'Funcionando perfeitamente, 8GB RAM',
      categoria: 'Eletrônicos',
      preco: 1200,
      nomeContato: 'João Silva',
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
      nomeContato: 'Maria Souza',
      contato: '(63) 9 8888-0000',
      destaque: true,
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '3',
      nome: 'Camisas masculinas',
      descricao: '3 camisas tamanho M',
      categoria: 'Roupas',
      preco: null,
      nomeContato: 'Pedro Lima',
      contato: '(63) 9 7777-0000',
      destaque: true,
      criadoEm: DateTime.now(),
    ),
  ];

  static final List<ItemModel> _recentes = [
    ItemModel(
      id: '4',
      nome: 'Monitor 21"',
      descricao: 'Samsung, Bom estado',
      categoria: 'Eletrônico',
      preco: 350,
      nomeContato: 'João Silva',
      contato: '(63) 9 9999-1111',
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '5',
      nome: 'Mesa de escritório',
      descricao: 'Madeira, 1.20m, ótimo estado',
      categoria: 'Móveis',
      preco: 180,
      nomeContato: 'Ana Costa',
      contato: '(63) 9 9999-2222',
      criadoEm: DateTime.now(),
    ),
    ItemModel(
      id: '6',
      nome: 'Camisas masculinas',
      descricao: '3 camisas tamanho M',
      categoria: 'Roupas',
      preco: null,
      nomeContato: 'Lucas Rocha',
      contato: '(63) 9 9999-3333',
      criadoEm: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.contentBg,
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
                  _buildRecentesHeader(context),
                  const SizedBox(height: 10),
                  _buildRecentesList(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Desapego+',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Palmas, TO',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                SizedBox(width: 14),
                Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Buscar itens...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return CarouselWidget(
      itens: _destaques,
      onItemTap: (item) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalheScreen(item: item)),
      ),
    );
  }

  Widget _buildRecentesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recentes',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Ver todos',
              style: TextStyle(color: AppTheme.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentesList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _recentes[index];
        return ItemCard(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetalheScreen(item: item)),
          ),
        );
      },
    );
  }
}
