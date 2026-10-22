import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_login_email');
      if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
        setState(() {
          emailController.text = savedEmail;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final nav = Navigator.of(context);
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Veuillez renseigner votre email et mot de passe.";
      });
      return;
    }

    try {
      final result = await ApiClient.login(email, password);
      if (!mounted) return;

      if (result.success) {
        try {
          final prefs = await SharedPreferences.getInstance();
          if (rememberMe) {
            await prefs.setString('saved_login_email', email);
          } else {
            await prefs.remove('saved_login_email');
          }
        } catch (_) {}
        nav.pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() {
          errorMessage = result.errorMessage ?? "Identifiant ou mot de passe incorrect.";
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion.";
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ============================================
                  // EN-TÊTE DE MARQUE & LOGO GALANA
                  // ============================================
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Image.asset(
                        "assets/logo-galana.webp",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Badge officiel & Accès rapide urgences
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                "PORTAIL SÉCURISÉ HSSE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyContacts),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emergency_rounded, size: 14, color: Color(0xFFDC2626)),
                                SizedBox(width: 4),
                                Text(
                                  "URGENCES 24/7",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "GALANA MADAGASCAR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Système Intégré d'Inspections & Audits Terrain",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ============================================
                  // CARTE FORMULAIRE DE CONNEXION
                  // ============================================
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Connexion",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Entrez vos identifiants professionnels",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Adresse Email
                        const Text(
                          "Identifiant professionnel",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "prenom.nom@galana.mg",
                            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Mot de passe
                        const Text(
                          "Mot de passe",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18,
                                color: const Color(0xFF94A3B8),
                              ),
                              onPressed: () {
                                setState(() => obscurePassword = !obscurePassword);
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Se souvenir & mot de passe oublié
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) => setState(() => rememberMe = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Mémoriser",
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.forgotPassword);
                              },
                              child: const Text(
                                "Mot de passe oublié ?",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bouton principal Se Connecter
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Se connecter",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 16),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================================
                  // BANNIÈRE CONTACTS D'URGENCE (HSSE 24/7)
                  // ============================================
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.phone_in_talk_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Contacts d'Urgence",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF991B1B),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "24/7",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    "Pompiers (118), SAMU (124), Police, Dépôts & Stations",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ============================================
                  // PIED DE PAGE & CONFORMITÉ ISO
                  // ============================================
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          "Galana Distribution Madagascar",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Système de Management HSSE conforme ISO 45001 & 14001",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
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
