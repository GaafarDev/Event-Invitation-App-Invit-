import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  int _pageIndex = 0;
  late PageController _pageController;
  bool isShowingMainData = true;
  List<FlSpot> yearlyDataPoints = [];
  List<FlSpot> monthlyDataPoints = [];
  List<FlSpot> weeklyDataPoints = [];
  List<Map<String, dynamic>> eventEarnings = [];
  double totalEarnings = 0.0;
  final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  final List<String> weeks = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    fetchOrganizerUserId();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchOrganizerUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String organizerUserId = user.uid;
      print('Logged in user ID: $organizerUserId');
      fetchDataFromFirestore(organizerUserId);
    } else {
      print('No user is currently logged in.');
    }
  }

  Future<void> fetchDataFromFirestore(String organizerUserId) async {
    print('Fetching events for organizer with user_id: $organizerUserId');
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: organizerUserId)
        .get();

    List<FlSpot> fetchedYearlyDataPoints = [];
    List<FlSpot> fetchedMonthlyDataPoints = [];
    List<FlSpot> fetchedWeeklyDataPoints = [];
    Map<int, double> yearlyEarnings = {};
    Map<int, double> monthlyEarnings = {};
    Map<int, double> weeklyEarnings = {};
    List<Map<String, dynamic>> eventEarningsList = [];
    double totalEarningsCalc = 0.0;

    print('Events fetched: ${eventsSnapshot.docs.length}');
    for (var eventDoc in eventsSnapshot.docs) {
      var eventData = eventDoc.data() as Map<String, dynamic>;
      double ticketPrice = (eventData['ticket_price'] as num).toDouble();
      DateTime startDate = (eventData['start_date'] as Timestamp).toDate();
      String eventId = eventDoc.id;
      int monthIndex = startDate.month - 1;
      int weekIndex = ((startDate.day - 1) / 7).floor();
      int yearIndex = startDate.year;

      print(
          'Processing event: $eventId, Start date: $startDate, Month index: $monthIndex, Week index: $weekIndex, Ticket price: $ticketPrice');

      QuerySnapshot participantsSnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('eventId', isEqualTo: eventId)
          .get();

      int participantCount = participantsSnapshot.docs.length;
      double earnings = ticketPrice * participantCount;

      print(
          'Event: $eventId, Participants: $participantCount, Earnings: $earnings');

      eventEarningsList.add({
        'eventName': eventData['name'],
        'earnings': earnings,
        'startDate': startDate,
        'participants': participantCount,
        'ticketPrice': ticketPrice,
      });

      if (yearlyEarnings.containsKey(yearIndex)) {
        yearlyEarnings[yearIndex] = yearlyEarnings[yearIndex]! + earnings;
      } else {
        yearlyEarnings[yearIndex] = earnings;
      }

      if (monthlyEarnings.containsKey(monthIndex)) {
        monthlyEarnings[monthIndex] = monthlyEarnings[monthIndex]! + earnings;
      } else {
        monthlyEarnings[monthIndex] = earnings;
      }

      if (weeklyEarnings.containsKey(weekIndex)) {
        weeklyEarnings[weekIndex] = weeklyEarnings[weekIndex]! + earnings;
      } else {
        weeklyEarnings[weekIndex] = earnings;
      }

      totalEarningsCalc += earnings;
    }

    yearlyEarnings.forEach((yearIndex, earnings) {
      fetchedYearlyDataPoints.add(FlSpot(yearIndex.toDouble(), earnings));
    });

    monthlyEarnings.forEach((monthIndex, earnings) {
      fetchedMonthlyDataPoints.add(FlSpot(monthIndex.toDouble(), earnings));
    });

    weeklyEarnings.forEach((weekIndex, earnings) {
      fetchedWeeklyDataPoints.add(FlSpot(weekIndex.toDouble(), earnings));
    });

    setState(() {
      yearlyDataPoints = fetchedYearlyDataPoints;
      monthlyDataPoints = fetchedMonthlyDataPoints;
      weeklyDataPoints = fetchedWeeklyDataPoints;
      eventEarnings = eventEarningsList;
      totalEarnings = totalEarningsCalc;
      print('Yearly Data Points updated: $yearlyDataPoints');
      print('Monthly Data Points updated: $monthlyDataPoints');
      print('Weekly Data Points updated: $weeklyDataPoints');
      print('Event Earnings updated: $eventEarnings');
      print('Total Earnings updated: $totalEarnings');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Page'),
      ),
      body: (yearlyDataPoints.isEmpty ||
              monthlyDataPoints.isEmpty ||
              weeklyDataPoints.isEmpty)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1.23,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _pageIndex = index;
                          });
                        },
                        children: <Widget>[
                          _buildPage(
                              'Yearly Earning',
                              _YearlyLineChart(
                                  isShowingMainData: isShowingMainData,
                                  dataPoints: yearlyDataPoints)),
                          _buildPage(
                              'Monthly Earning',
                              _MonthlyLineChart(
                                  isShowingMainData: isShowingMainData,
                                  dataPoints: monthlyDataPoints,
                                  months: months)),
                          _buildPage(
                              'Weekly Earning',
                              _WeeklyLineChart(
                                  isShowingMainData: isShowingMainData,
                                  dataPoints: weeklyDataPoints,
                                  weeks: weeks)),
                        ],
                      ),
                    ),
                  ),
                  _buildTotalEarnings(),
                  _buildEventTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildPage(String title, Widget chart) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 37,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 6),
                    child: chart,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
              ),
              onPressed: () {
                setState(() {
                  isShowingMainData = !isShowingMainData;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarnings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Earnings: \RM${totalEarnings.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Event Name')),
              // DataColumn(label: Text('Start Date')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('Ticket Price')),
              DataColumn(label: Text('Participants')),
            ],
            rows: eventEarnings.map((event) {
              return DataRow(cells: [
                DataCell(Text(event['eventName'])),
                // DataCell(Text(DateFormat.yMMMd().format(event['startDate']))),
                DataCell(Text(event['earnings'].toStringAsFixed(2))),
                DataCell(Text(event['ticketPrice'].toStringAsFixed(2))),
                DataCell(Text(event['participants'].toStringAsFixed(0))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _YearlyLineChart extends StatelessWidget {
  const _YearlyLineChart(
      {required this.isShowingMainData, required this.dataPoints});

  final bool isShowingMainData;
  final List<FlSpot> dataPoints;

  @override
  Widget build(BuildContext context) {
    double maxY = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double minX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a > b ? a : b)
        : 0;
    List<int> displayedYears = _getDisplayedYears(minX.toInt(), maxX.toInt());

    return LineChart(
      isShowingMainData
          ? getYearlyChartData(dataPoints, maxY, minX, maxX, displayedYears)
          : getYearlyChartData(dataPoints, maxY, minX, maxX, displayedYears,
              alternative: true),
      duration: const Duration(milliseconds: 250),
    );
  }

  List<int> _getDisplayedYears(int minX, int maxX) {
    List<int> displayedYears = [];
    for (int i = minX; i <= maxX; i++) {
      displayedYears.add(i);
    }
    return displayedYears;
  }

  LineChartData getYearlyChartData(List<FlSpot> dataPoints, double maxY,
      double minX, double maxX, List<int> displayedYears,
      {bool alternative = false}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      ),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index =
                  (value - minX).toInt(); // Adjust index to be 0-based
              if (index < 0 || index >= displayedYears.length)
                return const Text('');
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 10,
                child: Text(displayedYears[index].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              );
            },
            reservedSize: 32,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center);
            },
            reservedSize: 40,
            interval: maxY > 0 ? maxY / 5 : 1,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.blue.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: !alternative,
          color: alternative ? Colors.green.withOpacity(0.5) : Colors.green,
          barWidth: alternative ? 4 : 8,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: dataPoints,
        )
      ],
      minX: minX,
      maxX: maxX, // Updated to match the displayed years length
      maxY: maxY,
      minY: 0,
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  const _MonthlyLineChart(
      {required this.isShowingMainData,
      required this.dataPoints,
      required this.months});

  final bool isShowingMainData;
  final List<FlSpot> dataPoints;
  final List<String> months;

  @override
  Widget build(BuildContext context) {
    double maxY = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double minX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a > b ? a : b)
        : 0;
    List<String> displayedMonths =
        _getDisplayedMonths(minX.toInt(), maxX.toInt());

    return LineChart(
      isShowingMainData
          ? getMonthlyChartData(dataPoints, maxY, minX, maxX, displayedMonths)
          : getMonthlyChartData(dataPoints, maxY, minX, maxX, displayedMonths,
              alternative: true),
      duration: const Duration(milliseconds: 250),
    );
  }

  List<String> _getDisplayedMonths(int minX, int maxX) {
    List<String> displayedMonths = [];
    for (int i = minX; i <= maxX; i++) {
      displayedMonths.add(months[i % 12]);
    }
    return displayedMonths;
  }

  LineChartData getMonthlyChartData(List<FlSpot> dataPoints, double maxY,
      double minX, double maxX, List<String> displayedMonths,
      {bool alternative = false}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      ),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index =
                  (value - minX).toInt(); // Adjust index to be 0-based
              if (index < 0 || index >= displayedMonths.length)
                return const Text('');
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 10,
                child: Text(displayedMonths[index],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              );
            },
            reservedSize: 32,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center);
            },
            reservedSize: 40,
            interval: maxY > 0 ? maxY / 5 : 1,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.blue.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: !alternative,
          color: alternative ? Colors.green.withOpacity(0.5) : Colors.green,
          barWidth: alternative ? 4 : 8,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: dataPoints,
        )
      ],
      minX: minX,
      maxX: maxX, // Updated to match the displayed months length
      maxY: maxY,
      minY: 0,
    );
  }
}

class _WeeklyLineChart extends StatelessWidget {
  const _WeeklyLineChart(
      {required this.isShowingMainData,
      required this.dataPoints,
      required this.weeks});

  final bool isShowingMainData;
  final List<FlSpot> dataPoints;
  final List<String> weeks;

  @override
  Widget build(BuildContext context) {
    double maxY = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double minX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxX = dataPoints.isNotEmpty
        ? dataPoints.map((e) => e.x).reduce((a, b) => a > b ? a : b)
        : 0;
    List<String> displayedWeeks =
        _getDisplayedWeeks(minX.toInt(), maxX.toInt());

    return LineChart(
      isShowingMainData
          ? getWeeklyChartData(dataPoints, maxY, minX, maxX, displayedWeeks)
          : getWeeklyChartData(dataPoints, maxY, minX, maxX, displayedWeeks,
              alternative: true),
      duration: const Duration(milliseconds: 250),
    );
  }

  List<String> _getDisplayedWeeks(int minX, int maxX) {
    List<String> displayedWeeks = [];
    for (int i = minX; i <= maxX; i++) {
      displayedWeeks.add(weeks[i % 5]);
    }
    return displayedWeeks;
  }

  LineChartData getWeeklyChartData(List<FlSpot> dataPoints, double maxY,
      double minX, double maxX, List<String> displayedWeeks,
      {bool alternative = false}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      ),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index =
                  (value - minX).toInt(); // Adjust index to be 0-based
              if (index < 0 || index >= displayedWeeks.length)
                return const Text('');
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 10,
                child: Text(displayedWeeks[index],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              );
            },
            reservedSize: 32,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center);
            },
            reservedSize: 40,
            interval: maxY > 0 ? maxY / 5 : 1,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.blue.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: !alternative,
          color: alternative ? Colors.green.withOpacity(0.5) : Colors.green,
          barWidth: alternative ? 4 : 8,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: dataPoints,
        )
      ],
      minX: minX,
      maxX: maxX, // Updated to match the displayed weeks length
      maxY: maxY,
      minY: 0,
    );
  }
}
