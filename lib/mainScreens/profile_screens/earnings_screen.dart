import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/models/sales.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:delivery_service_riders/widgets/show_floating_toast.dart';
import 'package:delivery_service_riders/widgets/status_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EarningsScreen extends StatefulWidget {
  final String riderID;

  const EarningsScreen({super.key, required this.riderID});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cash Earnings'),
            Tab(text: 'Online Earnings'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesTab(paymentMethod: 'cod'), // Cash Sales
          _buildSalesTab(paymentMethod: 'paymongo'), // Online Sales
        ],
      ),
    );
  }

  Widget _buildSalesTab({required String paymentMethod}) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('riders')
          .doc(widget.riderID)
          .collection('transactions')
          .where('paymentMethod', isEqualTo: paymentMethod)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No transactions found.'));
        }

        // Parse transactions into Sales objects
        final List<Sales> transactions = snapshot.data!.docs
            .map((doc) => Sales.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Group transactions by day of the month
        final Map<int, double> dailyEarnings = {};
        for (final transaction in transactions) {
          final int day = transaction.orderCompleted.toDate().day;
          dailyEarnings[day] = (dailyEarnings[day] ?? 0) + transaction.earnings;
        }

        // Convert daily earnings to chart data
        final List<FlSpot> chartData = dailyEarnings.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              //Sales for the Month of $month
              Text(' ${DateFormat('MMMM').format(transactions[0].orderCompleted.toDate())}', style: const TextStyle(fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Earnings
                  Row(
                    children: [
                      const Text('Earnings: '),
                      transactionStatusWidget(true, calculateTotalEarnings(transactions)),
                    ],
                  ),
                  //Service Fee
                  Row(
                    children: [
                      const Text('Service Fee: '),
                      transactionStatusWidget(false, calculateServiceFeeTotal(transactions)),
                    ],
                  ),
                ],
              ),

              // Chart
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        if (touchResponse != null && touchResponse.lineBarSpots != null) {
                          final spot = touchResponse.lineBarSpots!.first;
                          showFloatingToast(
                            context: context,
                            message: 'Day ${spot.x.toInt()}: ₱${spot.y.toInt()}',
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                          );
                        }
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Day ${spot.x.toInt()}: ₱${spot.y.toInt()}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                          reservedSize: 28,
                          interval: 4, // Show labels every 5 days
                        ),
                        axisNameWidget: const Text(
                          'Days',
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // leftTitles: AxisTitles(
                      //   sideTitles: SideTitles(
                      //     showTitles: true,
                      //     getTitlesWidget: (double value, TitleMeta meta) {
                      //       return Text(
                      //         '₱${value.toInt()}', // Add ₱ sign to the Y-axis labels
                      //         style: const TextStyle(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 12,
                      //         ),
                      //       );
                      //     },
                      //     reservedSize: 70,
                      //     interval: 100,
                      //   ),
                      // ),
                      // leftTitles: AxisTitles(
                      //   sideTitles: SideTitles(
                      //     showTitles: true,
                      //     getTitlesWidget: (double value, TitleMeta meta) {
                      //       return Text(
                      //         '${value.toInt()}',
                      //         style: const TextStyle(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 12,
                      //         ),
                      //       );
                      //     },
                      //     reservedSize: 40,
                      //     interval: 100, // Show labels every 100 Php
                      //   ),
                      //   axisNameWidget: const Text(
                      //     'Sales in Php',
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      // ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black, width: 0),
                    ),
                    minX: 1,
                    maxX: 31,
                    minY: 0,
                    maxY: () {
                      final maxEarnings = dailyEarnings.values.reduce((a, b) => a > b ? a : b);
                      final roundedUp = (maxEarnings / 100).ceil() * 100.0; // Round up to the nearest 100 and ensure it's a double
                      return roundedUp;
                    }(), // Add padding
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],

                  ),
                ),
              ),

              const Divider(
                color: Color.fromARGB(255, 242, 243, 244), // You can customize the color
                height: 25,
                thickness: 1,
                indent: 8,
                endIndent: 8,
              ),

              const Text('Order Transactions ', style: TextStyle(fontWeight: FontWeight.bold),),
              // Transaction List
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(transaction.orderID.toUpperCase(), overflow: TextOverflow.ellipsis,),
                          leading: PhosphorIcon(PhosphorIcons.package()),
                          subtitle: Text(orderDateRead(transaction.orderCompleted.toDate())),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+${transaction.earnings.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '+${transaction.serviceFeeTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(255, 242, 243, 244), // You can customize the color
                          height: 1,
                          thickness: 1,
                          indent: 72,
                          endIndent: 16,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}