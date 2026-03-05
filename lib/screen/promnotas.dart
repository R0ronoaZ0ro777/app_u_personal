import 'package:flutter/material.dart';

class PromNotas extends StatefulWidget {
  const PromNotas({super.key});

  @override
  State<PromNotas> createState() => _PromNotasState();
}

class _NoteRow {
  final TextEditingController gradeCtl;
  final TextEditingController percentCtl;

  _NoteRow({String grade = '', String percent = ''})
      : gradeCtl = TextEditingController(text: grade),
        percentCtl = TextEditingController(text: percent);

  void dispose() {
    gradeCtl.dispose();
    percentCtl.dispose();
  }
}

class _PromNotasState extends State<PromNotas> {
  final List<_NoteRow> _rows = [];
  double? _result;
  static const double _passing = 40.0; // umbral para aprobar

  @override
  void initState() {
    super.initState();
    // empezar con 3 campos por defecto
    for (var i = 0; i < 3; i++) {
      _rows.add(_NoteRow());
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_NoteRow()));
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _clear() {
    setState(() {
      for (final r in _rows) {
        r.dispose();
      }
      _rows.clear();
      for (var i = 0; i < 3; i++) {
        _rows.add(_NoteRow());
      }
      _result = null;
    });
  }

  void _calculate() {
    double sum = 0.0;
    double percentSum = 0.0;
    for (final r in _rows) {
      final gText = r.gradeCtl.text.trim();
      final pText = r.percentCtl.text.trim();
      if (gText.isEmpty || pText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todas las notas y porcentajes')));
        return;
      }
      final g = double.tryParse(gText.replaceAll(',', '.'));
      final p = double.tryParse(pText.replaceAll(',', '.'));
      if (g == null || p == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa valores numéricos válidos')));
        return;
      }
      // escala chilena 10..70 - no forzamos, sólo advertimos
      if (g < 0 || g > 1000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valor de nota fuera de rango')));
        return;
      }
      sum += g * (p / 100.0);
      percentSum += p;
    }

    setState(() => _result = double.parse(sum.toStringAsFixed(2)));

    String title = 'Resultado: ${_result!.toStringAsFixed(2)}';
    String subtitle = '';
    if ((percentSum - 100.0).abs() > 0.001) {
      subtitle = 'Suma de porcentajes = ${percentSum.toStringAsFixed(2)} (ideal 100)';
    } else {
      subtitle = 'Suma de porcentajes = 100%';
    }
    final passed = _result! >= _passing;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            Text(passed ? 'Estado: Aprobado' : 'Estado: Reprobado', style: TextStyle(color: passed ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promedio de Notas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DataTable(
                      columnSpacing: 12,
                      columns: const [
                        DataColumn(label: Center(child: Text('#', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                        DataColumn(label: Center(child: Text('Nota (10-70)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                        DataColumn(label: Center(child: Text('%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                        DataColumn(label: Center(child: Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                      ],
                      rows: List.generate(_rows.length, (i) {
                        final row = _rows[i];
                        return DataRow(cells: [
                          DataCell(Center(child: Text('Nota ${i + 1}', style: const TextStyle(fontSize: 16)))),
                          DataCell(Center(child: SizedBox(width: 140, child: TextField(textAlign: TextAlign.center, style: const TextStyle(fontSize: 16), controller: row.gradeCtl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'ej: 40'))))),
                          DataCell(Center(child: SizedBox(width: 110, child: TextField(textAlign: TextAlign.center, style: const TextStyle(fontSize: 16), controller: row.percentCtl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'ej: 30'))))),
                          DataCell(Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (_rows.length > 1)
                              IconButton(onPressed: () => _removeRow(i), icon: const Icon(Icons.delete, color: Colors.red, size: 24)),
                          ]))),
                        ]);
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text(' Agregar ')),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate), label: const Text(' Calcular ')),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(onPressed: _clear, icon: const Icon(Icons.clear), label: const Text(' Limpiar ')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_result != null)
                      Center(
                        child: Card(
                          color: _result! >= _passing ? Colors.green[50] : Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Promedio: ${_result!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(_result! >= _passing ? 'Aprobado' : 'Reprobado', style: TextStyle(color: _result! >= _passing ? Colors.green : Colors.red, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
