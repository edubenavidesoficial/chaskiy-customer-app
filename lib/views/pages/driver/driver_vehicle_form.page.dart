import 'dart:io';

import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/requests/driver_vehicle.request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DriverVehicleFormPage extends StatefulWidget {
  const DriverVehicleFormPage({super.key});

  @override
  State<DriverVehicleFormPage> createState() => _DriverVehicleFormPageState();
}

class _DriverVehicleFormPageState extends State<DriverVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _request = DriverVehicleRequest();
  final _registration = TextEditingController();
  final _color = TextEditingController();
  List<Map<String, dynamic>> _makes = const [];
  List<Map<String, dynamic>> _models = const [];
  List<Map<String, dynamic>> _types = const [];
  List<File> _documents = const [];
  int? _makeId;
  int? _modelId;
  int? _typeId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final values = await Future.wait([
        _request.options(Api.driverCarMakes),
        _request.options(Api.driverVehicleTypes),
      ]);
      if (mounted) setState(() { _makes = values[0]; _types = values[1]; });
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectMake(int? id) async {
    setState(() { _makeId = id; _modelId = null; _models = const []; });
    if (id == null) return;
    try {
      final models = await _request.options(
        Api.driverCarModels,
        query: {'car_make_id': id},
      );
      if (mounted) setState(() => _models = models);
    } catch (error) { _error(error); }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;
    setState(() => _documents = result.paths.whereType<String>().map(File.new).toList());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await _request.register(values: {
        'car_make_id': _makeId,
        'car_model_id': _modelId,
        'vehicle_type_id': _typeId,
        'reg_no': _registration.text.trim(),
        'color': _color.text.trim(),
      }, documents: _documents);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _error(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$error'), backgroundColor: Colors.red),
    );
  }

  DropdownMenuItem<int> _item(Map<String, dynamic> value) => DropdownMenuItem(
    value: int.parse(value['id'].toString()),
    child: Text(value['name']?.toString() ?? ''),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registrar vehículo')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<int>(
                  value: _makeId,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  items: _makes.map(_item).toList(),
                  onChanged: _selectMake,
                  validator: (value) => value == null ? 'Selecciona una marca' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _modelId,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  items: _models.map(_item).toList(),
                  onChanged: (value) => setState(() => _modelId = value),
                  validator: (value) => value == null ? 'Selecciona un modelo' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _typeId,
                  decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
                  items: _types.map(_item).toList(),
                  onChanged: (value) => setState(() => _typeId = value),
                  validator: (value) => value == null ? 'Selecciona un tipo' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _registration,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Placa o matrícula'),
                  validator: (value) => (value ?? '').trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _color,
                  decoration: const InputDecoration(labelText: 'Color'),
                  validator: (value) => (value ?? '').trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _pickDocuments,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_documents.isEmpty
                      ? 'Adjuntar documentos (opcional)'
                      : '${_documents.length} documento(s) seleccionado(s)'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Guardar vehículo'),
                ),
              ],
            ),
          ),
  );
}
