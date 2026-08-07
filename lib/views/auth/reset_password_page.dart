import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  double passwordStrength = 0.0;
  String passwordStrengthText = "Faible";
  Color passwordStrengthColor = Colors.red;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void checkPasswordStrength(String password) {
    double strength = 0;

    if (password.length >= 8) {
      strength += 0.25;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
        .hasMatch(password)) {
      strength += 0.25;
    }

    setState(() {
      passwordStrength = strength;

      if (strength <= 0.25) {
        passwordStrengthText = "Faible";
        passwordStrengthColor = Colors.red;
      } else if (strength <= 0.50) {
        passwordStrengthText = "Moyen";
        passwordStrengthColor =
            Colors.orange;
      } else if (strength <= 0.75) {
        passwordStrengthText = "Bon";
        passwordStrengthColor =
            Colors.lightGreen;
      } else {
        passwordStrengthText = "Fort";
        passwordStrengthColor =
            const Color(0xFF0F9D58);
      }
    });
  }

  void updatePassword() {
    final password =
        passwordController.text.trim();

    final confirmPassword =
        confirmPasswordController.text.trim();

    if (password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs.",
          ),
        ),
      );

      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Les mots de passe ne correspondent pas.",
          ),
        ),
      );

      return;
    }

    if (passwordStrength < 0.50) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Le mot de passe est trop faible.",
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Mot de passe mis à jour avec succès.",
        ),
      ),
    );

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Réinitialisation"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFE8F5EE),
                    borderRadius:
                        BorderRadius.circular(
                            28),
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    size: 52,
                    color:
                        Color(0xFF0F9D58),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Créer un nouveau mot de passe",
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme.headlineSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Veuillez définir un nouveau mot de passe sécurisé pour votre compte.",
                textAlign:
                    TextAlign.center,
                style:
                    theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller:
                    passwordController,
                obscureText:
                    obscurePassword,
                onChanged:
                    checkPasswordStrength,
                decoration:
                    InputDecoration(
                  labelText:
                      "Nouveau mot de passe",
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Sécurité du mot de passe : $passwordStrengthText",
                style: TextStyle(
                  color:
                      passwordStrengthColor,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                        10),
                child:
                    LinearProgressIndicator(
                  value: passwordStrength,
                  minHeight: 6,
                  backgroundColor:
                      Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation(
                    passwordStrengthColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller:
                    confirmPasswordController,
                obscureText:
                    obscureConfirmPassword,
                decoration:
                    InputDecoration(
                  labelText:
                      "Confirmer le mot de passe",
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding:
                    const EdgeInsets.all(
                        16),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                          0xFFE8F5EE),
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      "Exigences du mot de passe",
                      style: TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                        "• Minimum 8 caractères"),
                    Text(
                        "• Une lettre majuscule"),
                    Text(
                        "• Un chiffre"),
                    Text(
                        "• Un caractère spécial"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      updatePassword,
                  child: const Text(
                    "Mettre à jour le mot de passe",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}