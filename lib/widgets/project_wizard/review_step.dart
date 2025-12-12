import 'dart:io';
import 'package:flutter/material.dart';

class ReviewStep extends StatelessWidget {
  final Map<String, dynamic> formData;

  const ReviewStep({
    super.key,
    required this.formData,
  });

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Project',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all the information before proceeding to payment.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Basic Info
          _buildSection(
            'Basic Information',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formData['imagePreview'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(formData['imagePreview']),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (formData['imagePreview'] != null) const SizedBox(height: 12),
                _buildInfoRow('Title', formData['title'] ?? 'N/A'),
                _buildInfoRow('Short Description', formData['shortDesc'] ?? 'N/A'),
                _buildInfoRow('Description', formData['description'] ?? 'N/A'),
                _buildInfoRow('Category', formData['category'] ?? 'N/A'),
                _buildInfoRow('Status', formData['status'] ?? 'N/A'),
              ],
            ),
          ),

          // Financial Info
          _buildSection(
            'Financial Information',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total Price', formData['totalPrice'] ?? 'N/A'),
                _buildInfoRow('Expected ROI', '${formData['expectedROI'] ?? 'N/A'}%'),
                _buildInfoRow(
                  'Available Percentage',
                  formData['availablePercentage'] != null &&
                          formData['availablePercentage'].toString().isNotEmpty
                      ? '${formData['availablePercentage']}%'
                      : 'N/A',
                ),
              ],
            ),
          ),

          // Key Benefits
          if (formData['keyBenefits'] != null &&
              (formData['keyBenefits'] as List).isNotEmpty)
            _buildSection(
              'Key Benefits',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (formData['keyBenefits'] as List)
                    .map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(benefit)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Potential Risks
          if (formData['potentialRisks'] != null &&
              (formData['potentialRisks'] as List).isNotEmpty)
            _buildSection(
              'Potential Risks',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (formData['potentialRisks'] as List)
                    .map((risk) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(risk)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Timeline
          if (formData['timeline'] != null &&
              (formData['timeline'] as List).isNotEmpty)
            _buildSection(
              'Project Timeline',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (formData['timeline'] as List)
                    .asMap()
                    .entries
                    .map((entry) {
                  final phase = entry.value as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phase ${entry.key + 1}: ${phase['phase'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (phase['title'] != null)
                            Text(phase['title']),
                          if (phase['date'] != null)
                            Text(
                              'Date: ${phase['date']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          if (phase['status'] != null)
                            Chip(
                              label: Text(phase['status']),
                              labelStyle: const TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Documents
          if (formData['documents'] != null &&
              (formData['documents'] as List).isNotEmpty)
            _buildSection(
              'Documents',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (formData['documents'] as List)
                    .map((doc) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(doc['title'] ?? 'Document'),
                            subtitle: Text(doc['name'] ?? ''),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

