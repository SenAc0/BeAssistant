import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/resources/app_resources.dart';
import 'package:myapp/widgets/indicator.dart';
import 'package:myapp/pages/listaAsistentes.dart';
import 'package:myapp/api_service.dart';
class ReporteReunion extends StatefulWidget {
  final int? meetingId;
  const ReporteReunion({super.key, this.meetingId});

  @override
  State<ReporteReunion> createState() => _ReporteReunionState();
}

class _ReporteReunionState extends State<ReporteReunion> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? reportData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => loading = true);
    if (widget.meetingId == null) {
      setState(() {
        reportData = null;
        loading = false;
      });
      return;
    }
    final data = await apiService.getReportMeeting(widget.meetingId!);
    setState(() {
      reportData = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Reunión'),
        backgroundColor: Color(0xFFAF79F2),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  NombreCard(
                    fecha: reportData?['fecha'] ?? '',
                    nombre: reportData?['nombre_reunion'] ?? '',
                  ),
                  const SizedBox(height: 16),
                  AsistenciasCard(asistenciasTotales: reportData?['invitados_totales'] ?? 0),
                  const SizedBox(height: 16),
                  CantPAACard(
                    presentes: reportData?['asistentes_totales'] ?? 0,
                    ausentes: reportData?['ausentes'] ?? 0,
                    atrasados: reportData?['llegadas_tarde'] ?? 0,
                  ),
                  const SizedBox(height: 16),
                  GraficoCard(
                    presente: (reportData?['porcentaje_asistencias'] as num?)?.toDouble() ?? 0.0,
                    ausente: (reportData?['porcentaje_ausencias'] as num?)?.toDouble() ?? 0.0,
                    atrasado: (reportData?['porcentaje_tarde'] as num?)?.toDouble() ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  ListaAsistentes(meetingId: widget.meetingId),
                ],
              ),
            ),
    );
  }
}


class NombreCard extends StatelessWidget {
  final String fecha;
  final String nombre;

  const NombreCard({
    super.key,
    required this.fecha,
    required this.nombre,
   
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Color(0xFFAF79F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      fecha,
                      style: const TextStyle(fontSize: 14),
                    ),

                  ],
                ),
              ),
      ),
          );
  
  }
}

class AsistenciasCard extends StatelessWidget {
  final int asistenciasTotales;

  const AsistenciasCard({
    super.key,
    required this.asistenciasTotales,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Color(0xFFAF79F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Invitados Totales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$asistenciasTotales',
                style: const TextStyle(
                  fontSize: 50,
                  color: Color(0xFFAF79F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class GraficoCard extends StatelessWidget {
  final double presente;
  final double ausente;
  final double atrasado;

  const GraficoCard({super.key, required this.presente, required this.ausente, required this.atrasado});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shadowColor: Color(0xFFAF79F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            const Text(
              'Gráfico de Asistencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 230, 
              child: PieChartSample2(
                presente: presente,
                ausente: ausente,
                atrasado: atrasado,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  final double presente;
  final double ausente;
  final double atrasado;

  const PieChartSample2({
    super.key,
    required this.presente,
    required this.ausente,
    required this.atrasado,
  });

  @override
  State<PieChartSample2> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Indicator(
                  color: AppColors.contentColorGreen,
                  text: 'Presente',
                  isSquare: true,
                ),
                SizedBox(height: 8),
                Indicator(
                  color: AppColors.contentColorRosado,
                  text: 'Ausente',
                  isSquare: true,
                ),
                SizedBox(height: 8),
                Indicator(
                  color: Color(0xFFFF9800),
                  text: 'Atrasado',
                  isSquare: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.contentColorGreen,
            value: widget.presente,
            title: '${widget.presente.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );

        case 1:
          return PieChartSectionData(
            color: AppColors.contentColorRosado,
            value: widget.ausente,
            title: '${widget.ausente.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );

        case 2:
          return PieChartSectionData(
            color: const Color(0xFFFF9800),
            value: widget.atrasado,
            title: '${widget.atrasado.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );

        default:
          throw StateError('Invalid index');
      }
    });
  }
}

class CantPAACard extends StatelessWidget {
  final int presentes;
  final int ausentes;
  final int atrasados;

  const CantPAACard({
    super.key,
    required this.presentes,
    required this.ausentes,
    required this.atrasados,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildSingleCard(
            'Presentes',
            presentes,
            AppColors.contentColorGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSingleCard(
            'Ausentes',
            ausentes,
            const Color(0xFFFF0967),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSingleCard(
            'Atrasados',
            atrasados,
            const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCard(String label, int value, Color color) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0xFFAF79F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(
                label,
                style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

