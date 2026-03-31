import 'dart:io';

import 'package:desapego/core/theme.dart';
import 'package:desapego/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' show ImageSource, ImagePicker;

class CadastrarScreen extends StatefulWidget {
  const CadastrarScreen({super.key});

  @override
  State<CadastrarScreen> createState() => _CadastrarScreenState();
}

class _CadastrarScreenState extends State<CadastrarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _contatoController = TextEditingController();
  final _nomeContatoController = TextEditingController();

  String? _categoriaSelecionada;

  bool _isGratuito = false;

  File? _imagemSelecionada;

  final List<String> _categorias = [
    'Eletrônicos',
    'Móveis',
    'Roupas',
    'Livros',
    'Esportes',
    'Outros',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _contatoController.dispose();
    _nomeContatoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagemSelecionada = File(image.path);
      });
    }
  }

  void _publicar() {
    if (!_formKey.currentState!.validate()) return;

    final novoItem = ItemModel(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaSelecionada!,
      preco: _isGratuito
          ? null
          : double.tryParse(_valorController.text.replaceAll(',', '.')),
      nomeContato: _nomeContatoController.text.trim(),
      contato: _contatoController.text.trim(),
      criadoEm: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anúncio publicado com sucesso!'),
        backgroundColor: Color(0xFF1D9E75),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAreaFoto(),
                    const SizedBox(height: 16),
                    _buildCampo(
                      label: 'Nome do item',
                      controller: _nomeController,
                      placeholder: 'Ex: Mesa de escritório',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o nome do item'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Descrição',
                      controller: _descricaoController,
                      placeholder: 'Descreva o estado do item...',
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe a descrição'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildDropdownCategoria(),
                    const SizedBox(height: 14),
                    _buildTogglePreco(),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isGratuito
                          ? const SizedBox.shrink() // widget vazio — some
                          : _buildCampo(
                              key: const ValueKey('campo_valor'),
                              label: 'Valor (R\$)',
                              controller: _valorController,
                              placeholder: '0,00',
                              // TextInputType.number abre teclado numérico
                              teclado: TextInputType.number,
                              validator: (v) {
                                if (_isGratuito) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Informe o valor';
                                }
                                final val = double.tryParse(
                                  v.replaceAll(',', '.'),
                                );
                                if (val == null || val <= 0) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Seu nome',
                      controller: _nomeContatoController,
                      placeholder: 'Ex: João Silva',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe seu nome'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'WhatsApp para contato',
                      controller: _contatoController,
                      placeholder: '(63) 9 0000-0000',
                      teclado: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o contato'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildBotaoPublicar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TopBar ───────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          // Botão voltar circular
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Novo anúncio',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Área de seleção de foto ──────────────────────────
  Widget _buildAreaFoto() {
    return GestureDetector(
      onTap: _selecionarImagem,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _imagemSelecionada != null
                ? AppTheme.primary
                : const Color(0xFFB4B2A9),
            width: 1.5,
          ),
        ),
        child: _imagemSelecionada != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imagemSelecionada!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: const Color(0xFFB4B2A9),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adicionar foto',
                    style: TextStyle(color: Color(0xFF888780), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Toque para selecionar',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCampo({
    Key? key,
    required String label,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      key: key,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: teclado,
          validator: validator,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFFB4B2A9), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E5E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE24B4A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Dropdown de categoria ────────────────────────────
  Widget _buildDropdownCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            color: Color(0xFF888780),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _categoriaSelecionada,
          hint: const Text(
            'Selecionar categoria',
            style: TextStyle(color: Color(0xFFB4B2A9), fontSize: 13),
          ),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E5E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE24B4A),
                width: 1.5,
              ),
            ),
          ),
          items: _categorias
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (valor) => setState(() {
            _categoriaSelecionada = valor;
          }),
          validator: (v) => v == null ? 'Selecione uma categoria' : null,
        ),
      ],
    );
  }

  // ── Toggle Com valor / Gratuito ──────────────────────
  Widget _buildTogglePreco() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preço',
          style: TextStyle(
            color: Color(0xFF888780),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isGratuito = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isGratuito ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: !_isGratuito
                          ? AppTheme.primary
                          : const Color(0xFFE5E5E0),
                    ),
                  ),
                  child: Text(
                    'Com valor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: !_isGratuito
                          ? Colors.white
                          : const Color(0xFF888780),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isGratuito = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isGratuito ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isGratuito
                          ? AppTheme.primary
                          : const Color(0xFFE5E5E0),
                    ),
                  ),
                  child: Text(
                    'Gratuito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isGratuito
                          ? Colors.white
                          : const Color(0xFF888780),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Botão Publicar ───────────────────────────────────
  Widget _buildBotaoPublicar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _publicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Publicar anúncio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
