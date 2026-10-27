import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gestion_hsse/cores/models/attachment.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/attachment_action.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/attachment_card.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/bottom_quick_action.dart';

class AttachmentBottomSheet extends StatefulWidget {
  final List<Attachment> attachments;

  const AttachmentBottomSheet({
    super.key,
    required this.attachments,
  });

  @override
  State<AttachmentBottomSheet> createState() =>
      _AttachmentBottomSheetState();
}

class _AttachmentBottomSheetState
    extends State<AttachmentBottomSheet> {
  final ImagePicker _picker = ImagePicker();

  late List<Attachment> attachments;

  @override
  void initState() {
    super.initState();

    attachments = List.from(
      widget.attachments,
    );
  }

  Future<void> _takePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return;

    setState(() {
      attachments.add(
        Attachment(
          id: DateTime.now()
              .millisecondsSinceEpoch,
          fileName: file.name,
          filePath: file.path,
          fileType: "image",
        ),
      );
    });
  }

  Future<void> _pickGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    setState(() {
      attachments.add(
        Attachment(
          id: DateTime.now()
              .millisecondsSinceEpoch,
          fileName: file.name,
          filePath: file.path,
          fileType: "image",
        ),
      );
    });
  }

  Future<void> _pickDocument() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Sélection de document à implémenter avec file_picker",
        ),
      ),
    );
  }

  void _deleteAttachment(
    Attachment attachment,
  ) {
    setState(() {
      attachments.remove(attachment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height *
                0.85,

        child: Column(
          children: [
            // HEADER

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    "Pièces jointes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  Badge(
                    label: Text(
                      attachments.length
                          .toString(),
                    ),
                    child: const Icon(
                      Icons.attach_file,
                    ),
                  ),
                ],
              ),
            ),

            // ACTIONS

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AttachmentAction(
                      icon: Icons
                          .photo_camera_outlined,
                      title: "Prendre photo",
                      selected: true,
                      onTap: _takePhoto,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AttachmentAction(
                      icon: Icons
                          .photo_library_outlined,
                      title: "Galerie",
                      onTap: _pickGallery,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AttachmentAction(
                      icon:
                          Icons.insert_drive_file_outlined,
                      title: "Document",
                      onTap: _pickDocument,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: attachments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 60,
                            color:
                                Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Aucune pièce jointe",
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: GridView.builder(
                        itemCount:
                            attachments.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing:
                              12,
                          mainAxisSpacing:
                              12,
                          childAspectRatio:
                              .85,
                        ),

                        itemBuilder:
                            (context, index) {
                          final attachment =
                              attachments[
                                  index];

                          return AttachmentCard(
                            attachment:
                                attachment,

                            onDelete: () {
                              _deleteAttachment(
                                attachment,
                              );
                            },

                            onTap: () {
                              debugPrint(
                                attachment
                                    .fileName,
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),

            BottomQuickAction(
              primaryText: "Confirmer",

              onPrimaryPressed: () {
                Navigator.pop(
                  context,
                  attachments,
                );
              },

              secondaryText: "Fermer",

              onSecondaryPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}