import 'package:flutter/material.dart';
import 'package:spend_sense/globalData.dart';
import 'package:spend_sense/storageService.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {

  bool isDataLoaded = false;

  final TextEditingController _textController = TextEditingController();

  void _showTextPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Account Name'),
          content: TextFormField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Type something...',
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
                String inputText = _textController.text;
                setState(() {
                  accounts.add(Account(inputText));
                  StorageService.saveAccounts(accounts);
                });
                _textController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void updateHomeScreen() {
    StorageService.saveAccounts(accounts);
    setState(() {

    });
  }

  Future<bool> loadData() async {
    final loadedAccounts = await StorageService.loadAccounts();
    if (loadedAccounts != null) {
      accounts = loadedAccounts;
    }

    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData().then((success) {
      setState(() {
        isDataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    List<AccountCard> accountCards = [];
    if (isDataLoaded) {
      for (int i=0; i<accounts.length; i++) {
        accountCards.add(AccountCard(accounts[i], updateHomeScreen));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
      ),

      floatingActionButton: (isDataLoaded) ? FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
        onPressed: (){

          _showTextPopup(context);
        },

      ) : null,

      body: (isDataLoaded)? ListView(
        children: accountCards,
      ) : Center(child: CircularProgressIndicator(),),

    );
  }
}


class AccountCard extends StatelessWidget {

  Account account;
  Function updateHomeScreen;
  AccountCard(this.account, this.updateHomeScreen, {Key? key}) : super(key: key);

  List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.yellow,
  ];

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Account"),
          content: Container(
              child: Text("Are you sure you want to delete account?")
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('CANCEL'),
            ),

            TextButton(
              onPressed: () {
                accounts.remove(account);
                updateHomeScreen();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/transactions', arguments: AccountArgs(account, updateHomeScreen));
      },

      onLongPress: () {
        _showDeleteDialog(context);
      },

      child: Container(
        height: 130, // Height of the rectangle
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _availableColors[accounts.indexOf(account) % 5],
          borderRadius: BorderRadius.circular(10), // Adjust the radius for rounded corners
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
                account.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      '${account.balance}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: (account.balance >= 0)? Colors.white : Colors.red
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

