import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectPaymentForm extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final File? projectImage;
  final Function(Map<String, dynamic> paymentData) onSubmit;
  final VoidCallback onBack;
  final bool loading;
  final Map<String, String>? errors;

  const ProjectPaymentForm({
    super.key,
    required this.projectData,
    this.projectImage,
    required this.onSubmit,
    required this.onBack,
    this.loading = false,
    this.errors,
  });

  @override
  State<ProjectPaymentForm> createState() => _ProjectPaymentFormState();
}

class _ProjectPaymentFormState extends State<ProjectPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  String _cardBrand = 'Card';

  static const double listingFee = 50.0; // Fixed listing fee

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) formatted.write(' ');
      formatted.write(cleaned[i]);
    }
    _cardNumberController.value = TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _detectCardBrand(cleaned);
  }

  void _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      setState(() => _cardBrand = 'Visa');
    } else if (RegExp(r'^5[1-5]').hasMatch(cardNumber)) {
      setState(() => _cardBrand = 'Mastercard');
    } else if (RegExp(r'^3[47]').hasMatch(cardNumber)) {
      setState(() => _cardBrand = 'American Express');
    } else if (RegExp(r'^6(?:011|5)').hasMatch(cardNumber)) {
      setState(() => _cardBrand = 'Discover');
    } else {
      setState(() => _cardBrand = 'Card');
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final cardNumber = _cardNumberController.text.replaceAll(RegExp(r'[^\d]'), '');
    final expiryMonth = int.tryParse(_expiryMonthController.text) ?? 0;
    final expiryYear = 2000 + (int.tryParse(_expiryYearController.text) ?? 0);

    widget.onSubmit({
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': _cvvController.text,
      'cardholderName': _cardholderNameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              TextButton.icon(
                onPressed: widget.loading ? null : widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Project Form'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Text(
                'Complete Payment',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your payment details to publish your project',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Project Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                      theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Project Title:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Expanded(
                          child: Text(
                            widget.projectData['title'] ?? 'Untitled Project',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Listing Fee:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '\$${listingFee.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mock Payment Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.yellow.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mock Payment (Demo Only) - This is a demonstration. No actual payment will be processed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                ],
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                  suffixIcon: _cardNumberController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _cardBrand,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      : null,
                ),
                onChanged: _formatCardNumber,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Card number is required';
                  }
                  final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (cleaned.length < 13 || cleaned.length > 19) {
                    return 'Card number must be between 13 and 19 digits';
                  }
                  return widget.errors?['cardNumber'];
                },
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _cardholderNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cardholder name is required';
                  }
                  return widget.errors?['cardholderName'];
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  // Expiry Month
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Month',
                        hintText: 'MM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final month = int.tryParse(value);
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid';
                        }
                        return widget.errors?['expiryMonth'];
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expiry Year
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Year',
                        hintText: 'YY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final year = int.tryParse(value);
                        final currentYear = DateTime.now().year % 100;
                        if (year == null || year < currentYear) {
                          return 'Invalid';
                        }
                        return widget.errors?['expiryYear'];
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid';
                        }
                        return widget.errors?['cvv'];
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a mock payment form for demonstration purposes only. No actual payment will be processed.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.loading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.lock, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Pay & Create Project',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

