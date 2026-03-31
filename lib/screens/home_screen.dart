import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/services/item_service.dart';
import 'package:desapego/widgets/carousel_widget.dart';
import 'package:desapego/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dados mockados locais (enquanto não há itens no Firestore)
  static final List<ItemModel> _destaquesMock = [
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
      imagemAsset: 'assets/images/mesa_escritorio.jpg',
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
      imagemAsset: 'assets/images/camisas.png',
      destaque: true,
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
                  CarouselWidget(
                    itens: _destaquesMock,
                    onItemTap: (item) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetalheScreen(item: item)),
                    ),
                  ),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
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
    return StreamBuilder<List<ItemModel>>(
      stream: ItemService.listarTodos(),
      builder: (context, snapshot) {
        // Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        // Erro
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Erro ao carregar itens.',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          );
        }

        final itens = snapshot.data ?? [];

        // Sem dados ainda — mostra mock
        if (itens.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _destaquesMock
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ItemCard(
                          item: item,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetalheScreen(item: item)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        }

        // Dados do Firestore
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: itens.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => ItemCard(
            item: itens[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetalheScreen(item: itens[index])),
            ),
          ),
        );
      },
    );
  }
}