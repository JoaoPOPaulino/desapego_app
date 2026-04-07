import 'package:desapego/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Dados mockados — trocar por autenticação real futuramente
  static const String _nome = 'João Silva';
  static const String _membroDesde = 'março de 2025';
  static const int _anuncios = 5;
  static const int _vendidos = 2;
  static const int _favoritos = 8;

  String get _iniciais {
    final partes = _nome.split(' ');
    return partes.length >= 2
        ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
        : _nome.substring(0, 2).toUpperCase();
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
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildEstatisticas(),
                  const SizedBox(height: 20),
                  _buildMenu(context),
                ],
              ),
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
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 28,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          // Avatar com iniciais
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _iniciais,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nome,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Membro desde $_membroDesde',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticas() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: [
          _buildStat('$_anuncios', 'Anúncios'),
          _buildDivisorVertical(),
          _buildStat('$_vendidos', 'Vendidos'),
          _buildDivisorVertical(),
          _buildStat('$_favoritos', 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildStat(String valor, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisorVertical() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE5E5E0),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final itens = [
      _MenuItem(
        icone: Icons.person_outline,
        label: 'Editar perfil',
        cor: AppTheme.primary,
        corFundo: const Color(0xFFEEEDFE),
        onTap: () => _emBreve(context, 'Editar perfil'),
      ),
      _MenuItem(
        icone: Icons.favorite_outline,
        label: 'Meus favoritos',
        cor: const Color(0xFF1D9E75),
        corFundo: const Color(0xFFE1F5EE),
        onTap: () => _emBreve(context, 'Meus favoritos'),
      ),
      _MenuItem(
        icone: Icons.help_outline,
        label: 'Ajuda e suporte',
        cor: const Color(0xFFEF9F27),
        corFundo: const Color(0xFFFFF4E0),
        onTap: () => _emBreve(context, 'Ajuda e suporte'),
      ),
      _MenuItem(
        icone: Icons.logout,
        label: 'Sair da conta',
        cor: const Color(0xFFE24B4A),
        corFundo: const Color(0xFFFDEDED),
        onTap: () => _confirmarSaida(context),
        isDestructive: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        children: List.generate(itens.length, (i) {
          final item = itens[i];
          final isUltimo = i == itens.length - 1;
          return Column(
            children: [
              _buildMenuItem(item),
              if (!isUltimo)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 56,
                  endIndent: 16,
                  color: Color(0xFFF0EFEF),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ícone com fundo colorido
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.corFundo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icone, color: item.cor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: item.isDestructive
                      ? const Color(0xFFE24B4A)
                      : const Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: item.isDestructive
                  ? const Color(0xFFE24B4A).withOpacity(0.5)
                  : const Color(0xFFB4B2A9),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _emBreve(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — em breve!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmarSaida(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alça
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFE24B4A),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sair da conta?',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Você precisará entrar novamente\npara acessar sua conta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888780),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFE5E5E0), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF888780),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B4A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo interno para os itens do menu
class _MenuItem {
  final IconData icone;
  final String label;
  final Color cor;
  final Color corFundo;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icone,
    required this.label,
    required this.cor,
    required this.corFundo,
    required this.onTap,
    this.isDestructive = false,
  });
}