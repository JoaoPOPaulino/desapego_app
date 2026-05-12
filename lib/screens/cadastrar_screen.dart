import 'dart:io';
import 'package:desapego/core/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:desapego/models/item_model.dart';
import 'package:desapego/controllers/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String? _categoriaSelecionada;
  bool _isGratuito = false;
  bool _salvando = false;
  File? _imagemSelecionada;
  Uint8List? _imagemWebBytes;

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
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() => _imagemWebBytes = bytes);
      } else {
        setState(() => _imagemSelecionada = File(image.path));
      }
    }
  }

  void _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
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

      await ItemController.publicarItem(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoria: _categoriaSelecionada!,
        preco: _isGratuito
            ? null
            : double.tryParse(_valorController.text.replaceAll(',', '.')),
        nomeContato: _nomeContatoController.text.trim(),
        contato: _contatoController.text.trim(),
        imagem: kIsWeb ? null : _imagemSelecionada,
        imagemBytes: kIsWeb ? _imagemWebBytes : null,
      );

      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: const Text('Anúncio publicado com sucesso!'),
              backgroundColor: const Color(0xFF1D9E75),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
          .closed;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAreaFoto(),
                    const SizedBox(height: 20),
                    _buildSecaoLabel('Informações do item'),
                    const SizedBox(height: 10),
                    _buildCampo(
                      label: 'Nome do item',
                      controller: _nomeController,
                      placeholder: 'Ex: Mesa de escritório',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe o nome do item';
                        }
                        if (v.trim().length < 3) {
                          return 'Nome muito curto (mín. 3 caracteres)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Descrição',
                      controller: _descricaoController,
                      placeholder: 'Descreva o estado do item...',
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe a descrição';
                        }
                        if (v.trim().length < 10) {
                          return 'Descrição muito curta (mín. 10 caracteres)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildDropdownCategoria(),
                    const SizedBox(height: 20),
                    _buildSecaoLabel('Preço'),
                    const SizedBox(height: 10),
                    _buildTogglePreco(),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isGratuito
                          ? const SizedBox.shrink()
                          : _buildCampo(
                              key: const ValueKey('campo_valor'),
                              label: 'Valor (R\$)',
                              controller: _valorController,
                              placeholder: '0,00',
                              teclado: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,.]'),
                                ),
                              ],
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
                    const SizedBox(height: 20),
                    _buildSecaoLabel('Contato'),
                    const SizedBox(height: 10),
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
                      inputFormatters: [_telefoneMask],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o contato'
                          : null,
                    ),
                    const SizedBox(height: 28),
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

  // ── Rótulo de seção ────────────────────────────────────────
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

  // ── Header consistente com ExplorarScreen ──────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Novo anúncio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaFoto() {
    final temImagem = kIsWeb
        ? _imagemWebBytes != null
        : _imagemSelecionada != null;

    return GestureDetector(
      onTap: _selecionarImagem,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: temImagem ? AppTheme.primary : const Color(0xFFE5E5E0),
            width: temImagem ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: temImagem
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb
                        ? Image.memory(
                            _imagemWebBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _imagemSelecionada!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Adicionar foto',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Toque para selecionar da galeria',
                    style: TextStyle(color: Color(0xFF888780), fontSize: 11),
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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildDropdownCategoria() {
    const categoriaInfo = {
      'Eletrônicos': (
        Icons.devices_outlined,
        Color(0xFF5DCAA5),
        Color(0xFF1D3A30),
      ),
      'Móveis': (Icons.chair_outlined, Color(0xFFEF9F27), Color(0xFF2A2010)),
      'Roupas': (
        Icons.checkroom_outlined,
        Color(0xFFAFA9EC),
        Color(0xFF2A2060),
      ),
      'Livros': (
        Icons.menu_book_outlined,
        Color(0xFF85B7EB),
        Color(0xFF1A2A3A),
      ),
      'Esportes': (Icons.sports_outlined, Color(0xFF97C459), Color(0xFF1A3020)),
      'Outros': (
        Icons.inventory_2_outlined,
        Color(0xFF888780),
        Color(0xFF2C2C2E),
      ),
    };

    return FormField<String>(
      initialValue: _categoriaSelecionada,
      validator: (v) => v == null ? 'Selecione uma categoria' : null,
      builder: (field) {
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
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: _categorias.map((cat) {
                final info = categoriaInfo[cat]!;
                final selecionado = _categoriaSelecionada == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() => _categoriaSelecionada = cat);
                    field.didChange(cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selecionado ? info.$3 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selecionado ? info.$2 : const Color(0xFFE5E5E0),
                        width: selecionado ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: info.$2.withOpacity(
                              selecionado ? 0.2 : 0.12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(info.$1, color: info.$2, size: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat,
                          style: TextStyle(
                            color: selecionado
                                ? Colors.white
                                : const Color(0xFF5F5E5A),
                            fontSize: 11,
                            fontWeight: selecionado
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: Color(0xFFE24B4A),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTogglePreco() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isGratuito = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: !_isGratuito ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isGratuito
                      ? AppTheme.primary
                      : const Color(0xFFE5E5E0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sell_outlined,
                    size: 15,
                    color: !_isGratuito
                        ? Colors.white
                        : const Color(0xFF888780),
                  ),
                  const SizedBox(width: 6),
                  Text(
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
                ],
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
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _isGratuito ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isGratuito
                      ? AppTheme.primary
                      : const Color(0xFFE5E5E0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 15,
                    color: _isGratuito ? Colors.white : const Color(0xFF888780),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Doação',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isGratuito
                          ? Colors.white
                          : const Color(0xFF888780),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoPublicar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _salvando ? null : _publicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A2E),
          disabledBackgroundColor: const Color(0xFF1A1A2E).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _salvando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Publicar anúncio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
