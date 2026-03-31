import 'package:desapego/widgets/item_imagem.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../core/theme.dart';
import '../models/item_model.dart';

class CarouselWidget extends StatefulWidget {
  final List<ItemModel> itens;
  final Function(ItemModel) onItemTap;

  const CarouselWidget({
    super.key,
    required this.itens,
    required this.onItemTap,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _indiceAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            padEnds: true,
            onPageChanged: (index, reason) {
              setState(() => _indiceAtual = index);
            },
          ),
          items: widget.itens.map((item) {
            return GestureDetector(
              onTap: () => widget.onItemTap(item),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Destaque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.nome,
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
                              color: Color(0xFFD4D0FF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Imagem do item no carousel
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ItemImage(
                        item: item,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.itens.length, (i) {
            final bool ativo = i == _indiceAtual;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: ativo ? 20 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ativo ? 4 : 50),
                color:
                    ativo ? AppTheme.primary : Colors.grey.withOpacity(0.4),
              ),
            );
          }),
        ),
      ],
    );
  }
}