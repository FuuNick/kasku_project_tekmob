import 'package:flutter/material.dart';
import 'package:financial_management_app/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Function onDelete;
  final Function onEdit;

  TransactionTile({
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.description),
      subtitle: Text(transaction.date.toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => onEdit(),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onDelete(),
          ),
        ],
      ),
      leading: CircleAvatar(
        child: Text(transaction.amount.toString()),
      ),
    );
  }
}
