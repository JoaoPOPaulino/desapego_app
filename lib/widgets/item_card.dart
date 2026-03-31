import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../core/theme.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  // Retorna a cor de fundo do thumbnail com base na categoria.
  // Usar um método separado deixa o build() mais limpo e
  // facilita adicionar novas categorias no futuro.
  Color _corFundoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'eletrônicos':
      case 'eletrônico':
        return const Color(0xFF1D3A30); // verde escuro
      case 'móveis':
        return const Color(0xFF2A2010); // marrom escuro
      case 'roupas':
        return const Color(0xFF2A2060); // azul/roxo escuro
      case 'livros':
        return const Color(0xFF1A2A3A); // azul escuro
      case 'esportes':
        return const Color(0xFF1A3020); // verde mais escuro
      default:
        return const Color(0xFF2C2C2E); // cinza padrão
    }
  }

  // Retorna o ícone correspondente à categoria.
  // Melhora a leitura visual — usuário identifica a categoria de relance.
  IconData _iconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'eletrônicos':
      case 'eletrônico':
        return Icons.devices_outlined;
      case 'móveis':
        return Icons.chair_outlined;
      case 'roupas':
        return Icons.checkroom_outlined;
      case 'livros':
        return Icons.menu_book_outlined;
      case 'esportes':
        return Icons.sports_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  // Retorna a cor do ícone — mais clara que o fundo para dar contraste
  Color _corIconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'eletrônicos':
      case 'eletrônico':
        return const Color(0xFF5DCAA5); // verde claro
      case 'móveis':
        return const Color(0xFFEF9F27); // âmbar
      case 'roupas':
        return const Color(0xFFAFA9EC); // roxo claro
      case 'livros':
        return const Color(0xFF85B7EB); // azul claro
      case 'esportes':
        return const Color(0xFF97C459); // verde vivo
      default:
        return const Color(0xFF888780); // cinza
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            _buildThumbnail(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        // Usa a cor da categoria em vez de uma cor fixa
        color: _corFundoCategoria(item.categoria),
        borderRadius: BorderRadius.circular(10),
      ),
      child: item.imagemUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Se tem imagem, mostra ela — requisito obrigatório do trabalho
              child: Image.network(item.imagemUrl!, fit: BoxFit.cover),
            )
          : Center(
              child: Icon(
                // Ícone correspondente à categoria
                _iconeCategoria(item.categoria),
                // Cor do ícone correspondente à categoria
                color: _corIconeCategoria(item.categoria),
                size: 26,
              ),
            ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do item
        Text(
          item.nome,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        // Descrição resumida — maxLines evita que quebre o layout
        Text(
          item.descricao,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // "..." quando o texto é longo
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Preço ou badge "Grátis"
            item.isGratuito ? _buildTagGratis() : _buildPreco(),
            // Tag da categoria
            _buildTagCategoria(),
          ],
        ),
      ],
    );
  }

  // Badge "Grátis" com fundo roxo claro
  Widget _buildTagGratis() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'Grátis',
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Texto do preço em verde
  Widget _buildPreco() {
    return Text(
      'R\$ ${item.preco!.toStringAsFixed(0)}',
      style: const TextStyle(
        color: AppTheme.priceGreen,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Tag da categoria com fundo escuro sutil
  Widget _buildTagCategoria() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.categoria,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
      ),
    );
  }
}
