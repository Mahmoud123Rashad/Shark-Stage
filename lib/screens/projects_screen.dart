// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
// import 'project_details_screen.dart';

// class ProjectsScreen extends StatelessWidget {
//   const ProjectsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Available Projects"),
//         backgroundColor: AppColors.button,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('projects')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No projects available."));
//           }

//           final projects = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(10),
//             itemCount: projects.length,
//             itemBuilder: (context, index) {
//               final project = projects[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Project Image
//                       if (project['imageUrl'] != null && project['imageUrl'] != '')
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             project['imageUrl'],
//                             height: 180,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       const SizedBox(height: 10),

//                       // Project Title
//                       Text(
//                         project['title'],
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 5),

//                       // Project Details (3 lines)
//                       Text(
//                         project['details'],
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 5),

//                       // Price
//                       Text(
//                         "Price: \$${project['price']}",
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),

//                       // View Details Button
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ProjectDetailsScreen(
//                                   projectId: project.id,
//                                 ),
//                               ),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.button,
//                           ),
//                           child: const Text("View Full Project"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> projects = List.generate(10, (index) {
      return {
        'title': 'Project ${index + 1}',
        'details':
            'This is a brief description of project ${index + 1}. It focuses on innovation, technology, and business growth opportunities.',
        'price': (index + 1) * 5000,
        'imageUrl':
            'https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=60',
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Projects"),
        backgroundColor: AppColors.button,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];

            return Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 6,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        project['imageUrl'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      project['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      project['details'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Investment: \$${project['price']}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(
                                projectId: 'project_${index + 1}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text("View Full Project"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
