import 'package:flutter/material.dart';

class DetailsStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) updateFormData;

  const DetailsStep({
    super.key,
    required this.formData,
    required this.updateFormData,
  });

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  List<String> _keyBenefits = [''];
  List<String> _potentialRisks = [''];
  List<Map<String, dynamic>> _timeline = [];

  @override
  void initState() {
    super.initState();
    _keyBenefits = List<String>.from(widget.formData['keyBenefits'] ?? ['']);
    _potentialRisks = List<String>.from(widget.formData['potentialRisks'] ?? ['']);
    _timeline = List<Map<String, dynamic>>.from(widget.formData['timeline'] ?? []);
  }

  void _updateFormData() {
    widget.updateFormData({
      'keyBenefits': _keyBenefits.where((b) => b.trim().isNotEmpty).toList(),
      'potentialRisks': _potentialRisks.where((r) => r.trim().isNotEmpty).toList(),
      'timeline': _timeline,
    });
  }

  void _addBenefit() {
    setState(() {
      _keyBenefits.add('');
      _updateFormData();
    });
  }

  void _removeBenefit(int index) {
    setState(() {
      _keyBenefits.removeAt(index);
      if (_keyBenefits.isEmpty) _keyBenefits.add('');
      _updateFormData();
    });
  }

  void _updateBenefit(int index, String value) {
    setState(() {
      _keyBenefits[index] = value;
      _updateFormData();
    });
  }

  void _addRisk() {
    setState(() {
      _potentialRisks.add('');
      _updateFormData();
    });
  }

  void _removeRisk(int index) {
    setState(() {
      _potentialRisks.removeAt(index);
      if (_potentialRisks.isEmpty) _potentialRisks.add('');
      _updateFormData();
    });
  }

  void _updateRisk(int index, String value) {
    setState(() {
      _potentialRisks[index] = value;
      _updateFormData();
    });
  }

  void _addTimelinePhase() {
    setState(() {
      _timeline.add({
        'phase': '',
        'title': '',
        'date': '',
        'status': 'upcoming',
      });
      _updateFormData();
    });
  }

  void _removeTimelinePhase(int index) {
    setState(() {
      _timeline.removeAt(index);
      _updateFormData();
    });
  }

  void _updateTimelinePhase(int index, String field, dynamic value) {
    setState(() {
      _timeline[index][field] = value;
      _updateFormData();
    });
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
            'Additional Details (Optional)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add key benefits, potential risks, and project timeline to make your project more attractive to investors.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Key Benefits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Benefits',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addBenefit,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_keyBenefits.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _keyBenefits[index],
                      decoration: InputDecoration(
                        hintText: 'Enter key benefit ${index + 1}',
                        prefixIcon: const Icon(Icons.check_circle_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => _updateBenefit(index, value),
                    ),
                  ),
                  if (_keyBenefits.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeBenefit(index),
                      color: Colors.red,
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Potential Risks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Potential Risks',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addRisk,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_potentialRisks.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _potentialRisks[index],
                      decoration: InputDecoration(
                        hintText: 'Enter potential risk ${index + 1}',
                        prefixIcon: const Icon(Icons.warning_amber_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => _updateRisk(index, value),
                    ),
                  ),
                  if (_potentialRisks.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeRisk(index),
                      color: Colors.red,
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project Timeline',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addTimelinePhase,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No timeline phases added yet',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ...List.generate(_timeline.length, (index) {
              final phase = _timeline[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phase ${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeTimelinePhase(index),
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: phase['phase'] ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Phase Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) =>
                            _updateTimelinePhase(index, 'phase', value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: phase['title'] ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Phase Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) =>
                            _updateTimelinePhase(index, 'title', value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: phase['date'] ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Expected Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) =>
                            _updateTimelinePhase(index, 'date', value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: phase['status'] ?? 'upcoming',
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'upcoming',
                            child: Text('Upcoming'),
                          ),
                          DropdownMenuItem(
                            value: 'in-progress',
                            child: Text('In Progress'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _updateTimelinePhase(index, 'status', value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

