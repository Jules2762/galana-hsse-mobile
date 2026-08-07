import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/attachment.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/attachment_bottom_sheet.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/comment_bottom_sheet.dart';

class InspectionAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;

  const InspectionAppBar({
    super.key,
    required this.title,
  });

  @override
  State<InspectionAppBar> createState() =>
      _InspectionAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}

class _InspectionAppBarState
    extends State<InspectionAppBar> {

  final List<Attachment> attachments = [];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),

      actions: [
        IconButton(
          onPressed: () async {
            await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape:
                  const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              builder: (_) =>
                  const CommentBottomSheet(),
            );
          },
          icon: const Icon(
            Icons.comment_outlined,
          ),
        ),

        IconButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape:
                  const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              builder: (_) {
                return AttachmentBottomSheet(
                  attachments: attachments,

                
                );
              },
            );

            setState(() {});
          },

          icon: Badge(
            isLabelVisible:
                attachments.isNotEmpty,
            label: Text(
              attachments.length.toString(),
            ),
            child: const Icon(
              Icons.attach_file,
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}