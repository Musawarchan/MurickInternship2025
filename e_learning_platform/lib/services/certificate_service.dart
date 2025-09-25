import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CertificateService {
  static Future<Uint8List> generateCertificate({
    required String userName,
    required String courseTitle,
    required DateTime completionDate,
  }) async {
    // Simulate PDF generation delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // In a real app, you would use a PDF package like pdf/widgets to generate a proper PDF file.
    // For now, we'll create a mock certificate as a simple text representation
    final certificateContent = '''
CERTIFICATE OF COMPLETION 

This is to certify that

$userName

has successfully completed the course

"$courseTitle"

on ${completionDate.day}/${completionDate.month}/${completionDate.year}

Certificate ID: CERT-${DateTime.now().millisecondsSinceEpoch}
Generated on: ${DateTime.now().toIso8601String()}

---
E-Learning Platform
    '''
        .trim();

    return Uint8List.fromList(certificateContent.codeUnits);
  }

  static Future<Uint8List> generateCertificateImage({
    required String userName,
    required String courseTitle,
    required DateTime completionDate,
  }) async {
    // This would generate an actual image representation of the certificate
    // For now, return a placeholder
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    final certificateData = '''
CERTIFICATE OF COMPLETION

$userName
$courseTitle
${completionDate.day}/${completionDate.month}/${completionDate.year}
    '''
        .trim();

    return Uint8List.fromList(certificateData.codeUnits);
  }

  static String getCertificateId(String userName, String courseTitle) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = (userName + courseTitle + timestamp.toString()).hashCode.abs();
    return 'CERT-${hash.toString().substring(0, 8).toUpperCase()}';
  }
}
