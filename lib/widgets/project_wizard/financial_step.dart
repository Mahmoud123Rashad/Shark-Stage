import 'package:flutter/material.dart';

class FinancialStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) updateFormData;

  const FinancialStep({
    super.key,
    required this.formData,
    required this.updateFormData,
  });

  @override
  State<FinancialStep> createState() => _FinancialStepState();
}

class _FinancialStepState extends State<FinancialStep> {
  final _totalPriceController = TextEditingController();
  final _expectedROIController = TextEditingController();
  final _availablePercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalPriceController.text = widget.formData['totalPrice']?.toString() ?? '';
    _expectedROIController.text = widget.formData['expectedROI']?.toString() ?? '';
    _availablePercentageController.text = widget.formData['availablePercentage']?.toString() ?? '';
    _totalPriceController.addListener(_updateFormData);
    _expectedROIController.addListener(_updateFormData);
    _availablePercentageController.addListener(_updateFormData);
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _expectedROIController.dispose();
    _availablePercentageController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    widget.updateFormData({
      'totalPrice': _totalPriceController.text,
      'expectedROI': _expectedROIController.text,
      'availablePercentage': _availablePercentageController.text,
    });
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.surface.withOpacity(0.6),
                      colorScheme.surface.withOpacity(0.4),
                    ]
                  : [
                      Colors.white,
                      colorScheme.primary.withOpacity(0.03),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              labelText: label,
              hintText: hintText,
              labelStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 16,
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Financial Information', Icons.attach_money, theme),
          _buildTextField(
            'Total Price *',
            _totalPriceController,
            type: TextInputType.number,
            icon: Icons.attach_money,
            hintText: 'Enter total project price',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter total price';
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed < 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          _buildTextField(
            'Expected ROI (%) *',
            _expectedROIController,
            type: TextInputType.number,
            icon: Icons.trending_up,
            hintText: 'Enter expected ROI percentage',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter expected ROI';
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed < 0 || parsed > 100) {
                return 'ROI must be between 0 and 100';
              }
              return null;
            },
          ),
          _buildTextField(
            'Available Percentage (%)',
            _availablePercentageController,
            type: TextInputType.number,
            icon: Icons.percent,
            hintText: 'Optional - Percentage available for investment',
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0 || parsed > 100) {
                  return 'Percentage must be between 0 and 100';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

