import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../data/projects_repository.dart';
import '../domain/project.dart';

final AutoDisposeAsyncNotifierProvider<ProjectsController, List<Project>>
projectsControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProjectsController, List<Project>>(
      ProjectsController.new,
    );

class ProjectsController extends AutoDisposeAsyncNotifier<List<Project>> {
  late final ProjectsRepository _repository;

  @override
  Future<List<Project>> build() async {
    _repository = ref.read(projectsRepositoryProvider);
    return _fetchProjects();
  }

  Future<List<Project>> _fetchProjects() async {
    try {
      final List<Project> projects = await _repository.fetchAll();
      return projects;
    } on NetworkException catch (error) {
      state = AsyncValue.error(error.message, StackTrace.current);
      return <Project>[];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchProjects());
  }
}
