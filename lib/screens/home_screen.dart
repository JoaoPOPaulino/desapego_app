import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/widgets/itam_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../core/theme.dart';
import '../models/item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dados de exemplo para o carrossel (destaques)
  // Depois virão do Firestore
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

  // ── TopBar ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 12,
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
                  Text('Desapego+',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('Palmas, TO',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down,
                color: AppTheme.textPrimary, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de busca
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
                Text('Buscar itens...',
                  style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carrossel ────────────────────────────────────────
  Widget _buildCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        viewportFraction: 0.88,
        enlargeCenterPage: true,
        autoPlay: true,                   
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: _destaques.map((item) {
        return GestureDetector(
          // Comunicação entre telas: ao clicar, navega para Detalhe
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalheScreen(item: item),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Textos do lado esquerdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Destaque',
                          style: TextStyle(
                            color: Colors.white, fontSize: 10)),
                      ),
                      const SizedBox(height: 6),
                      Text(item.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isGratuito
                          ? 'Gratuito'
                          : 'R\$ ${item.preco!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFD4D0FF), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Placeholder da imagem (lado direito)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.imagemUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.imagemUrl!,
                          fit: BoxFit.cover),
                      )
                    : const Icon(Icons.image_outlined,
                        color: Colors.white54, size: 32),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Header "Recentes" ────────────────────────────────
  Widget _buildRecentesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Recentes',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {}, // futuramente navega para Explorar
            child: const Text('Ver todos',
              style: TextStyle(
                color: AppTheme.primary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Lista de itens recentes ──────────────────────────
  Widget _buildRecentesList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      // Importante: desabilita o scroll interno pois já tem
      // SingleChildScrollView no pai
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _recentes[index];
        // Usa o widget reutilizável ItemCard
        // Comunicação entre telas: passa o item para DetalheScreen
        return ItemCard(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalheScreen(item: item),
            ),
          ),
        );
      },
    );
  }
}