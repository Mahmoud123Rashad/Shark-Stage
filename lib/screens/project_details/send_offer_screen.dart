import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class SendOfferScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const SendOfferScreen({super.key, required this.project});

  @override
  State<SendOfferScreen> createState() => _SendOfferScreenState();
}

class _SendOfferScreenState extends State<SendOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _percentageController = TextEditingController();
  final _proposalController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _percentageController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  Future<void> _sendOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        '/offers/send',
        auth: true,
        body: {
          'project': widget.project['_id'],
          'offeredTo': widget.project['owner']['_id'],
          'amount': double.parse(_amountController.text),
          'percentage': double.parse(_percentageController.text),
          'proposalLetter': _proposalController.text,
        },
      );

      if (!mounted) return;

      if (response['status'] == 201 || response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to project details
      } else {
        throw Exception(response['message'] ?? 'Failed to send offer');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availablePercentage = widget.project['availablePercentage'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Investment Offer'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project['title'] ?? 'Project',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available: $availablePercentage%',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount Offered *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Percentage Field
              TextFormField(
                controller: _percentageController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Percentage to be Invested *',
                  suffixText: '%',
                  border: const OutlineInputBorder(),
                  hintText: '0-$availablePercentage',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Percentage is required';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null || percentage <= 0) {
                    return 'Must be greater than 0';
                  }
                  if (percentage > availablePercentage) {
                    return 'Cannot exceed $availablePercentage%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Proposal Letter Field
              TextFormField(
                controller: _proposalController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Proposal Letter *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your investment proposal...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proposal is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Send Offer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
