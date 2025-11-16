import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/investments_service.dart';
import '../project_details/project_details_screen.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  bool _isLoading = true;
  String _sort = 'Newest';
  final _sortOptions = const ['Newest', 'Amount (High)', 'Amount (Low)', 'Percentage'];
  List<Map<String, dynamic>> _investments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await InvestmentsService.fetchUserInvestments();
    setState(() {
      _investments = data;
      _applySort();
      _isLoading = false;
    });
  }

  void _applySort() {
    switch (_sort) {
      case 'Amount (High)':
        _investments.sort((a, b) => ((b['amount'] as num?)?.toDouble() ?? 0)
            .compareTo(((a['amount'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Amount (Low)':
        _investments.sort((a, b) => ((a['amount'] as num?)?.toDouble() ?? 0)
            .compareTo(((b['amount'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Percentage':
        _investments.sort((a, b) => ((b['percentage'] as num?)?.toDouble() ?? 0)
            .compareTo(((a['percentage'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Newest':
      default:
        _investments.sort((a, b) {
          final ad = DateTime.tryParse(a['investedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = DateTime.tryParse(b['investedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
    }
  }

  String _fmtDate(String? s) {
    final d = DateTime.tryParse(s ?? '');
    if (d == null) return '';
    return DateFormat('yMMMd • HH:mm').format(d);
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Investments'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sort,
            onSelected: (v) {
              setState(() => _sort = v);
              setState(_applySort);
            },
            itemBuilder: (context) => _sortOptions
                .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
                .toList(),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _investments.isEmpty
              ? const Center(child: Text('You have no investments yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _investments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final inv = _investments[index];
                    final project = inv['project'];
                    final title = (project is Map<String, dynamic>) ? (project['title']?.toString() ?? 'Project') : 'Project';
                    final projectId = (project is Map<String, dynamic>) ? (project['_id']?.toString() ?? '') : project?.toString() ?? '';
                    final percentage = (inv['percentage'] as num?)?.toDouble() ?? 0;
                    final amount = (inv['amount'] as num?)?.toDouble() ?? 0;
                    final date = _fmtDate(inv['investedAt']?.toString());

                    return Card(
                      child: ListTile(
                        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
                            Text('Amount: \$${amount.toStringAsFixed(2)}'),
                            if (date.isNotEmpty) Text(date, style: theme.textTheme.bodySmall),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: projectId.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailsScreen(projectId: projectId),
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),
    );
  }
}


