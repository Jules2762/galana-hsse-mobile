import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/bottom_quick_action.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool loading = false;

  double passwordStrength = 0.0;

  String passwordStrengthText =
      "Faible";

  Color passwordStrengthColor =
      AppColors.danger;

  @override
  void dispose() {
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void checkPasswordStrength(
    String password,
  ) {
    double strength = 0;

    if (password.length >= 8) {
      strength += 0.25;
    }

    if (RegExp(r'[A-Z]')
        .hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[0-9]')
        .hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(
      r'[!@#\$%^&*(),.?":{}|<>]',
    ).hasMatch(password)) {
      strength += 0.25;
    }

    setState(() {
      passwordStrength = strength;

      if (strength <= 0.25) {
        passwordStrengthText =
            "Faible";

        passwordStrengthColor =
            AppColors.danger;
      } else if (strength <= 0.50) {
        passwordStrengthText =
            "Moyen";

        passwordStrengthColor =
            AppColors.warning;
      } else if (strength <= 0.75) {
        passwordStrengthText =
            "Bon";

        passwordStrengthColor =
            Colors.lightGreen;
      } else {
        passwordStrengthText =
            "Fort";

        passwordStrengthColor =
            AppColors.primary;
      }
    });
  }

  Future<void> changePassword() async {
    final currentPassword =
        currentPasswordController.text
            .trim();

    final password =
        passwordController.text.trim();

    final confirmPassword =
        confirmPasswordController.text
            .trim();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir votre mot de passe actuel.",
          ),
        ),
      );
      return;
    }

    if (password !=
        confirmPassword) {
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

    if (passwordStrength <
        0.50) {
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

    setState(() {
      loading = true;
    });

    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.put(
        '/home/profile/password',
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      if (!mounted) return;
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF15803D),
            content: Text("Mot de passe modifié avec succès."),
          ),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      final msg = e.response?.data?['message']?.toString() ??
          "Échec de la modification du mot de passe.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(msg),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text("Une erreur inattendue est survenue."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.lightBackground,

      appBar: AppBar(
        title: const Text(
          "Changer le mot de passe",
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            16,
          ),

          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                            currentPasswordController,

                        obscureText:
                            obscureCurrentPassword,

                        decoration:
                            InputDecoration(
                          labelText:
                              "Mot de passe actuel",

                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_outline,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(
                                () {
                                  obscureCurrentPassword =
                                      !obscureCurrentPassword;
                                },
                              );
                            },

                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                        ),

                        validator:
                            (
                              value,
                            ) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return "Champ obligatoire";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

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
                            Icons
                                .lock_reset,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(
                                () {
                                  obscurePassword =
                                      !obscurePassword;
                                },
                              );
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

                        validator:
                            (
                              value,
                            ) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return "Champ obligatoire";
                          }

                          if (value
                                  .length <
                              8) {
                            return "Minimum 8 caractères";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Align(
                        alignment:
                            Alignment
                                .centerLeft,

                        child: Text(
                          "Sécurité du mot de passe : $passwordStrengthText",

                          style:
                              TextStyle(
                            color:
                                passwordStrengthColor,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),

                        child:
                            LinearProgressIndicator(
                          value:
                              passwordStrength,
                          minHeight:
                              6,

                          backgroundColor:
                              AppColors
                                  .border,

                          valueColor:
                              AlwaysStoppedAnimation(
                            passwordStrengthColor,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

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
                            Icons
                                .verified_user_outlined,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed:
                                () {
                              setState(
                                () {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                },
                              );
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

                        validator:
                            (
                              value,
                            ) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return "Champ obligatoire";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration: BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: .08,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: const [
                    Text(
                      "Exigences du mot de passe",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    Text(
                      "• Minimum 8 caractères",
                    ),

                    Text(
                      "• Une lettre majuscule",
                    ),

                    Text(
                      "• Un chiffre",
                    ),

                    Text(
                      "• Un caractère spécial",
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 120,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomQuickAction(
        primaryText:
            "Modifier le mot de passe",

        loading: loading,

        onPrimaryPressed:
            changePassword,

        secondaryText:
            "Annuler",

        onSecondaryPressed:
            () {
          Navigator.pop(
            context,
          );
        },
      ),
    );
  }
}