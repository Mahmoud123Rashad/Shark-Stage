// TODO Implement this library.
// lib/utils/status_utils.dart

import 'package:flutter/material.dart';

class StatusConfig {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final String label;

  const StatusConfig({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.label,
  });
}

// تحويل حالة العرض إلى ألوان Tailwind CSS مكافئة
StatusConfig getStatusConfig(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      // yellow-100 / yellow-800
      return StatusConfig(
        bgColor: const Color(0xFFFFFBEB),
        textColor: const Color(0xFF92400E),
        borderColor: const Color(0xFFFDE68A),
        label: "Pending",
      );
    case 'accepted':
      // green-100 / green-800
      return StatusConfig(
        bgColor: const Color(0xFFD1FAE5),
        textColor: const Color(0xFF065F46),
        borderColor: const Color(0xFFA7F3D0),
        label: "Accepted",
      );
    case 'rejected':
      // red-100 / red-800
      return StatusConfig(
        bgColor: const Color(0xFFFFEEEE),
        textColor: const Color(0xFF991B1B),
        borderColor: const Color(0xFFFEE2E2),
        label: "Rejected",
      );
    case 'cancelled':
      // gray-100 / gray-800
      return StatusConfig(
        bgColor: const Color(0xFFF3F4F6),
        textColor: const Color(0xFF4B5563),
        borderColor: const Color(0xFFE5E7EB),
        label: "Cancelled",
      );
    default:
      return getStatusConfig('pending');
  }
}