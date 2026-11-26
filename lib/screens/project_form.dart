import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:provider/provider.dart';

// TODO: Import the drawer created earlier

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  bool _isSubmitting = false;
  bool _checkingAuth = true;
  final _formKey = GlobalKey<FormState>();
  String _projectName = "";
  String _description = "";
  String _category = "Web Development"; // default
  String _technologies = "";
  String _projectLink = "";

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (context.read<AuthState>().isLoggedIn) {
        setState(() => _checkingAuth = false);
        return;
      }
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted) return;
      if (context.read<AuthState>().isLoggedIn) {
        setState(() => _checkingAuth = false);
      } else {
        Navigator.pop(context);
      }
    });
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    try {
      final api = context.read<ApiClient>();

      // TODO: ganti sesuai cara project kamu menyimpan token
      // (misalnya AuthProvider / SharedPreferences)
      final token = context.read<AuthState>().token;
      if (token == null) {
        throw const ApiException(401, 'Please log in before adding a project.');
      }

      final project = Project(
        title: _projectName,
        description: _description,
        techStack: _technologies,
        projectUrl: _projectLink,
      );

      final created = await api.createProject(project, token: token);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Project added successfully!'),
          content: Text(created.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      _formKey.currentState!.reset();
      setState(() => _category = _categories.first);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // TODO: Add the drawer we created earlier
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _projectName = value ?? "";
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the project name';
                    }
                    return null;
                  },
                ),
              ),
              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Describe your project",
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onSaved: (value) {
                    _description = value ?? "";
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a project description.";
                    }
                    return null;
                  },
                ),
              ),
              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Project Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Technologies ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Example: Flutter, Django, Figma",
                    labelText: "Technologies Used",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _technologies = value!;
                    });
                  },
                ),
              ),

              // === Project Link ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Project URL (optional)",
                    labelText: "Project Link",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _projectLink = value!;
                    });
                  },
                ),
              ),
              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
              onPressed: _isSubmitting ? null : _submit,
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

