import 'package:flutter/material.dart';

class AppTheme {
  static const Color goldLight = Color(0xFFFFE1A1);
  static const Color gold = Color(0xFFD6A650);
  static const Color goldDark = Color(0xFF7B541D);
  static const Color cream = Color(0xFFF1E4C8);
  static const Color creamDark = Color(0xFFC9AD78);
  static const Color brownDark = Color(0xFF1B1009);
  static const Color brownLight = Color(0xFF5A3B20);
  static const Color ink = Color(0xFF100B08);
  static const Color blackTransparent = Color(0xCC000000);
  static const Color cardBackground = Color(0xB21B120B);
  static const Color cardBackgroundLight = Color(0x663D2816);
  static const Color cardBorder = Color(0x80D6A650);
  static const Color blueChip = Color(0xFF79AEFF);
  static const Color redChip = Color(0xFFFF756C);
  static const Color greenChip = Color(0xFF9AD56F);
  static const Color orangeChip = Color(0xFFFFB04D);
  static const Color greyChip = Color(0xFFC2B49C);

  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 18;
  static const double borderRadiusLarge = 24;
  static const double borderRadiusButton = 999;

  static const EdgeInsets spacingSmall = EdgeInsets.all(8);
  static const EdgeInsets spacingMedium = EdgeInsets.all(16);
  static const EdgeInsets spacingLarge = EdgeInsets.all(24);

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x99000000),
    blurRadius: 22,
    offset: Offset(0, 12),
  );

  static const BoxShadow glowShadow = BoxShadow(
    color: Color(0x33D6A650),
    blurRadius: 24,
    offset: Offset(0, 0),
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: goldLight,
    shadows: [
      Shadow(color: Color(0xCCD6A650), blurRadius: 14),
      Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 3)),
    ],
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontStyle: FontStyle.italic,
    color: Color(0xD9DCC6A3),
    shadows: [
      Shadow(color: Color(0x99000000), blurRadius: 8),
    ],
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: goldLight,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: cream,
    shadows: [
      Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: cream,
    height: 1.55,
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 16,
    color: Color(0x99F1E4C8),
  );

  static const TextStyle navTitleStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: goldLight,
    shadows: [
      Shadow(color: Color(0xCCD6A650), blurRadius: 12),
      Shadow(color: Color(0xCC000000), blurRadius: 6, offset: Offset(0, 3)),
    ],
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(260, 62),
    padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 18),
    textStyle: buttonStyle,
    backgroundColor: const Color(0x99402A17),
    foregroundColor: goldLight,
    side: const BorderSide(color: cardBorder, width: 1.4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
    shadowColor: gold.withOpacity(0.3),
    elevation: 10,
  );

  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    backgroundColor: const Color(0xCC7E1D14),
    foregroundColor: cream,
    side: const BorderSide(color: Color(0xFFFF6A46), width: 1.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
    elevation: 8,
  );

  static ButtonStyle hintButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    backgroundColor: const Color(0xD08C4C00),
    foregroundColor: goldLight,
    side: const BorderSide(color: Color(0xFFFFA726), width: 1.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
    elevation: 8,
  );

  static ButtonStyle searchButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(104, 58),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    backgroundColor: const Color(0xD8D9C7FF),
    foregroundColor: const Color(0xFF4A3478),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
    elevation: 7,
  );

  static InputDecoration textFieldDecoration(String hintText,
      {Widget? prefixIcon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
      borderSide: const BorderSide(color: cardBorder, width: 1.1),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusButton),
        borderSide: const BorderSide(color: goldLight, width: 1.4),
      ),
      fillColor: const Color(0x9914110E),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    border: Border.all(color: cardBorder, width: 1.05),
    boxShadow: [cardShadow, glowShadow],
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xB8422A17),
        Color(0xB016100C),
      ],
    ),
  );

  static BoxDecoration filterDecoration = BoxDecoration(
    color: const Color(0x9914110E),
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    border: Border.all(color: cardBorder, width: 1.1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 14,
        offset: Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration chipDecoration(Color color) => BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(borderRadiusButton),
        border: Border.all(color: color.withOpacity(0.9), width: 1),
      );

  static TextStyle chipTextStyle(Color color) => TextStyle(
        fontSize: 14,
        color: color,
        height: 1,
      );

  static Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return greenChip;
      case '中等':
        return orangeChip;
      case '困难':
        return redChip;
      case '入门':
        return greyChip;
      default:
        return greyChip;
    }
  }

  static Color getTagColor(String tag) {
    if (tag.contains('红汤') || tag.contains('微恐') || tag.contains('生活化')) {
      return redChip;
    } else if (tag.contains('清汤') || tag.contains('逻辑') || tag.contains('反转')) {
      return blueChip;
    } else if (tag.contains('简单')) {
      return greenChip;
    } else if (tag.contains('中等')) {
      return orangeChip;
    } else if (tag.contains('困难')) {
      return redChip;
    } else if (tag.contains('入门')) {
      return greyChip;
    }
    return blueChip;
  }
}
