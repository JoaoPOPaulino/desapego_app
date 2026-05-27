import 'package:desapego/controllers/item_controller.dart';
import 'package:desapego/core/theme.dart';
import 'package:desapego/models/item_model.dart';
import 'package:desapego/screens/detalhe_screen.dart';
import 'package:desapego/services/auth_service.dart';
import 'package:desapego/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeusAnunciosScreen extends StatelessWidget {
  const MeusAnunciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioAtual;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (usuario == null) {
      return const Scaffold(
        backgroundColor: AppTheme.contentBg,
        body: Center(
          child: Text(
            'Usuario nao autenticado.',
            style: TextStyle(color: Color(0xFF888780)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.contentBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: ItemController.listarMeusAnuncios(usuario.uid),
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
                  return const Center(
                    child: Text(
                      'Erro ao carregar seus anuncios.',
                      style: TextStyle(color: Color(0xFFE24B4A)),
                    ),
                  );
                }

                final itens = snapshot.data ?? [];

                if (itens.isEmpty) {
                  return _buildVazio(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: itens.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = itens[index];

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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: const Text(
        'Meus Anuncios',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildVazio(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.list_alt_outlined,
                size: 32,
                color: Color(0xFFB4B2A9),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Voce ainda nao publicou anuncios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Toque no botao de adicionar para cadastrar um item.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888780), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
