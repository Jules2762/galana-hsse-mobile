import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/attachment.dart';

class AttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AttachmentCard({
    super.key,
    required this.attachment,
    this.onDelete,
    this.onTap,
  });

  Widget _preview(bool isDark) {
    final placeholderBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    switch (attachment.fileType.toLowerCase()) {
      case "image":
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Image.file(
            File(attachment.filePath),
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );

      case "video":
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: placeholderBg,
            ),

            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.red,
              ),
            ),
          ],
        );

      case "pdf":
      case "document":
        return Container(
          color: placeholderBg,
          child: const Center(
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 50,
            ),
          ),
        );

      default:
        return Container(
          color: placeholderBg,
          child: const Center(
            child: Icon(
              Icons.insert_drive_file_outlined,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _preview(isDark),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onDelete,
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                attachment.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}