import 'package:desapego/widgets/item_imagem.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../core/theme.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  Color _corFundoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'eletrônicos':
      case 'eletrônico':
        return const Color(0xFF1D3A30);
      case 'móveis':
        return const Color(0xFF2A2010);
      case 'roupas':
        return const Color(0xFF2A2060);
      case 'livros':
        return const Color(0xFF1A2A3A);
      case 'esportes':
        return const Color(0xFF1A3020);
      default:
        return const Color(0xFF2C2C2E);
    }
  }

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

  Color _corIconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'eletrônicos':
      case 'eletrônico':
        return const Color(0xFF5DCAA5);
      case 'móveis':
        return const Color(0xFFEF9F27);
      case 'roupas':
        return const Color(0xFFAFA9EC);
      case 'livros':
        return const Color(0xFF85B7EB);
      case 'esportes':
        return const Color(0xFF97C459);
      default:
        return const Color(0xFF888780);
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
    // Se tem qualquer imagem, usa o ItemImage
    if (item.imagemBase64 != null ||
        item.imagemUrl != null ||
        item.imagemAsset != null) {
      return ItemImage(
        item: item,
        width: 56,
        height: 56,
        borderRadius: BorderRadius.circular(10),
      );
    }

    // Sem imagem — mostra ícone da categoria
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _corFundoCategoria(item.categoria),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          _iconeCategoria(item.categoria),
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
        Text(
          item.nome,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.descricao,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            item.isGratuito ? _buildTagGratis() : _buildPreco(),
            _buildTagCategoria(),
          ],
        ),
      ],
    );
  }

  Widget _buildTagGratis() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'Doação',
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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

  Widget _buildTagCategoria() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Text(
        item.categoria,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
      ),
    );
  }
}
