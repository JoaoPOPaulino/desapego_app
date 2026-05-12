import 'package:desapego/core/theme.dart';
import 'package:desapego/data/mock_data.dart';
import 'package:desapego/models/item_model.dart';
import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/controllers/item_controller.dart';
import 'package:desapego/widgets/item_imagem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
//  Scroll behavior que aceita mouse + trackpad + touch (Web)
// ─────────────────────────────────────────────────────────────
class _AllScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

// ─────────────────────────────────────────────────────────────
//  Modelo de categoria com ícone
// ─────────────────────────────────────────────────────────────
class _Categoria {
  final String label;
  final IconData icon;
  const _Categoria(this.label, this.icon);
}

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen>
    with SingleTickerProviderStateMixin {
  String _categoriaSelecionada = 'Todos';
  String _busca = '';
  final TextEditingController _buscaCtrl = TextEditingController();
  late AnimationController _fadeCtrl;

  // ── Categorias com ícones ──────────────────────────────────
  final List<_Categoria> _categorias = const [
    _Categoria('Todos', Icons.apps_rounded),
    _Categoria('Eletrônicos', Icons.devices_rounded),
    _Categoria('Móveis', Icons.chair_rounded),
    _Categoria('Roupas', Icons.checkroom_rounded),
    _Categoria('Livros', Icons.menu_book_rounded),
    _Categoria('Esportes', Icons.sports_soccer_rounded),
    _Categoria('Outros', Icons.category_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Filtro ─────────────────────────────────────────────────
  List<ItemModel> _filtrar(List<ItemModel> itens) {
    return ItemController.filtrarItens(
      itens: itens,
      categoriaSelecionada: _categoriaSelecionada,
      busca: _busca,
    );
  }

  void _selecionarCategoria(String cat) {
    if (cat == _categoriaSelecionada) return;
    setState(() => _categoriaSelecionada = cat);
    _fadeCtrl
      ..reset()
      ..forward();
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ScrollConfiguration(
      behavior: _AllScrollBehavior(),
      child: ColoredBox(
        color: const Color(0xFFF4F3F0),
        child: Column(
          children: [
            _buildHeader(context),
            _buildCategorias(),
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: ItemController.listarTodos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildErro();
                  }

                  final itensFirestore = snapshot.data ?? [];
                  final todos = [...MockData.itens, ...itensFirestore];
                  final filtrados = _filtrar(todos);

                  return FadeTransition(
                    opacity: _fadeCtrl,
                    child: Column(
                      children: [
                        _buildBarraInfo(filtrados.length),
                        Expanded(child: _buildGrid(context, filtrados)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + localização
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primary,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Palmas, TO',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Botão de notificação (decorativo)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Campo de busca
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextField(
              controller: _buscaCtrl,
              onChanged: (v) => setState(() => _busca = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar itens, categorias...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.45),
                  size: 20,
                ),
                suffixIcon: _busca.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _buscaCtrl.clear();
                          setState(() => _busca = '');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withOpacity(0.45),
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categorias (horizontal scroll) ─────────────────────────
  Widget _buildCategorias() {
    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          // Lista scrollável
          SizedBox(
            height: 88,
            child: ScrollConfiguration(
              behavior: _AllScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final sel = cat.label == _categoriaSelecionada;
                  return _buildCategoriaChip(cat, sel);
                },
              ),
            ),
          ),

          // Divisor sutil na base do header
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaChip(_Categoria cat, bool sel) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _selecionarCategoria(cat.label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 70,
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? AppTheme.primary : Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  cat.icon,
                  size: 20,
                  color: sel ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cat.label,
                style: TextStyle(
                  color: sel ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Barra de info (contador + ordenação) ───────────────────
  Widget _buildBarraInfo(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$total ',
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: total == 1 ? 'item' : 'itens',
                  style: const TextStyle(
                    color: Color(0xFF888780),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 4),
              const Text(
                'Mais recentes',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, List<ItemModel> itens) {
    if (itens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E7E3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: Color(0xFFB4B2A9),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum item encontrado',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tente outra categoria ou busca',
              style: TextStyle(color: const Color(0xFF888780), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemCount: itens.length,
      itemBuilder: (context, index) => _buildCard(context, itens[index]),
    );
  }

  Widget _buildCard(BuildContext context, ItemModel item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalheScreen(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            SizedBox(
              height: 130,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ItemImage(
                      item: item,
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                    // Badge de preço sobreposto
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isGratuito
                              ? AppTheme.primary
                              : const Color(0xFF1D9E75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isGratuito
                              ? 'Grátis'
                              : 'R\$ ${item.preco!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Informações
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF888780),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Categoria tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoria,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado de erro ─────────────────────────────────────────
  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: Color(0xFFB4B2A9),
          ),
          const SizedBox(height: 12),
          Text(
            'Erro ao carregar itens',
            style: TextStyle(color: Colors.red[300], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
