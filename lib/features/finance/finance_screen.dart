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
  List<FlSpot> dataPoints = [];
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
  final String organizerUserId =
      "St290D1fYyZP6XcJZdYeC0e4boY2"; // Replace with actual organizer user ID

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    fetchDataFromFirestore();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchDataFromFirestore() async {
    print('Fetching events for organizer with user_id: $organizerUserId');
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('user_id',
            isEqualTo: organizerUserId) // Fetch events created by the organizer
        .get();

    List<FlSpot> fetchedDataPoints = [];
    Map<int, double> monthlyEarnings =
        {}; // Initialize a map to store monthly earnings

    print('Events fetched: ${eventsSnapshot.docs.length}');
    // Iterate over each event
    for (var eventDoc in eventsSnapshot.docs) {
      var eventData = eventDoc.data() as Map<String, dynamic>;
      double ticketPrice = (eventData['ticket_price'] as num).toDouble();
      DateTime startDate = (eventData['start_date'] as Timestamp).toDate();
      String eventId = eventDoc.id;
      int monthIndex = startDate.month - 1; // Adjusting to 0-based index

      print(
          'Processing event: $eventId, Start date: $startDate, Month index: $monthIndex, Ticket price: $ticketPrice');

      // Fetch participants for the event
      QuerySnapshot participantsSnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('eventId', isEqualTo: eventId)
          .get();

      int participantCount = participantsSnapshot.docs.length;
      double earnings = ticketPrice * participantCount;

      print(
          'Event: $eventId, Participants: $participantCount, Earnings: $earnings');

      // Aggregate earnings by month
      if (monthlyEarnings.containsKey(monthIndex)) {
        // If the month already has earnings, add the new earnings
        monthlyEarnings[monthIndex] = monthlyEarnings[monthIndex]! + earnings;
      } else {
        // If the month doesn't have earnings yet, create a new entry
        monthlyEarnings[monthIndex] = earnings;
      }
    }

    // Convert the monthly earnings map to a list of FlSpot data points
    monthlyEarnings.forEach((monthIndex, earnings) {
      fetchedDataPoints.add(FlSpot(monthIndex.toDouble(), earnings));
      print('Month: $monthIndex, Earnings: $earnings');
    });

    setState(() {
      dataPoints =
          fetchedDataPoints; // Update the state with the fetched data points
      print('Data Points updated: $dataPoints');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Finance Page', style: Theme.of(context).textTheme.headline6),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: dataPoints.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                        'Weekly Sales',
                        _LineChart(
                            isShowingMainData: isShowingMainData,
                            dataPoints: dataPoints,
                            months: months)),
                    _buildPage(
                        'Monthly Sales',
                        _LineChart(
                            isShowingMainData: isShowingMainData,
                            dataPoints: dataPoints,
                            months: months)),
                    _buildPage(
                        'Yearly Sales',
                        _LineChart(
                            isShowingMainData: isShowingMainData,
                            dataPoints: dataPoints,
                            months: months)),
                  ],
                ),
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
}

class _LineChart extends StatelessWidget {
  const _LineChart(
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

    // Debugging prints
    print('Displayed Months: $displayedMonths');
    print('Max Y: $maxY');
    print('Min X: $minX');
    print('Max X: $maxX');
    print('Data Points for Chart: $dataPoints');

    return LineChart(
      isShowingMainData
          ? getChartData(dataPoints, maxY, minX, maxX, displayedMonths)
          : getChartData(dataPoints, maxY, minX, maxX, displayedMonths,
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

  LineChartData getChartData(List<FlSpot> dataPoints, double maxY, double minX,
      double maxX, List<String> displayedMonths,
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
