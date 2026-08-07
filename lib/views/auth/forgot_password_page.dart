import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    
    Navigator.pushNamed(context, AppRoutes.resetPassword);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Lien de réinitialisation envoyé.")),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    size: 52,
                    color: Color(0xFF0F9D58),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Réinitialiser votre mot de passe",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Saisissez votre adresse e-mail professionnelle. Un lien de réinitialisation vous sera envoyé.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Adresse e-mail",
                  hintText: "nom.prenom@galana.mg",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Envoyer le lien"),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Retour à la connexion"),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF0F9D58)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Si vous ne recevez pas l'e-mail dans quelques minutes, contactez l'administrateur HSSE.",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
