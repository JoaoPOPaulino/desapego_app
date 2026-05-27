import 'package:desapego/core/theme.dart';
import 'package:desapego/screens/cadastrar_screen.dart';
import 'package:desapego/screens/explorar_screen.dart';
import 'package:desapego/screens/home_screen.dart';
import 'package:desapego/screens/login_screen.dart';
import 'package:desapego/screens/perfil_screen.dart';
import 'package:desapego/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:desapego/screens/meus_anuncios_screen.dart';

class DesapegoApp extends StatelessWidget {
  const DesapegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desapego+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: StreamBuilder(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppTheme.contentBg,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }

          if (snapshot.hasData) {
            return const MainScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExplorarScreen(),
    MeusAnunciosScreen(),
    PerfilScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CadastrarScreen()),
      );
      return;
    }

    final screenIndex = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = screenIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: const Color(0xFF28282B),
        selectedItemColor: const Color(0xFF534AB7),
        unselectedItemColor: const Color(0xFF6E6E73),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36, color: Color(0xFF534AB7)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Meus Anúncios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _EmBreve extends StatelessWidget {
  final String label;

  const _EmBreve({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.contentBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction_outlined,
              size: 48,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Em breve',
              style: TextStyle(color: Color(0xFF888780), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
