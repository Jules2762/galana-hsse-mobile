import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
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

  @override
  void initState() {
    super.initState();
    final user = ApiClient.currentUser;
    final fullName = user?['name']?.toString() ??
        ("${user?['first_name'] ?? 'Jules'} ${user?['last_name'] ?? 'ARIMANANA'}").trim();
    nameController = TextEditingController(text: fullName);
    emailController = TextEditingController(text: user?['email']?.toString() ?? "julesari_ext@galana.mg");
    phoneController = TextEditingController(text: user?['phone']?.toString() ?? "+261 34 12 345 67");
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

  void saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Profil mis à jour avec succès",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          "Modifier le profil",
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
                          color: Colors.white,
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
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),

                child: Column(
                  children: [
                    TextFormField(
                      controller:
                          nameController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Nom complet",
                        prefixIcon:
                            Icon(Icons.person),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
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
                          emailController,

                      keyboardType:
                          TextInputType
                              .emailAddress,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Adresse e-mail",
                        prefixIcon:
                            Icon(Icons.email),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                          phoneController,

                      keyboardType:
                          TextInputType.phone,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Téléphone",
                        prefixIcon:
                            Icon(Icons.phone),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                          functionController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Fonction",
                        prefixIcon:
                            Icon(Icons.badge),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                          departmentController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Département",
                        prefixIcon:
                            Icon(
                          Icons
                              .business_center_outlined,
                        ),
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
                  onPressed: saveProfile,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                  ),

                  child: const Text(
                    "Enregistrer",
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
                  child: const Text(
                    "Annuler",
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