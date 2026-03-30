import 'package:desapego/core/theme.dart';
import 'package:desapego/models/item_model.dart';
import 'package:flutter/material.dart';

class DetalheScreen extends StatelessWidget {
  final ItemModel item;

  const DetalheScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.contentBg,
      body: Column(
        children: [
          // Imagem ocupa o topo, empurra o conteúdo para baixo
          _buildHeroImage(context),

          // Conteúdo rolável abaixo da imagem
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  _buildDivider(),
                  _buildDescricao(),
                  _buildContato(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Botões fixos no fundo — ficam sempre visíveis
      bottomSheet: _buildBottomButtons(context),
    );
  }

  // ── Imagem Hero ──────────────────────────────────────
  Widget _buildHeroImage(BuildContext context) {
    return Stack(
      children: [
        // Imagem ou placeholder colorido
        Container(
          width: double.infinity,
          height: 260,
          color: const Color(0xFFE1F5EE),
          child: item.imagemUrl != null
              ? Image.network(
                  item.imagemUrl!,
                  fit: BoxFit.cover,
                  // Enquanto carrega, mostra um indicador
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  },
                  // Se der erro, mostra ícone
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFF1D9E75),
                    size: 64,
                  ),
                ),
        ),

        // Botão voltar flutuando sobre a imagem
        // Por quê SafeArea? Para respeitar o notch/status bar do celular
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),

        // Pontinhos do carrossel (visuais, indicam múltiplas fotos)
        Positioned(
          bottom: 12,
          right: 16,
          child: Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? Colors.white : Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Título, Tags e Preço ────────────────────────────
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e preço na mesma linha
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título ocupa o máximo de espaço disponível
              Expanded(
                child: Text(item.nome,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Preço alinhado à direita
              Text(
                item.isGratuito
                  ? 'Gratuito'
                  : 'R\$ ${item.preco!.toStringAsFixed(0)}',
                style: TextStyle(
                  color: item.isGratuito
                    ? AppTheme.primary
                    : AppTheme.priceGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tags lado a lado
          Row(
            children: [
              _buildTag(item.categoria,
                bg: const Color(0xFFEEEDFE),
                text: AppTheme.primary),
              const SizedBox(width: 8),
              _buildTag('Bom estado',
                bg: const Color(0xFFE1F5EE),
                text: const Color(0xFF0F6E56)),
            ],
          ),
        ],
      ),
    );
  }

  // Tag reutilizável (categoria, estado)
  Widget _buildTag(String label,
      {required Color bg, required Color text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
        style: TextStyle(
          color: text, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ── Linha divisória ─────────────────────────────────
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: const Color(0xFFE5E5E0),
    );
  }

  // ── Seção Descrição ─────────────────────────────────
  Widget _buildDescricao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label em maiúsculas — padrão visual do app
          const Text('DESCRIÇÃO',
            style: TextStyle(
              color: Color(0xFF888780),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.descricao,
            style: const TextStyle(
              color: Color(0xFF5F5E5A),
              fontSize: 14,
              height: 1.6, // espaçamento entre linhas
            ),
          ),
        ],
      ),
    );
  }

  // ── Card de Contato ─────────────────────────────────
  Widget _buildContato() {
    // Pega as iniciais do contato para o avatar
    // Ex: "João Silva" → "JS"
    final partes = item.contato.split(' ');
    final iniciais = partes.length >= 2
      ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
      : item.contato.substring(0, 2).toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CONTATO',
            style: TextStyle(
              color: Color(0xFF888780),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Avatar com iniciais
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(iniciais,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Anunciante',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                    const SizedBox(height: 2),
                    Text(item.contato,
                      style: const TextStyle(
                        color: Color(0xFF888780),
                        fontSize: 12,
                      )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Botões de ação fixos no fundo ───────────────────
  // Por quê bottomSheet? Fica sempre visível independente do scroll,
  // facilitando a ação principal do usuário
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.contentBg,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Favoritar
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                // Mostra um feedback visual rápido (SnackBar)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adicionado aos favoritos!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Favoritar',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                )),
            ),
          ),

          const SizedBox(width: 10),

          // Entrar em contato
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _abrirWhatsApp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Entrar em contato',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
            ),
          ),
        ],
      ),
    );
  }

  // Simula abertura do WhatsApp
  void _abrirWhatsApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo contato: ${item.contato}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}