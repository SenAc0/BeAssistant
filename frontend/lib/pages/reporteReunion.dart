import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/resources/app_resources.dart';
import 'package:myapp/widgets/indicator.dart';


class ReporteReunion extends StatefulWidget {
  const ReporteReunion({super.key});

  @override
  State<ReporteReunion> createState() => _ReporteReunionState();
}

class _ReporteReunionState extends State<ReporteReunion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Reunión'),
        backgroundColor: Color(0xFFAF79F2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            NombreCard(
              fecha: "28/11/2025",
              nombre: "Reunión de Proyecto",
            ),
            SizedBox(height: 16),
            AsistenciasCard(asistenciasTotales: 100),
            SizedBox(height: 16),
            GraficoCard(),
            SizedBox(height: 16),
            TuAsistenciaCard(
              cantAsistidas: 8,
              cantTotal: 25,
              nombre: "Reunión de Proyecto",
            ),

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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      fecha,
                      style: const TextStyle(fontSize: 14),
                    ),

                  ],
                ),
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
                  'Asistencias Totales',
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
  const GraficoCard({super.key});

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
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gráfico de Asistencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            //const SizedBox(height: 12),

            SizedBox(
              height: 230, 
              child: PieChartSample2(
                presente: 10,
                ausente: 65,
                justificado: 25,
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
  final double justificado;

  const PieChartSample2({
    super.key,
    required this.presente,
    required this.ausente,
    required this.justificado,
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
                  color: AppColors.contentColorPurple,
                  text: 'Justificado',
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
            title: '${widget.presente}%',
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
            title: '${widget.ausente}%',
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
            color: AppColors.contentColorPurple,
            value: widget.justificado,
            title: '${widget.justificado}%',
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

class TuAsistenciaCard extends StatelessWidget {
  final int cantAsistidas;
  final int cantTotal;
  final String nombre;

  const TuAsistenciaCard({
    super.key,
    required this.cantAsistidas,
    required this.cantTotal,
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu asistencia: $nombre',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '$cantAsistidas/$cantTotal: Reuniones Asistidas',
                      style: const TextStyle(fontSize: 14),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
