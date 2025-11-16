import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../screens/login/login_screen.dart';

typedef ProtectedBuilder = Widget Function(BuildContext context);

class ProtectedScreen extends StatefulWidget {
  final ProtectedBuilder builder;
  const ProtectedScreen({super.key, required this.builder});

  @override
  State<ProtectedScreen> createState() => _ProtectedScreenState();
}

class _ProtectedScreenState extends State<ProtectedScreen> {
  bool _checking = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final token = await AuthStorage.getToken();
    if (!mounted) return;
    setState(() {
      _authorized = token != null && token.isNotEmpty;
      _checking = false;
    });
    if (!_authorized && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_authorized) {
      return const SizedBox.shrink();
    }
    return widget.builder(context);
  }
}


