import 'package:flutter/material.dart';
import '../controllers/project_controlller.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  // يجب تعريف الـ controller كـ final
  final _controller = ProjectController();

  // دالة لتحديث حالة الـ Form (تستخدم لإعادة بناء الـ Widget بعد أي تغيير في الـ Controller)
  void _updateFormState([String? newValue]) {
    setState(() {
      // لا تحتاج إلى فعل أي شيء داخل setState()، فقط استدعاؤها هو ما يهم.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Add New Project",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          // تمرير دالة تحديث الحالة
          _controller.buildImagePicker(context, _updateFormState),
          
          _controller.buildTextField("Project Title", _controller.titleController),
          _controller.buildTextField("Short Description", _controller.shortDescController),
          
          _controller.buildTextField("Details (Full Description)", _controller.detailsController,
              maxLines: 4),
          _controller.buildTextField("Price", _controller.priceController,
              type: TextInputType.number),

          const SizedBox(height: 12),

          // تحديث الـ Dropdown مع دالة التحديث
          _controller.buildSaleTypeDropdown(context, _updateFormState),

          const SizedBox(height: 12),

          // شرط ظهور حقل النسبة المئوية
          if (_controller.saleType.value == 'Partial') 
            _controller.buildTextField("Available Percentage (%)", _controller.percentageController,
                type: TextInputType.number),
          
          // تمرير دالة تحديث الحالة
          _controller.buildPdfUploader(context, _updateFormState),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _controller.saveProject(context),
            child: const Text("Save Project"),
          ),
        ],
      ),
    );
  }
}