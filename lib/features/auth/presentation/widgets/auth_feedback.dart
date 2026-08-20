import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/grimoire_colors.dart';

enum AuthSnackType { error, success, info }

/// Feedback padronizado das telas de auth: flutuante, com ícone e haptic
/// coerente com o tipo — erro "pesa" na mão, sucesso é leve.
void showAuthSnack(
  BuildContext context,
  String message, {
  AuthSnackType type = AuthSnackType.info,
}) {
  final gc = context.gc;
  final (color, icon) = switch (type) {
    AuthSnackType.error => (gc.alert, Icons.error_outline_rounded),
    AuthSnackType.success => (gc.success, Icons.check_circle_outline_rounded),
    AuthSnackType.info => (gc.info, Icons.info_outline_rounded),
  };

  switch (type) {
    case AuthSnackType.error:
      HapticFeedback.mediumImpact();
    case AuthSnackType.success:
      HapticFeedback.lightImpact();
    case AuthSnackType.info:
      break;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
