import 'package:desapego/core/theme.dart';
import 'package:desapego/models/item_model.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

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
        color: const Color(0xFF1D3A30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: item.imagemUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(item.imagemUrl!, fit: BoxFit.cover),
            )
          : const Icon(Icons.image_outlined, color: Colors.white38, size: 26),
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
            item.isGratuito
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                  )
                : Text(
                    'R\$ ${item.preco!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.priceGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.categoria,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
