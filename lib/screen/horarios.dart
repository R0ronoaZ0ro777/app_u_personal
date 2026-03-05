import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Horarios extends StatefulWidget {
  const Horarios({super.key});

  @override
  State<Horarios> createState() => _HorariosState();
}

class Schedule {
  int id;
  String name;
  String room;
  int day; // 1=lunes ...7=domingo
  String start; // HH:mm
  String end; // HH:mm
  int colorValue;

  Schedule({
    required this.id,
    required this.name,
    required this.room,
    required this.day,
    required this.start,
    required this.end,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'room': room,
        'day': day,
        'start': start,
        'end': end,
        'colorValue': colorValue,
      };

  static Schedule fromJson(Map<String, dynamic> j) => Schedule(
        id: j['id'] as int,
        name: j['name'] as String,
        room: j['room'] as String,
        day: j['day'] as int,
        start: j['start'] as String,
        end: j['end'] as String,
        colorValue: j['colorValue'] as int,
      );
}

class _HorariosState extends State<Horarios> {
  List<Schedule> schedules = [];
  final String storageKey = 'schedules_v1';

  final Map<String, Color> colorOptions = {
    'Azul': Colors.blue,
    'Verde': Colors.green,
    'Rojo': Colors.red,
    'Naranja': Colors.orange,
    'Morado': Colors.purple,
    'Gris': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      schedules = decoded.map((e) => Schedule.fromJson(Map<String, dynamic>.from(e))).toList();
      setState(() {});
    }
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final enc = jsonEncode(schedules.map((s) => s.toJson()).toList());
    await sp.setString(storageKey, enc);
  }

  void _openForm({Schedule? edit}) async {
    final isEdit = edit != null;
    final nameCtl = TextEditingController(text: edit?.name ?? '');
    final roomCtl = TextEditingController(text: edit?.room ?? '');
    int daySel = edit?.day ?? 1;
    TimeOfDay? start = edit != null ? _parseTime(edit.start) : null;
    TimeOfDay? end = edit != null ? _parseTime(edit.end) : null;
    String colorName = colorOptions.entries.firstWhere((e) => e.value.value == (edit?.colorValue ?? Colors.blue.value)).key;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(isEdit ? 'Editar horario' : 'Agregar horario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Nombre del ramo')),
                  TextField(controller: roomCtl, decoration: const InputDecoration(labelText: 'Sala')),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: daySel,
                        items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(_dayName(i + 1)))),
                        onChanged: (v) => setStateDialog(() => daySel = v ?? 1),
                        decoration: const InputDecoration(labelText: 'Día'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: ctx, initialTime: start ?? TimeOfDay(hour: 8, minute: 0));
                          if (picked != null) setStateDialog(() => start = picked);
                        },
                        child: Text(start != null ? start!.format(ctx) : 'Hora inicio'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: ctx, initialTime: end ?? TimeOfDay(hour: 9, minute: 0));
                          if (picked != null) setStateDialog(() => end = picked);
                        },
                        child: Text(end != null ? end!.format(ctx) : 'Hora fin'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: colorName,
                    items: colorOptions.keys.map((k) => DropdownMenuItem(value: k, child: Row(children: [Container(width: 12, height: 12, color: colorOptions[k]), const SizedBox(width: 8), Text(k)]))).toList(),
                    onChanged: (v) => setStateDialog(() => colorName = v ?? colorOptions.keys.first),
                    decoration: const InputDecoration(labelText: 'Color'),
                  ),
                ],
              ),
            ),
            actions: [
              if (isEdit)
                TextButton(
                  onPressed: () {
                    // delete
                    schedules.removeWhere((s) => s.id == edit!.id);
                    _save();
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtl.text.trim().isEmpty || roomCtl.text.trim().isEmpty || start == null || end == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
                    return;
                  }
                  final s = Schedule(
                    id: isEdit ? edit!.id : DateTime.now().millisecondsSinceEpoch,
                    name: nameCtl.text.trim(),
                    room: roomCtl.text.trim(),
                    day: daySel,
                    start: _formatTime(start!),
                    end: _formatTime(end!),
                    colorValue: colorOptions[colorName]!.value,
                  );
                  if (isEdit) {
                    final idx = schedules.indexWhere((it) => it.id == edit!.id);
                    if (idx != -1) schedules[idx] = s;
                  } else {
                    schedules.add(s);
                  }
                  schedules.sort((a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)));
                  _save();
                  setState(() {});
                  Navigator.of(ctx).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  static String _dayName(int d) {
    switch (d) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _formatTime(TimeOfDay t) => t.hour.toString().padLeft(2, '0') + ':' + t.minute.toString().padLeft(2, '0');

  static int _timeToMinutes(String hhmm) {
    final p = hhmm.split(':');
    final h = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = index + 1; // 1-7
          final items = schedules.where((s) => s.day == day).toList()
            ..sort((a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)));
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              initiallyExpanded: false,
              title: Row(children: [Text(_dayName(day), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text('(${items.length})')]),
              children: items.isEmpty
                  ? [const ListTile(title: Text('No hay horarios'))]
                  : items
                      .map(
                        (s) => ListTile(
                          leading: Container(width: 12, height: 40, color: Color(s.colorValue)),
                          title: Text(s.name),
                          subtitle: Text('${s.room} • ${s.start} - ${s.end}'),
                          onTap: () => _openForm(edit: s),
                        ),
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}