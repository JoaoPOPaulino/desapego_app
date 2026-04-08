import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/services/item_service.dart';
import 'package:desapego/widgets/carousel_widget.dart';
import 'package:desapego/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/item_model.dart';
import '../data/mock_data.dart';

// Mesmo scroll behavior da ExplorarScreen
class _AllScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const int _totalCarrossel = 3;

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
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: ItemService.listarTodos(),
                builder: (context, snapshot) {
                  final itensFirestore = snapshot.data ?? [];
                  final todosItens = [...MockData.itens, ...itensFirestore]
                    ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
                  final itensCarrossel =
                      todosItens.take(_totalCarrossel).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        if (itensCarrossel.isNotEmpty)
                          CarouselWidget(
                            itens: itensCarrossel,
                            onItemTap: (item) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalheScreen(item: item),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),
                        _buildRecentesHeader(context),
                        const SizedBox(height: 10),

                        _buildLista(context, todosItens, snapshot),

                        const SizedBox(height: 16),
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

  // ── Header consistente com ExplorarScreen ──────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Desapego+',
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
          // Botão de notificação
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recentes',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Ver todos',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(
    BuildContext context,
    List<ItemModel> todosItens,
    AsyncSnapshot<List<ItemModel>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        todosItens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Color(0xFFB4B2A9),
              ),
              const SizedBox(height: 12),
              Text(
                'Erro ao carregar itens.',
                style: TextStyle(color: Colors.red[300], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (todosItens.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E7E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 32,
                  color: Color(0xFFB4B2A9),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum item cadastrado ainda.',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: todosItens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = todosItens[index];
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