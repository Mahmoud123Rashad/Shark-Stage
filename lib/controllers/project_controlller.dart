import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ProjectController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final shortDescController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final percentageController = TextEditingController();

  File? projectImage;
  File? pdfFile;
  ValueNotifier<String> saleType = ValueNotifier<String>('Full');
  bool isLoading = false;

  final picker = ImagePicker();

  // ------------------------------------------------------------------
  // دوال اختيار الملفات (بدون تغيير)

  Future<void> pickImage(BuildContext context, Function() onUpdate) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      projectImage = File(picked.path);
      onUpdate();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image selected')));
    }
  }

  Future<void> pickPdf(BuildContext context, Function() onUpdate) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      pdfFile = File(result.files.single.path!);
      onUpdate();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PDF selected')));
    }
  }

  // ------------------------------------------------------------------
  // دوال بناء العناصر (بدون تغيير)

  Widget buildTextField(String label, TextEditingController c,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildImagePicker(BuildContext context, Function() onUpdate) => GestureDetector(
        onTap: () => pickImage(context, onUpdate),
        child: Container(
          height: 150,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: projectImage == null
              ? const Text("Tap to pick image")
              : Image.file(projectImage!, fit: BoxFit.cover),
        ),
      );

  Widget buildPdfUploader(BuildContext context, Function() onUpdate) => ElevatedButton(
        onPressed: () => pickPdf(context, onUpdate),
        child: Text(pdfFile == null
            ? "Upload Project PDF"
            : "PDF Selected: ${pdfFile!.path.split('/').last}"),
      );

  Widget buildSaleTypeDropdown(BuildContext context, Function(String) onUpdate) =>
      DropdownButtonFormField<String>(
        value: saleType.value,
        items: const [
          DropdownMenuItem(value: 'Full', child: Text("Sell Full Project")),
          DropdownMenuItem(value: 'Partial', child: Text("Sell Part of Project")),
        ],
        onChanged: (v) {
          if (v != null) {
            saleType.value = v;
            onUpdate(v);
          }
        },
        decoration: const InputDecoration(labelText: "Sale Type"),
      );

  // ------------------------------------------------------------------
  // دالة حفظ المشروع (Save Project) - تم إضافة الحقول الناقصة

  Future<void> saveProject(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    
    const String ownerId = "672a9f6d239dabc92b4d31f9"; 

    // المسار تم تعديله بناءً على الخطأ 404 السابق (تم افتراض أن المسار الصحيح هو بدون /api)
    // إذا كنت لا تزال تحصل على 404، قم بتغييره إلى "/api/projects/add"
    final url = Uri.parse("${ApiService.baseUrl}/projects/add"); 
    
    // تجهيز البيانات كـ JSON
    final Map<String, dynamic> projectData = {
      "title": titleController.text.trim(),
      "shortDesc": shortDescController.text.trim(),
      "description": detailsController.text.trim(),
      
      // التأكد من إرسال القيمة كـ رقم أو صفر إذا كانت فارغة
"totalPrice": priceController.text.trim(),
      "owner": ownerId,
      "status": "active",
      "expectedROI": 15,
      "availablePercentage": saleType.value == 'Partial'
          ? int.tryParse(percentageController.text.trim()) ?? 100 
          : 100,
      "image": null, 
      "category": {
        "en": "Technology",
        "ar": "تكنولوجيا",
      },
      // 💥 تمت إضافة الحقول الاختيارية لمنع رفض السيرفر لسبب فقدانها 💥
      "potentialRisks": [],
      "keyBenefits": [],
      "managementTeam": [],
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(projectData),
      ).timeout(const Duration(seconds: 60));

      final body = response.body;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Project added successfully")));
      } else {
        String serverMessage = "Unknown Error";
        try {
          final jsonResponse = jsonDecode(body);
          // السيرفر قد يرسل رسالة خطأ في 'message' أو 'error'
          serverMessage = jsonResponse['message'] ?? jsonResponse['error'] ?? "Error processing request";
        } catch (_) {
          serverMessage = body;
        }

        final errorMessage = "Failed to add project (${response.statusCode}): $serverMessage";
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error: Connection timeout. Check server status.")));
    } catch (e) {
      String errorMsg = e.toString().contains('SocketException')
          ? "Network Error: Cannot connect to server or URL is wrong."
          : e.toString();
      
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $errorMsg")));
    }
  }
}