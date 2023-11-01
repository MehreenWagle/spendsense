import 'package:flutter/material.dart';
import 'package:spend_sense/globalData.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {


  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as AccountArgs;

    Account account = args.account;
    Function updateHomeScreen = args.updateHomeScreen;

    final _key = GlobalKey<ExpandableFabState>();

    final TextEditingController _textAmountController = TextEditingController();
    final TextEditingController _textDescriptoinController = TextEditingController();

    void _showTextPopup(BuildContext context, [bool credit = true]) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(credit? "Credit Amount" : "Debit Amount"),
            content: Container(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Enter amount"),
                  TextFormField(
                    controller: _textAmountController,
                    decoration: InputDecoration(
                      hintText: '00.00',
                    ),
                  ),
                  Text("Description"),
                  TextFormField(
                    controller: _textDescriptoinController,
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Use the input text from _textController
                  double amount = double.parse(_textAmountController.text);

                  if (!credit) amount = - amount;

                  String description = _textDescriptoinController.text;
                  DateTime timestamp = DateTime.now();

                  setState(() {
                    account.transactions.insert(0,Transaction(amount, description, timestamp));
                    account.balance += amount;
                  });

                  updateHomeScreen();

                  _textAmountController.clear();
                  _textDescriptoinController.clear();

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    List<Widget> transactionCards = [];
    DateTime curday = DateTime.now();

    if (account.transactions.length != 0) {
      curday = account.transactions[0].timestamp;

      transactionCards.add(ListTile(
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${weekDay[curday.weekday]} - ${curday.day} / ${curday.month} / ${curday.year}'),
            ],
          )
      ));

      transactionCards.add(TransactionCard(account.transactions[0]));
    }

    for(int i=1; i<account.transactions.length; i++) {
      if (account.transactions[i].timestamp.day != curday.day) {
        curday = account.transactions[i].timestamp;
        transactionCards.add(ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${weekDay[curday.weekday]} - ${curday.day} / ${curday.month} / ${curday.year}'),
              ],
            )
        ));
      }
      transactionCards.add(TransactionCard(account.transactions[i]));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          Center(child:
            Text(
              '${account.balance}       ',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold
              ),
            )
          )
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,

        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.playlist_add_rounded),
          fabSize: ExpandableFabSize.regular,
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
        ),

        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
        ),

        type: ExpandableFabType.up,


        overlayStyle: ExpandableFabOverlayStyle(
          blur: 5,
        ),
        children: [

          FloatingActionButton.extended(
            // shape: const CircleBorder(),
            heroTag: "Debit",
            backgroundColor: Colors.black,
            foregroundColor: Colors.red,
            label: const Text(
              "Debit ",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            icon: const Icon(Icons.remove),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              _showTextPopup(context, false);
            },
          ),

          FloatingActionButton.extended(
            // shape: const CircleBorder(),
            heroTag: "Credit",
            backgroundColor: Colors.black,
            foregroundColor: Colors.green,
            label: const Text(
                "Credit",
              style: TextStyle(
                color: Colors.white
              ),
            ),
            icon: const Icon(Icons.add),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              _showTextPopup(context, true);
            },
          ),

        ],
      ),

      body: ListView(
        children: transactionCards,
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {

  Transaction transaction;
  TransactionCard(this.transaction, {Key? key}) : super(key: key);

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Transaction Details"),
            content: Container(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Amount: ${transaction.amount}\n"),
                    Text("Date: ${transaction.timestamp.toString()}\n"),
                    Text("Description"),
                    Text(transaction.description)
                  ],
                )
            ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    double amt = 0;
    if (transaction.amount >= 0) {
      amt = transaction.amount;
    } else {
      amt = - transaction.amount;
    }

    return InkWell(
      onTap: (){
        _showDetails(context);
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(10.0),
        height: 60.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), // Adjust the radius for rounded corners
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey, // Color of the shadow
              offset: Offset(0, 1), // Offset of the shadow
              blurRadius: 2, // Spread of the shadow
            ),
          ],
        ),

        child: Row(
          children: [
            Text(
              '${amt}',
              style: TextStyle(
                color: (transaction.amount >=0)? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16.0
              ),
            )
          ],
        ),
      ),
    );
  }
}

