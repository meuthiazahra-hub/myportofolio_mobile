import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _company = "";
  String _position = "";
  String _employmentType = "Full-time"; // default
  String _location = "";
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  String _description = "";

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Freelance',
    'Contract',
  ];
  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd'; // yyyy-MM-dd, cocok dengan DateField Django
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _company = "";
      _position = "";
      _employmentType = "Full-time";
      _location = "";
      _startDate = null;
      _endDate = null;
      _isCurrent = false;
      _description = "";
      _startDateController.clear();
      _endDateController.clear();
    });
  }
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Company ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Perusahaan",
                    labelText: "Nama Perusahaan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  onChanged: (String? value) {
                    setState(() { _company = value!; });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama perusahaan tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),
                          // === Position ===
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Contoh: Backend Developer",
                labelText: "Posisi / Jabatan",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onChanged: (String? value) {
                setState(() { _position = value!; });
              },
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return "Posisi tidak boleh kosong!";
                }
                return null;
              },
            ),
          ),

          // === Employment Type ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Tipe Pekerjaan",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              initialValue: _employmentType,
              items: _employmentTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() { _employmentType = newValue!; });
              },
            ),
          ),

          // === Location ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Contoh: Jakarta, Indonesia",
                labelText: "Lokasi",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onChanged: (String? value) {
                setState(() { _location = value!; });
              },
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return "Lokasi tidak boleh kosong!";
                }
                return null;
              },
            ),
          ),

          // === Start Date ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _pickDate(isStart: true),
              decoration: InputDecoration(
                hintText: "Pilih tanggal mulai",
                labelText: "Tanggal Mulai",
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Tanggal mulai tidak boleh kosong!";
                }
                return null;
              },
            ),
          ),

          // === Currently Working ===
          CheckboxListTile(
            title: const Text("Saya masih bekerja di sini"),
            value: _isCurrent,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() {
                _isCurrent = value!;
                if (_isCurrent) {
                  _endDate = null;
                  _endDateController.clear();
                }
              });
            },
          ),

          // === End Date ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _endDateController,
              readOnly: true,
              enabled: !_isCurrent,
              onTap: () => _pickDate(isStart: false),
              decoration: InputDecoration(
                hintText: "Pilih tanggal selesai",
                labelText: "Tanggal Selesai",
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              validator: (String? value) {
                if (_isCurrent) return null;
                if (value == null || value.isEmpty) {
                  return "Tanggal selesai tidak boleh kosong!";
                }
                if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                  return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
                }
                return null;
              },
            ),
          ),

          // === Description ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Deskripsi Pekerjaan",
                labelText: "Deskripsi Pekerjaan",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onChanged: (String? value) {
                setState(() { _description = value!; });
              },
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return "Deskripsi tidak boleh kosong!";
                }
                return null;
              },
            ),
          ),
          // === Tombol Simpan ===
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.indigo),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Pengalaman berhasil ditambahkan!'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Perusahaan: $_company'),
                              Text('Posisi: $_position'),
                              Text('Tipe: $_employmentType'),
                              Text('Lokasi: $_location'),
                              Text('Mulai: ${_startDateController.text}'),
                              Text('Selesai: ${_isCurrent ? "Sekarang" : _endDateController.text}'),
                              Text('Deskripsi: $_description'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                              _resetForm();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
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