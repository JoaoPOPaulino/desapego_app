import 'package:desapego/core/theme.dart';
import 'package:desapego/data/mock_data.dart';
import 'package:desapego/models/item_model.dart';
import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/services/item_service.dart';
import 'package:desapego/widgets/item_imagem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  String _categoriaSelecionada = 'Todos';
  String _busca = '';

  final List<String> _categorias = [
    'Todos',
    'Eletrônicos',
    'Móveis',
    'Roupas',
    'Livros',
    'Esportes',
    'Outros',
  ];

  List<ItemModel> _filtrar(List<ItemModel> itens) {
    return itens.where((item) {
      final categoriaOk =
          _categoriaSelecionada == 'Todos' ||
          item.categoria == _categoriaSelecionada;
      final buscaOk =
          _busca.isEmpty ||
          item.nome.toLowerCase().contains(_busca.toLowerCase()) ||
          item.descricao.toLowerCase().contains(_busca.toLowerCase());
      return categoriaOk && buscaOk;
    }).toList();
  }

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
            child: StreamBuilder<List<ItemModel>>(
              stream: ItemService.listarTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar itens.',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final itensFirestore = snapshot.data ?? [];

                final todos = [...MockData.itens, ...itensFirestore];
                final filtrados = _filtrar(todos);

                return Column(
                  children: [
                    _buildFiltros(),
                    _buildContador(filtrados.length),
                    Expanded(child: _buildGrid(context, filtrados)),
                  ],
                );
              },
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explorar',
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
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Buscar itens...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          final selecionado = cat == _categoriaSelecionada;

          return GestureDetector(
            onTap: () => setState(() => _categoriaSelecionada = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selecionado ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selecionado
                      ? AppTheme.primary
                      : const Color(0xFFD0CFC8),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selecionado ? Colors.white : const Color(0xFF888780),
                  fontSize: 13,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContador(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$total ${total == 1 ? 'item encontrado' : 'itens encontrados'}',
            style: const TextStyle(color: Color(0xFF888780), fontSize: 12),
          ),
          const Text(
            'Filtrar',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ItemModel> itens) {
    if (itens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Color(0xFFB4B2A9)),
            SizedBox(height: 12),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(color: Color(0xFF888780), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: itens.length,
      itemBuilder: (context, index) => _buildGridCard(context, itens[index]),
    );
  }

  Widget _buildGridCard(BuildContext context, ItemModel item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalheScreen(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEM + CATEGORIA
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: ItemImage(
                    item: item,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            //INFORMAÇÕES
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.isGratuito
                            ? 'Grátis'
                            : 'R\$ ${item.preco!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: item.isGratuito
                              ? AppTheme.primary
                              : AppTheme.priceGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _buildCategoriaTag(item.categoria),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaTag(String categoria) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Text(
        categoria,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
