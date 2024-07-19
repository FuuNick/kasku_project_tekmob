import 'package:flutter/material.dart';
import 'package:financial_management_app/models/transaction.dart';
import 'package:financial_management_app/db/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:financial_management_app/decoration/format_rupiah.dart'; // Mengimpor CurrencyFormat

class AddIncomeScreen extends StatelessWidget {
  final Transaction? transaction;

  AddIncomeScreen({this.transaction});

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (transaction != null) {
      _descriptionController.text = transaction!.description;
      _amountController.text = transaction!.amount.toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(transaction!.date);
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(transaction == null ? 'Tambah Pemasukkan' : 'Edit Pemasukkan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan keterangan';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Uang',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah uang';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan jumlah uang yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan tanggal';
                  }
                  if (DateTime.tryParse(value) == null) {
                    return 'Masukkan tanggal yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newTransaction = Transaction(
                      id: transaction?.id,
                      description: _descriptionController.text,
                      amount: double.parse(_amountController.text),
                      date: DateTime.parse(_dateController.text),
                      isIncome: true,
                    );
                    if (transaction == null) {
                      DatabaseHelper.instance.insertTransaction(newTransaction);
                    } else {
                      DatabaseHelper.instance.updateTransaction(newTransaction);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(transaction == null ? 'Tambah' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
