import 'package:flutter/material.dart';
//import 'package:myapp/pages/crearReunion1.dart';
import 'package:myapp/pages/crearReunion3.dart';
import 'package:myapp/utils/homeNavigation.dart';

class CrearReunion2 extends StatelessWidget {
  const CrearReunion2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Reunion'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Fecha', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 4),
                        Fecha(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Hora
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Hora', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 4),
                        Hora(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Tipo de Reunion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: FilterButton(text: 'Unica')),
                  const SizedBox(width: 16),
                  Expanded(child: FilterButton(text: 'Repetir cada semana')),
                ],
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Sala/Beacon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),

              const SizedBox(height: 6),
              
              // --- EJEMPLO LISTA DE REUNIONES ---
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SalaBeaconCard(
                    titulo: 'Beacon A1-1',
                    estado: 'Activo',
                    lugar: 'Oficina 1 ',
                  ),
                  SalaBeaconCard(
                    titulo: 'Beacon A1-2',
                    estado: 'Inactivo',
                    lugar: 'Oficina 2 ',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const BotonesReunion2(),
            ],
          ),
        ),
      )
      
    );
  }
}

class BotonesReunion2 extends StatelessWidget {
  const BotonesReunion2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón de siguiente
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 56, 140, 208),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrearReunion3()),
              );
            },
            child: const Text('Siguiente', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        // Botón de cancelar
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 172, 48, 48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              volverAlInicio(context);
            },
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

// --- WIDGET TARJETA DE REUNIÓN ---
class SalaBeaconCard extends StatefulWidget {
  final String titulo;
  final String estado;
  final String lugar;
  const SalaBeaconCard({
    super.key,
    required this.titulo,
    required this.estado,
    required this.lugar,
  });

  @override
  State<SalaBeaconCard> createState() => _SalaBeaconCardState();
}

class _SalaBeaconCardState extends State<SalaBeaconCard> {
  bool _seleccionado = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _seleccionado
          ? const Color.fromARGB(255, 87, 177, 60)
          : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${widget.estado} | ${widget.lugar}'),
        onTap: () {
          setState(() {
            _seleccionado = !_seleccionado;
          });
        },
      ),
    );
  }
}

class Fecha extends StatefulWidget {
  const Fecha({super.key});
  @override
  State<Fecha> createState() => _FechaState();
}

class _FechaState extends State<Fecha> {
  DateTime? _currentSelectedDate;

  void callDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _currentSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(data: ThemeData.light(), child: child);
      },
    );
    if (selectedDate != null) {
      setState(() {
        _currentSelectedDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fechaTexto = _currentSelectedDate == null
        ? 'Seleccione Fecha'
        : '${_currentSelectedDate!.day.toString().padLeft(2, '0')}/'
              '${_currentSelectedDate!.month.toString().padLeft(2, '0')}/'
              '${_currentSelectedDate!.year}';

    return ElevatedButton(
      onPressed: callDatePicker,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fechaTexto,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Hora extends StatefulWidget {
  const Hora({super.key});
  @override
  State<Hora> createState() => _HoraState();
}

class _HoraState extends State<Hora> {
  TimeOfDay? _currentSelectedTime;

  void callTimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _currentSelectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(data: ThemeData.light(), child: child);
      },
    );

    if (selectedTime != null) {
      setState(() {
        _currentSelectedTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String horaTexto = _currentSelectedTime == null
        ? 'Seleccione Hora'
        : '${_currentSelectedTime!.hour.toString().padLeft(2, '0')}:'
              '${_currentSelectedTime!.minute.toString().padLeft(2, '0')}';

    return ElevatedButton(
      onPressed: callTimePicker,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            horaTexto,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatefulWidget {
  final String text;
  const FilterButton({super.key, required this.text});
  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool seleccionado = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          seleccionado = !seleccionado;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: seleccionado
            ? const Color.fromARGB(255, 87, 177, 60)
            : Colors.grey[300],
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(widget.text, textAlign: TextAlign.center),
    );
  }
}
