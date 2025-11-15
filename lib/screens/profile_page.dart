import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../components/organisms/profile_form.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: Center(child: GlassPanel(child: const ProfileForm())),
    );
  }
}
