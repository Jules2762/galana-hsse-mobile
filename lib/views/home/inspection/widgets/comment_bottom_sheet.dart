import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/home/inspection/widgets/bottom_quick_action.dart';


class CommentBottomSheet extends StatefulWidget {
  final String? initialComment;

  const CommentBottomSheet({
    super.key,
    this.initialComment,
  });

  @override
  State<CommentBottomSheet> createState() =>
      _CommentBottomSheetState();
}

class _CommentBottomSheetState
    extends State<CommentBottomSheet> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.initialComment ?? "",
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void confirm() {
    Navigator.pop(
      context,
      controller.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(context).size.height *
                0.8,

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Commentaire",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Commentaires",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TextFormField(
                controller: controller,

                expands: true,
                minLines: null,
                maxLines: null,

                textAlignVertical:
                    TextAlignVertical.top,

                decoration:
                    const InputDecoration(
                  hintText:
                      "Saisissez votre commentaire...",
                ),
              ),
            ),

            const SizedBox(height: 16),

            BottomQuickAction(
              primaryText: "Confirmer",

              onPrimaryPressed: confirm,

              secondaryText: "Annuler",

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