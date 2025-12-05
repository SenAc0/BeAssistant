import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/resources/app_resources.dart';
import 'package:myapp/widgets/indicator.dart';
import 'package:myapp/api_service.dart';

class ReporteGeneral extends StatefulWidget {
  const ReporteGeneral({super.key});

  @override
  State<ReporteGeneral> createState() => _ReporteGeneralState();
}

class _ReporteGeneralState extends State<ReporteGeneral> with WidgetsBindingObserver {

  final ApiService apiService = ApiService();

  Map<String, dynamic>? reportData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchReportData(); 
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchReportData(); // Recargar al volver a la app
    }
  }

  Future<void> fetchReportData() async {
    final data = await apiService.getReportGeneral();
    setState(() {
      reportData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Reporte de Personal'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8C3CE6),
                Color(0xFFA159FF),
              ],
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        color: const Color(0xFFAF79F2),
        onRefresh: fetchReportData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: ReunionesAsistidasCard(
                        cantAsistidas: reportData?['cantidad_asistencias'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReunionesTotalesCard(
                        cantReuniones: reportData?['cantidad_reuniones'] ?? 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                GraficoCard(
                  presente: (reportData?['porcentaje_asistencias'] as num?)?.toDouble() ?? 0.0,
                  ausente: (reportData?['porcentaje_ausencias'] as num?)?.toDouble() ?? 0.0,
                  atrasado: (reportData?['porcentaje_atrasados'] as num?)?.toDouble() ?? 0.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReunionesAsistidasCard extends StatelessWidget {
  final int cantAsistidas;

  const ReunionesAsistidasCard({super.key,required this.cantAsistidas,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
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

                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Reuniones Asistidas',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Text(
                      '$cantAsistidas',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFAF79F2),
                        fontWeight: FontWeight.bold,
                      ),
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

class ReunionesTotalesCard extends StatelessWidget {
  final int cantReuniones;
  const ReunionesTotalesCard({super.key,required this.cantReuniones,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
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
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Reuniones Totales',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Text(
                      '$cantReuniones',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFAF79F2),
                        fontWeight: FontWeight.bold,
                      ),
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
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gráfico de Asistencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 220, 
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
                  color:   Color(0xFFFF9800),
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
              color: Color(0xFFFF9800),
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
