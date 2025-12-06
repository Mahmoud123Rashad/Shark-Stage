import 'package:flutter/material.dart';
import '../controllers/project_controller.dart';
import '../payment/project_payment_form.dart';

class ProjectPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final ProjectController controller;

  const ProjectPaymentScreen({
    super.key,
    required this.projectData,
    required this.controller,
  });

  @override
  State<ProjectPaymentScreen> createState() => _ProjectPaymentScreenState();
}

class _ProjectPaymentScreenState extends State<ProjectPaymentScreen> {
  bool _isProcessing = false;

  void _handlePaymentSubmit(Map<String, dynamic> paymentData) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing (replace with actual payment logic)
      await Future.delayed(const Duration(seconds: 2));

      // After successful payment, add the project
      final success = await widget.controller.addProject(context);

      if (success && mounted) {
        // Navigate back to previous screen or dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project created successfully after payment!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Payment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[50],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ProjectPaymentForm(
            projectData: widget.projectData,
            onSubmit: _handlePaymentSubmit,
            onBack: _handleBack,
            loading: _isProcessing,
          ),
        ),
      ),
    );
  }
}
