import 'package:finial_project/services/api_service.dart';
import 'package:finial_project/services/auth_storage.dart';

class InvestmentsService {
  static Future<List<Map<String, dynamic>>> fetchUserInvestments() async {
    final summary = await AuthStorage.getUserSummary();
    final userId = summary['id'];
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final res = await ApiService.get('projects/user/$userId', auth: true);
    if (res['status'] == 200 && res['userProjects'] is List) {
      final list = List<Map<String, dynamic>>.from(
        (res['userProjects'] as List)
            .where((e) => e is Map<String, dynamic>)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)),
      );
      // For investors response is investedProjects; normalize items
      // Each item expected: { project, percentage, amount, investedAt }
      final investments = <Map<String, dynamic>>[];
      for (final item in list) {
        // If the API returned owned projects, skip
        if (item.containsKey('project')) {
          final project = item['project'];
          final normalized = {
            'project': project,
            'percentage': (item['percentage'] as num?)?.toDouble() ?? 0,
            'amount': (item['amount'] as num?)?.toDouble() ?? 0,
            'investedAt': item['investedAt']?.toString(),
          };
          investments.add(normalized);
        }
      }
      return investments;
    }
    return [];
  }
}


