import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(project.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (project.projectImageUrl.isNotEmpty) ...[
              Image.network(
                project.projectImageUrl,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
            ],
            Text(project.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Technologies: ${project.techStack}'),
            const SizedBox(height: 12),
            Text(project.description),
            if (project.projectUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectableText('Project URL: ${project.projectUrl}'),
            ],
          ],
        ),
      );
}
