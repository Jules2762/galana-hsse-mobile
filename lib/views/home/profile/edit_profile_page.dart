import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/extensions/context_extensions.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController functionController;
  late final TextEditingController departmentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ApiClient.currentUser;
    final fullName = user?['name']?.toString() ??
        ("${user?['first_name'] ?? 'Jules'} ${user?['last_name'] ?? 'ARIMANANA'}").trim();
    nameController = TextEditingController(text: fullName);
    emailController = TextEditingController(text: user?['email']?.toString() ?? "julesari_ext@galana.mg");
    final rawPhone = user?['phone_number']?.toString() ?? (user?['phone']?.toString() ?? "");
    phoneController = TextEditingController(text: rawPhone);
    functionController = TextEditingController(text: user?['job_title']?.toString() ?? "Superviseur Terrain HSSE");
    departmentController = TextEditingController(text: user?['department']?.toString() ?? "Opérations & Sûreté");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    functionController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => isLoading = true);

    final user = ApiClient.currentUser;
    final userId = user?['id'];
    final phone = phoneController.text.trim();
    final nameParts = nameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      if (userId != null) {
        await ApiClient.dio.put('/profile/$userId', data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
        });
      }
      await ApiClient.updateCurrentUser({
        'name': nameController.text.trim(),
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'phone': phone,
      });
      await ApiClient.fetchCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileSaved),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      await ApiClient.updateCurrentUser({
        'name': nameController.text.trim(),
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'phone': phone,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileSaved),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          context.l10n.editProfile,
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // PHOTO

              Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      "assets/images/profile.jpg",
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 34,
                      height: 34,

                      decoration: BoxDecoration(
                        color:
                            AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          width: 3,
                        ),
                      ),

                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // TODO:
                          // choisir photo
                        },
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(
                  20,
                ),

                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),

                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.fullName,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.emptyCredentials;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.l10n.officialEmail,
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: context.l10n.phone,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: functionController,
                      decoration: InputDecoration(
                        labelText: context.l10n.jobFunction,
                        prefixIcon: const Icon(Icons.badge),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: departmentController,
                      decoration: InputDecoration(
                        labelText: context.l10n.department,
                        prefixIcon: const Icon(Icons.business_center_outlined),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          context.l10n.save,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    context.l10n.cancel,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}