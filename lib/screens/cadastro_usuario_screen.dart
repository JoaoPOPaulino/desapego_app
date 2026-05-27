import 'package:desapego/core/theme.dart';
import 'package:desapego/services/auth_service.dart';
import 'package:desapego/services/cep_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  bool _ocultarSenha = true;
  bool _buscandoCep = false;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      _mostrarMensagem('Informe um CEP com 8 digitos', erro: true);
      return;
    }

    setState(() => _buscandoCep = true);

    try {
      final endereco = await CepService.buscarCep(cep);

      _logradouroController.text = endereco['logradouro'] ?? '';
      _bairroController.text = endereco['bairro'] ?? '';
      _cidadeController.text = endereco['localidade'] ?? '';
      _ufController.text = endereco['uf'] ?? '';

      if (!mounted) return;
      _mostrarMensagem('Endereco encontrado!');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao buscar CEP: ${e.toString()}', erro: true);
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await AuthService.cadastrarUsuario(
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        telefone: _telefoneController.text.trim(),
        cep: _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        uf: _ufController.text.trim().toUpperCase(),
      );

      if (!mounted) return;
      _mostrarMensagem('Conta criada com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao criar conta: ${e.toString()}', erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? const Color(0xFFE24B4A) : AppTheme.priceGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildSecaoLabel('Dados pessoais'),
                    const SizedBox(height: 10),
                    _buildCampo(
                      label: 'Nome completo',
                      controller: _nomeController,
                      placeholder: 'Ex: Joao Silva',
                      icon: Icons.person_outline,
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'CPF',
                      controller: _cpfController,
                      placeholder: '000.000.000-00',
                      icon: Icons.badge_outlined,
                      teclado: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (v) {
                        final cpf = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                        if (cpf.isEmpty) return 'Informe o CPF';
                        if (cpf.length != 11) return 'CPF deve ter 11 digitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Telefone',
                      controller: _telefoneController,
                      placeholder: '(63) 9 0000-0000',
                      icon: Icons.phone_outlined,
                      teclado: TextInputType.phone,
                      validator: _validarTelefone,
                    ),
                    const SizedBox(height: 20),
                    _buildSecaoLabel('Acesso'),
                    const SizedBox(height: 10),
                    _buildCampo(
                      label: 'E-mail',
                      controller: _emailController,
                      placeholder: 'seuemail@exemplo.com',
                      icon: Icons.mail_outline,
                      teclado: TextInputType.emailAddress,
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Senha',
                      controller: _senhaController,
                      placeholder: 'Minimo 6 caracteres',
                      icon: Icons.lock_outline,
                      obscureText: _ocultarSenha,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _ocultarSenha = !_ocultarSenha);
                        },
                        icon: Icon(
                          _ocultarSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF888780),
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a senha';
                        if (v.length < 6) {
                          return 'A senha deve ter no Minimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSecaoLabel('Endereco'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCampo(
                            label: 'CEP',
                            controller: _cepController,
                            placeholder: '77000-000',
                            icon: Icons.location_on_outlined,
                            teclado: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]'),
                              ),
                              LengthLimitingTextInputFormatter(8),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o CEP';
                              }
                              if (v.length != 8) return 'CEP invalido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          width: 52,
                          child: ElevatedButton(
                            onPressed: _buscandoCep ? null : _buscarCep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: _buscandoCep
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Logradouro',
                      controller: _logradouroController,
                      placeholder: 'Rua, avenida...',
                      icon: Icons.route_outlined,
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Numero',
                      controller: _numeroController,
                      placeholder: 'Ex: 120',
                      icon: Icons.home_outlined,
                      teclado: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9A-Za-z]'),
                        ),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 14),
                    _buildCampo(
                      label: 'Bairro',
                      controller: _bairroController,
                      placeholder: 'Seu bairro',
                      icon: Icons.apartment_outlined,
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildCampo(
                            label: 'Cidade',
                            controller: _cidadeController,
                            placeholder: 'Cidade',
                            icon: Icons.location_city_outlined,
                            validator: _obrigatorio,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCampo(
                            label: 'UF',
                            controller: _ufController,
                            placeholder: 'TO',
                            icon: Icons.map_outlined,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: _obrigatorio,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildBotaoCadastrar(),
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

  String? _obrigatorio(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obrigatorio';
    return null;
  }

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
              'Criar conta',
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

  Widget _buildCampo({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
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
          obscureText: obscureText,
          keyboardType: teclado,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFFB4B2A9), fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE24B4A)),
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

  Widget _buildBotaoCadastrar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _salvando ? null : _cadastrar,
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Criar conta',
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

String? _validarTelefone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe o telefone';
  }

  final telefone = value.replaceAll(RegExp(r'[^0-9]'), '');

  // Brasil: 10 ou 11 dígitos
  if (telefone.length < 10 || telefone.length > 11) {
    return 'Telefone inválido';
  }

  return null;
}

String? _validarEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe o e-mail';
  }

  final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  if (!emailRegex.hasMatch(value.trim())) {
    return 'E-mail inválido';
  }

  return null;
}
