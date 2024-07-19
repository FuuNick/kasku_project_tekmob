import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financial_management_app/db/database_helper.dart';
import 'package:financial_management_app/models/transaction.dart' as fm;
import 'package:financial_management_app/widgets/transaction_tile.dart';
import 'package:financial_management_app/screens/add_income_screen.dart';
import 'package:financial_management_app/screens/add_expense_screen.dart';
import 'package:financial_management_app/decoration/format_rupiah.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// Definisikan Enum di luar kelas _HomeScreenState
enum SortBy { tanggalTerlama, tanggalTerbaru, nominalTerkecil, nominalTerbesar }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<fm.Transaction> transactions = [];
  DateTime selectedDate = DateTime.now();
  String monthName = DateFormat.MMMM().format(DateTime.now());

  SortBy currentSortBy = SortBy.tanggalTerbaru; // Filter default

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  double getTotalAmount(bool isIncome) {
    return transactions
        .where((transaction) =>
            transaction.isIncome == isIncome &&
            transaction.date.month == selectedDate.month &&
            transaction.date.year == selectedDate.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  List<fm.Transaction> _getFilteredTransactions(bool isIncome) {
    List<fm.Transaction> filteredTransactions = transactions
        .where((transaction) =>
            transaction.isIncome == isIncome &&
            transaction.date.month == selectedDate.month &&
            transaction.date.year == selectedDate.year)
        .toList();

    switch (currentSortBy) {
      case SortBy.tanggalTerlama:
        filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortBy.tanggalTerbaru:
        filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.nominalTerkecil:
        filteredTransactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortBy.nominalTerbesar:
        filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    return filteredTransactions;
  }

  void changeSortBy(SortBy sortBy) {
    setState(() {
      currentSortBy = sortBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Financial Management'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.trending_up), text: 'Pemasukkan'),
              Tab(icon: Icon(Icons.trending_down), text: 'Pengeluaran'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildDashboard(),
            buildTransactionList(true),
            buildTransactionList(false),
          ],
        ),
        floatingActionButton: buildSpeedDial(),
      ),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      backgroundColor: Theme.of(context).primaryColor,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.trending_up),
          backgroundColor: Colors.green,
          label: 'Tambah Pemasukkan',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddIncomeScreen()),
            ).then((value) => _fetchTransactions());
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.trending_down),
          backgroundColor: Colors.red,
          label: 'Tambah Pengeluaran',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpenseScreen()),
            ).then((value) => _fetchTransactions());
          },
        ),
      ],
    );
  }

  Widget buildDashboard() {
    double totalIncome = getTotalAmount(true);
    double totalExpense = getTotalAmount(false);
    double balance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              DropdownButton<int>(
                value: selectedDate.month,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(
                      DateFormat.MMMM().format(DateTime(0, index + 1)),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDate =
                          DateTime(selectedDate.year, value, selectedDate.day);
                      monthName = DateFormat.MMMM().format(selectedDate);
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          buildSummaryCard(
              'Pemasukkan Bulan $monthName', totalIncome, Colors.green),
          SizedBox(height: 10),
          buildSummaryCard(
              'Pengeluaran Bulan $monthName', totalExpense, Colors.red),
          SizedBox(height: 10),
          buildSummaryCard('Saldo', balance, Colors.blue),
          SizedBox(height: 20),
          Text(
            'Grafik Keuangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(child: buildChart(totalIncome, totalExpense, balance)),
        ],
      ),
    );
  }

  Widget buildSummaryCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              CurrencyFormat.convertToIdr(amount),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart(double totalIncome, double totalExpense, double balance) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: totalIncome,
            title: 'Pemasukkan',
            color: Colors.green,
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: totalExpense,
            title: 'Pengeluaran',
            color: Colors.red,
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: balance,
            title: 'Saldo',
            color: Colors.blue,
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionList(bool isIncome) {
    final filteredTransactions = _getFilteredTransactions(isIncome);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isIncome ? 'Pemasukkan' : 'Pengeluaran'} Bulan $monthName: ${CurrencyFormat.convertToIdr(getTotalAmount(isIncome))}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButton<SortBy>(
                value: currentSortBy,
                items: [
                  DropdownMenuItem(
                    value: SortBy.tanggalTerlama,
                    child: Text('Terlama'),
                  ),
                  DropdownMenuItem(
                    value: SortBy.tanggalTerbaru,
                    child: Text('Terbaru'),
                  ),
                  DropdownMenuItem(
                    value: SortBy.nominalTerkecil,
                    child: Text('Nominal Terkecil'),
                  ),
                  DropdownMenuItem(
                    value: SortBy.nominalTerbesar,
                    child: Text('Nominal Terbesar'),
                  ),
                ],
                onChanged: (sortBy) {
                  if (sortBy != null) {
                    changeSortBy(sortBy);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return buildTransactionTile(transaction, isIncome);
            },
          ),
        ),
      ],
    );
  }

  Widget buildTransactionTile(fm.Transaction transaction, bool isIncome) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          // Hapus item dari database dan refresh UI
          DatabaseHelper.instance.deleteTransaction(transaction.id!);
          transactions.removeAt(transactions.indexOf(transaction));
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: ListTile(
          leading: Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: isIncome ? Colors.green : Colors.red,
            size: 40,
          ),
          title: Text(
            transaction.description,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy').format(transaction.date),
            style: TextStyle(fontSize: 16),
          ),
          trailing: Text(
            CurrencyFormat.convertToIdr(transaction.amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isIncome
                    ? AddIncomeScreen(transaction: transaction)
                    : AddExpenseScreen(transaction: transaction),
              ),
            ).then((value) => _fetchTransactions());
          },
        ),
      ),
    );
  }
}
