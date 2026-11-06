import 'package:flutter/material.dart';

class BottomQuickAction extends StatelessWidget {
  final String primaryText;
  final VoidCallback onPrimaryPressed;

  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;

  final bool loading;
  final bool enabled;

  const BottomQuickAction({
    super.key,
    required this.primaryText,
    required this.onPrimaryPressed,
    this.secondaryText,
    this.onSecondaryPressed,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),

      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),

      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton(
                onPressed: enabled && !loading
                    ? onPrimaryPressed
                    : null,

                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(primaryText),
              ),
            ),

            if (secondaryText != null) ...[
              const SizedBox(height: 10),

              TextButton(
                onPressed: onSecondaryPressed,
                child: Text(
                  secondaryText!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}