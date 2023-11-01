class Transaction {

  String description;
  double amount;
  DateTime timestamp;

  Transaction(this.amount, this.description, this.timestamp);

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      json['amount'],
      json['description'],
      DateTime.parse(json['timestamp']),
    );
  }
}


class Account {
  String name;
  double balance;
  late List<Transaction> transactions;


  Account(this.name, [this.balance=0]) {
    transactions = [];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    final List<dynamic> transactionsJson = json['transactions'];
    final List<Transaction> transactions = transactionsJson.map((json) => Transaction.fromJson(json)).toList();

    return Account(
      json['name'],
      json['balance'],
    )..transactions = transactions;
  }
}

class AccountArgs {
  Function updateHomeScreen;
  Account account;

  AccountArgs(this.account, this.updateHomeScreen);
}

List<Account> accounts = [];