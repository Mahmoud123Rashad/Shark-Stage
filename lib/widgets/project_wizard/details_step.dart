import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
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
    String hintText,
    String initialValue,
    Function(String) onChanged,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(16),
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
        initialValue: initialValue,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
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
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
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
              ],
            ),
          ),

          // Key Benefits
          _buildSectionTitle('Key Benefits', Icons.check_circle, theme, colorScheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green,
                      Colors.green.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addBenefit,
                ),
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
                    child: _buildTextField(
                      'Enter key benefit ${index + 1}',
                      _keyBenefits[index],
                      (value) => _updateBenefit(index, value),
                      Icons.check_circle_outline,
                      theme,
                      colorScheme,
                    ),
                  ),
                  if (_keyBenefits.length > 1)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeBenefit(index),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Potential Risks
          _buildSectionTitle('Potential Risks', Icons.warning, theme, colorScheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addRisk,
                ),
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
                    child: _buildTextField(
                      'Enter potential risk ${index + 1}',
                      _potentialRisks[index],
                      (value) => _updateRisk(index, value),
                      Icons.warning_amber_outlined,
                      theme,
                      colorScheme,
                    ),
                  ),
                  if (_potentialRisks.length > 1)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeRisk(index),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Timeline
          _buildSectionTitle('Project Timeline', Icons.timeline, theme, colorScheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addTimelinePhase,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_timeline.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colorScheme.surface.withOpacity(0.3),
                          colorScheme.surface.withOpacity(0.1),
                        ]
                      : [
                          Colors.white.withOpacity(0.5),
                          colorScheme.primary.withOpacity(0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 48,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No timeline phases added yet',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_timeline.length, (index) {
              final phase = _timeline[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                  borderRadius: BorderRadius.circular(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.button,
                                AppColors.button.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Phase ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTimelinePhase(index),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Phase Name',
                      phase['phase'] ?? '',
                      (value) => _updateTimelinePhase(index, 'phase', value),
                      Icons.label,
                      theme,
                      colorScheme,
                    ),
                    _buildTextField(
                      'Phase Title',
                      phase['title'] ?? '',
                      (value) => _updateTimelinePhase(index, 'title', value),
                      Icons.title,
                      theme,
                      colorScheme,
                    ),
                    _buildTextField(
                      'Expected Date',
                      phase['date'] ?? '',
                      (value) => _updateTimelinePhase(index, 'date', value),
                      Icons.calendar_today,
                      theme,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: phase['status'] ?? 'upcoming',
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.flag, color: colorScheme.primary, size: 20),
                          ),
                          labelText: 'Status',
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
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
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}


