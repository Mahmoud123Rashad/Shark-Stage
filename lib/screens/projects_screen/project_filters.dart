import 'package:flutter/material.dart';

class ProjectFilters {
  final List<String> categories;
  final String? status;
  final double? minRoi;
  final double? maxRoi;
  final double? minPrice;
  final double? maxPrice;

  const ProjectFilters({
    this.categories = const [],
    this.status,
    this.minRoi,
    this.maxRoi,
    this.minPrice,
    this.maxPrice,
  });

  ProjectFilters copyWith({
    List<String>? categories,
    String? status,
    double? minRoi,
    double? maxRoi,
    double? minPrice,
    double? maxPrice,
  }) {
    return ProjectFilters(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      minRoi: minRoi ?? this.minRoi,
      maxRoi: maxRoi ?? this.maxRoi,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

typedef OnApplyFilters = void Function(ProjectFilters filters);

class ProjectFiltersSheet extends StatefulWidget {
  const ProjectFiltersSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final ProjectFilters initial;
  final OnApplyFilters onApply;

  @override
  State<ProjectFiltersSheet> createState() => _ProjectFiltersSheetState();
}

class _ProjectFiltersSheetState extends State<ProjectFiltersSheet> {
  static const _categories = <String>[
    'All',
    'Technology',
    'E-Commerce',
    'Food',
    'Health',
    'Education',
    'Real Estate',
    'Industrial',
    'Other',
  ];
  static const _statuses = <String>[
    'active',
    'closed',
  ];

  List<String> _categoriesSelected = const [];
  String? _status;
  double? _minRoi;
  double? _maxRoi;
  double? _minPrice;
  double? _maxPrice;

  final _minRoiController = TextEditingController();
  final _maxRoiController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesSelected = List<String>.from(widget.initial.categories);
    _status = widget.initial.status;
    _minRoi = widget.initial.minRoi;
    _maxRoi = widget.initial.maxRoi;
    _minPrice = widget.initial.minPrice;
    _maxPrice = widget.initial.maxPrice;
    _minRoiController.text = _minRoi?.toString() ?? '';
    _maxRoiController.text = _maxRoi?.toString() ?? '';
    _minPriceController.text = _minPrice?.toString() ?? '';
    _maxPriceController.text = _maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _minRoiController.dispose();
    _maxRoiController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters', style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _categoriesSelected = const [];
                      _status = null;
                      _minRoi = null;
                      _maxRoi = null;
                      _minPrice = null;
                      _maxPrice = null;
                      _minRoiController.clear();
                      _maxRoiController.clear();
                      _minPriceController.clear();
                      _maxPriceController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                if (c == 'All') {
                  final isAll = _categoriesSelected.isEmpty;
                  return FilterChip(
                    label: const Text('All'),
                    selected: isAll,
                    onSelected: (_) {
                      setState(() {
                        _categoriesSelected = const [];
                      });
                    },
                  );
                }
                final selected = _categoriesSelected.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _categoriesSelected = [..._categoriesSelected, c];
                      } else {
                        _categoriesSelected = _categoriesSelected.where((e) => e != c).toList();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _statuses
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s[0].toUpperCase() + s.substring(1)),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _minRoiController,
                    label: 'Min ROI %',
                    onChanged: (v) => _minRoi = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _maxRoiController,
                    label: 'Max ROI %',
                    onChanged: (v) => _maxRoi = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _minPriceController,
                    label: 'Min Price',
                    onChanged: (v) => _minPrice = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _maxPriceController,
                    label: 'Max Price',
                    onChanged: (v) => _maxPrice = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(
                    ProjectFilters(
                      categories: _categoriesSelected,
                      status: _status,
                      minRoi: _minRoi,
                      maxRoi: _maxRoi,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}


