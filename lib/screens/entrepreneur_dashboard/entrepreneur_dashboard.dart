import 'package:finial_project/controllers/owner_dashboard_controller.dart';
import 'package:finial_project/widgets/entrepreneur_project_card.dart';
import 'package:finial_project/widgets/entrepreneur_stat_card.dart';
import 'package:flutter/material.dart';
// تم تصحيح مسارات الـ widgets والمتحكم لإزالة التكرار

// ملاحظة: نموذج Project يتم استيراده ضمنياً مع ملف المتحكم إذا كان مُعرّفاً فيه.

class EntrepreneurDashboard extends StatefulWidget {
   const EntrepreneurDashboard({super.key});

   @override
   State<EntrepreneurDashboard> createState() => _EntrepreneurDashboardState();
}

class _EntrepreneurDashboardState extends State<EntrepreneurDashboard> {
   final _controller = OwnerDashboardController();
   
   // يجب استخدام "Project" المُعرَّف في owner_dashboard_controller.dart
   late Future<List<Project>> _projectsFuture; 
   late Future<Map<String, String>> _statsFuture;

   @override
   void initState() {
      super.initState();
      _projectsFuture = _controller.fetchOwnerProjects();
      _statsFuture = _controller.fetchStats();
   }

   @override
   Widget build(BuildContext context) {
      final theme = Theme.of(context);

      return Scaffold(
         backgroundColor: theme.scaffoldBackgroundColor,
         appBar: AppBar(
            title: Text(
               "Entrepreneur Dashboard",
               style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
               ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
         ),
         body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text("Welcome... ", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Here's a quick overview of your performance today", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),

                  // --- قسم الإحصائيات ---
                  FutureBuilder<Map<String, String>>(
                     future: _statsFuture,
                     builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CircularProgressIndicator());
                        }
                        final stats = snapshot.data ?? {};
                        return Column(
                           children: [
                              Row(
                                 children: [
                                    // تم استخدام Expanded لضمان توزيع المساحة بالتساوي
                                    Expanded(child: EntrepreneurStatCard(title: "Projects", value: stats["Projects"] ?? "0", icon: Icons.business_center, color: Colors.deepPurple)),
                                    Expanded(child: EntrepreneurStatCard(title: "Earnings", value: stats["Earnings"] ?? "£ 0", icon: Icons.attach_money, color: Colors.green)),
                                 ],
                              ),
                              Row(
                                 children: [
                                    Expanded(child: EntrepreneurStatCard(title: "New Orders", value: stats["NewOrders"] ?? "0", icon: Icons.shopping_cart, color: Colors.orange)),
                                    Expanded(child: EntrepreneurStatCard(title: "Clients", value: stats["Clients"] ?? "0", icon: Icons.people_alt, color: Colors.teal)),
                                 ],
                              ),
                           ],
                        );
                     },
                  ),

                  const SizedBox(height: 20),

                  // --- قسم المشاريع ---
                  Text(
                     "Current Projects",
                     style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<Project>>(
                     future: _projectsFuture,
                     builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: LinearProgressIndicator());
                        }
                        if (snapshot.hasError) {
                           // عرض رسالة خطأ واضحة
                           return Center(child: Text('Failed to load projects: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                           return const Center(child: Text("You have no projects yet."));
                        }

                        return Column(
                           children: snapshot.data!.map((project) {
                              return EntrepreneurProjectCard(
                                 projectName: project.title,
                                 status: project.status,
                                 progress: project.progress,
                              );
                           }).toList(),
                        );
                     },
                  ),
               ],
            ),
         ),
      );
   }
}