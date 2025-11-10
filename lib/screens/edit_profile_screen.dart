import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
 final String firstName;
 final String lastName;
 final String email;
 final String phone;
 final String? imageUrl;

 const EditProfileScreen({
  super.key,
  required this.firstName,
  required this.lastName,
  required this.email,
  required this.phone,
  this.imageUrl,
 });

 @override
 State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
 late TextEditingController _firstNameController;
 late TextEditingController _lastNameController;
 late TextEditingController _emailController;
 late TextEditingController _phoneController;
 
 File? _selectedImage;
 bool _isLoading = false;

 // ⚠️ يجب استبدال هذا برابط API Service مركزي في مشروعك
 final String baseUrl ="https://sharkserver-production.up.railway.app";

 @override
 void initState() {
  super.initState();
  _firstNameController = TextEditingController(text: widget.firstName);
  _lastNameController = TextEditingController(text: widget.lastName);
  // الإيميل للقراءة فقط
  _emailController = TextEditingController(text: widget.email); 
  _phoneController = TextEditingController(text: widget.phone);
 }
  
 @override
 void dispose() {
  // التخلص من المتحكمات عند إغلاق الشاشة
  _firstNameController.dispose();
  _lastNameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  super.dispose();
 }

 Future<void> _pickImage() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked != null) {
   setState(() => _selectedImage = File(picked.path));
  }
 }

 Future<void> _saveProfile() async {
  // تجنب إرسال طلب آخر أثناء التحميل
  if (_isLoading) return; 

  setState(() => _isLoading = true);
  try {
   final prefs = await SharedPreferences.getInstance();
   final token = prefs.getString('token');

   if (token == null) {
    _showSnack("Token not found. Please log in again.");
    return; 
   }

   final uri = Uri.parse("$baseUrl/auth/update");
   var request = http.MultipartRequest('PUT', uri);

   // 1. إضافة حقول النص
   request.fields['firstName'] = _firstNameController.text.trim();
   request.fields['lastName'] = _lastNameController.text.trim();
   request.fields['phone'] = _phoneController.text.trim();

   // 2. إضافة ملف الصورة (إن وجد)
   if (_selectedImage != null) {
    request.files.add(await http.MultipartFile.fromPath(
     'image', 
     _selectedImage!.path,
    ));
   }

   // 3. إضافة الهيدر
   request.headers['Authorization'] = 'Bearer $token';

   final streamedResponse = await request.send();
   final response = await http.Response.fromStream(streamedResponse);

   if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final updatedUser = data['user'] ?? {};

    // تحديث البيانات المخزنة محلياً
    await prefs.setString('firstName', updatedUser['firstName'] ?? '');
    await prefs.setString('lastName', updatedUser['lastName'] ?? '');
    await prefs.setString('phone', updatedUser['phone'] ?? '');

    _showSnack("✅ Profile updated successfully");

    // العودة من الشاشة (true يشير إلى نجاح عملية التحديث)
    Navigator.pop(context, true); 

   } else {
    final data = jsonDecode(response.body);
    _showSnack(data['message'] ?? "❌ Failed to update profile");
   }
  } catch (e) {
   // ⚠️ يجب طباعة الخطأ إلى وحدة التحكم لتصحيحه: debugPrint('Update error: $e');
   _showSnack("Error occurred while updating profile");
  } finally {
   // تحديث حالة التحميل فقط إذا كانت الشاشة لا تزال موجودة
   if (mounted) {
    setState(() => _isLoading = false);
   }
  }
 }

 void _showSnack(String msg) {
  if (!mounted) return;
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(
    content: Text(msg),
    backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
   ),
  );
 }

 // دالة مساعدة لتحديد مصدر الصورة بناءً على الحالة
 ImageProvider _resolveImageProvider() {
  if (_selectedImage != null) {
   return FileImage(_selectedImage!);
  } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
   return NetworkImage(widget.imageUrl!);
  } else {
   // ⚠️ تأكد أن مسار الصورة الافتراضية صحيح في مشروعك
   return const AssetImage('images/profile.jpeg'); 
  }
 }

 // ويدجيت لبناء حقل الإدخال المتكيف مع الثيم
 Widget _buildTextField(String label, TextEditingController controller, IconData icon,
   {bool readOnly = false}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return Container(
   margin: const EdgeInsets.symmetric(vertical: 10),
   child: TextField(
    controller: controller,
    readOnly: readOnly,
    // النص لونه يتكيف مع الخلفية (onBackground)
    style: TextStyle(color: colorScheme.onBackground), 
    decoration: InputDecoration(
     // لون الأيقونة يتكيف
     prefixIcon: Icon(icon, color: colorScheme.onBackground.withOpacity(0.7)),
     labelText: label,
     labelStyle: TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
     filled: true,
     // لون التعبئة يتكيف مع الوضع الفاتح والداكن
     fillColor: isDark ? Colors.white10 : Colors.grey.shade200, 
     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
     enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.onBackground.withOpacity(0.06)),
     ),
     focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
     ),
    ),
   ),
  );
 }

 @override
 Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return Scaffold(
   // شريط التطبيق شفاف ويتكيف لونه تلقائياً
   extendBodyBehindAppBar: true,
   appBar: AppBar(
    title: Text("Edit Profile", style: theme.textTheme.titleLarge),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    // لون الأيقونات (مثل زر الرجوع) يتكيف بناءً على سطوع الخلفية
    iconTheme: IconThemeData(
     color: isDark ? Colors.white : Colors.black,
    ),
   ),
   body: Container(
    decoration: BoxDecoration(
     // تكييف الخلفية المتدرجة للوضع الداكن والفاتح
     gradient: LinearGradient(
      colors: isDark
        ? [const Color(0xFF0D1117), const Color(0xFF161B22)] // ألوان داكنة
        : [Colors.white, Colors.grey.shade50], // ألوان فاتحة
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
     ),
    ),
    child: SafeArea(
     child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       children: [
        const SizedBox(height: 16),
        Stack(
         alignment: Alignment.bottomRight,
         children: [
          CircleAvatar(
           radius: 65,
           // استخدام الدالة المساعدة لمعالجة مصدر الصورة
           backgroundImage: _resolveImageProvider(), 
           // لون احتياطي للدائرة
           backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade300,
          ),
          Positioned(
           bottom: 0,
           right: 4,
           child: InkWell(
            onTap: _pickImage,
            child: Container(
             padding: const EdgeInsets.all(6),
             decoration: BoxDecoration(
              shape: BoxShape.circle,
              // لون أيقونة الكاميرا يتكيف
              color: colorScheme.primary, 
             ),
             child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
           ),
          ),
         ],
        ),
        const SizedBox(height: 30),
        _buildTextField("First Name", _firstNameController, Icons.person),
        _buildTextField("Last Name", _lastNameController, Icons.person_outline),
        // يتم جعل الإيميل للقراءة فقط
        _buildTextField("Email", _emailController, Icons.email, readOnly: true),
        _buildTextField("Phone", _phoneController, Icons.phone),
        const SizedBox(height: 35),
        _isLoading
          ? const CircularProgressIndicator()
          : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
             icon: const Icon(Icons.save, color: Colors.white),
             label: const Text("Save Changes"),
             style: ElevatedButton.styleFrom(
              // لون الزر الرئيسي يتكيف مع الثيم
              backgroundColor: colorScheme.primary, 
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
              ),
             ),
             onPressed: _saveProfile,
            ),
           ),
       ],
      ),
     ),
    ),
   ),
  );
 }
}