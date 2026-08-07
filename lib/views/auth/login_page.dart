import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SizedBox(
              width: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  // Logo
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                     
                      child:  Image.asset("assets/logo-galana.webp",fit: BoxFit.contain,)
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "GALANA HSSE",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Inspections & Conformité",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Bienvenue",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Connectez-vous à votre espace HSSE",
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Adresse e-mail",
                      hintText: "nom.prenom@galana.mg",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      hintText: "••••••••",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Se souvenir de moi"),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: const Text("Mot de passe oublié ?"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      },
                      child: const Text("Se connecter"),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("OU", style: theme.textTheme.bodySmall),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.fingerprint),
                      label: const Text("Connexion biométrique"),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pas encore de compte ? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Color(0xFF0F9D58),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Version 1.0.0",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "GALANA Madagascar",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
