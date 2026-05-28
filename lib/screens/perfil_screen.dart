import 'package:desapego/core/theme.dart';
import 'package:desapego/models/usuario_model.dart';
import 'package:desapego/screens/login_screen.dart';
import 'package:desapego/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return StreamBuilder<UsuarioModel?>(
      stream: AuthService.usuarioAtualStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(
            color: AppTheme.contentBg,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final usuario = snapshot.data;

        if (usuario == null) {
          return ColoredBox(
            color: AppTheme.contentBg,
            child: Column(
              children: [
                _buildSimpleHeader(context),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Dados do usuario nao encontrados.',
                      style: TextStyle(color: Color(0xFF888780)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ColoredBox(
          color: AppTheme.contentBg,
          child: Column(
            children: [
              _buildHeader(context, usuario),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildEstatisticas(),
                      const SizedBox(height: 20),
                      _buildSecaoLabel('Dados da conta'),
                      const SizedBox(height: 10),
                      _buildDadosConta(usuario),
                      const SizedBox(height: 20),
                      _buildSecaoLabel('Menu'),
                      const SizedBox(height: 10),
                      _buildMenu(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: const Text(
        'Perfil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UsuarioModel usuario) {
    final iniciais = _iniciais(usuario.nome);
    final cidadeUf = _cidadeUf(usuario);
    final membroDesde = _membroDesde(usuario.criadoEm);

    return Container(
      width: double.infinity,
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                iniciais,
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
            usuario.nome,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            usuario.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white.withOpacity(0.45),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                cidadeUf,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.calendar_today_rounded,
                color: Colors.white.withOpacity(0.45),
                size: 11,
              ),
              const SizedBox(width: 4),
              Text(
                membroDesde,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF888780),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildEstatisticas() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('itens')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, itensSnapshot) {
        if (!itensSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = itensSnapshot.data!.docs;

        final anuncios = docs.length;

        final vendidos = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['status'] ?? '') == 'vendido';
        }).length;

        final favoritos = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['favoritado'] ?? false) == true;
        }).length;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStat('$anuncios', 'Anuncios', Icons.campaign_outlined),
              _buildDivisorVertical(),
              _buildStat('$vendidos', 'Vendidos', Icons.sell_outlined),
              _buildDivisorVertical(),
              _buildStat('$favoritos', 'Favoritos', Icons.favorite_outline),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String valor, String label, IconData icone) {
    return Expanded(
      child: Column(
        children: [
          Icon(icone, size: 18, color: AppTheme.primary),
          const SizedBox(height: 6),
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
            style: const TextStyle(color: Color(0xFF888780), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisorVertical() {
    return Container(width: 1, height: 48, color: const Color(0xFFE5E5E0));
  }

  Widget _buildDadosConta(UsuarioModel usuario) {
    final endereco = _enderecoCompleto(usuario);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(
            icone: Icons.badge_outlined,
            label: 'CPF',
            valor: _formatarCpf(usuario.cpf),
            cor: AppTheme.primary,
            corFundo: const Color(0xFFEEEDFE),
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Color(0xFFF0EFEF),
          ),
          _InfoTile(
            icone: Icons.phone_outlined,
            label: 'Telefone',
            valor: usuario.telefone,
            cor: const Color(0xFF1D9E75),
            corFundo: const Color(0xFFE1F5EE),
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Color(0xFFF0EFEF),
          ),
          _InfoTile(
            icone: Icons.location_on_outlined,
            label: 'Endereco',
            valor: endereco,
            cor: const Color(0xFFEF9F27),
            corFundo: const Color(0xFFFFF4E0),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
        content: Text('$label em breve!'),
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
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              decoration: const BoxDecoration(
                color: Color(0xFFFDEDED),
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
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE5E5E0),
                        width: 1.5,
                      ),
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
                    onPressed: () async {
                      Navigator.pop(sheetContext);

                      await AuthService.sair();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
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

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.isEmpty
        ? '?'
        : nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _cidadeUf(UsuarioModel usuario) {
    if (usuario.cidade.isEmpty && usuario.uf.isEmpty) {
      return 'Local nao informado';
    }
    if (usuario.uf.isEmpty) {
      return usuario.cidade;
    }
    if (usuario.cidade.isEmpty) {
      return usuario.uf;
    }
    return '${usuario.cidade}, ${usuario.uf}';
  }

  String _membroDesde(DateTime? data) {
    if (data == null) return 'Membro desde hoje';
    return 'Membro desde ${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _enderecoCompleto(UsuarioModel usuario) {
    final partes = [
      usuario.logradouro,
      if (usuario.numero.isNotEmpty) 'No ${usuario.numero}',
      usuario.bairro,
      _cidadeUf(usuario),
    ].where((parte) => parte.trim().isNotEmpty).join('\n');

    final cep = usuario.cep.isEmpty ? '' : 'CEP ${usuario.cep}';
    if (partes.isEmpty) return cep.isEmpty ? 'Endereco nao informado' : cep;
    return cep.isEmpty ? partes : '$partes\n$cep';
  }

  String _formatarCpf(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 11) return cpf;
    return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;
  final Color cor;
  final Color corFundo;

  const _InfoTile({
    required this.icone,
    required this.label,
    required this.valor,
    required this.cor,
    required this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF888780),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
