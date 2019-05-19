import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'connection.dart';
import 'main.dart';

class EditConnectionPage extends StatefulWidget {
  EditConnectionPage(int favoritesIndex) {
    _EditConnectionPageState._textEditingController.forEach((k, v) {
      _EditConnectionPageState._textEditingController[k].text = FavoritesPage.connections[favoritesIndex].toMap()[k];
    });
    _EditConnectionPageState._favoritesIndex = favoritesIndex;
    _EditConnectionPageState._connection = FavoritesPage.connections[favoritesIndex];
  }
  @override
  _EditConnectionPageState createState() => _EditConnectionPageState();
}

class _EditConnectionPageState extends State<EditConnectionPage> {
  static Map<String, TextEditingController> _textEditingController = {
    "name": TextEditingController(),
    "address": TextEditingController(),
    "port": TextEditingController(),
    "username": TextEditingController(),
    "passwordOrKey": TextEditingController(),
    "path": TextEditingController()
  };
  static int _favoritesIndex;

  static Connection _connection = Connection();

  bool _addressIsEntered = true;
  bool _passwordWasChanged = false;

  List<FocusNode> focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode()];

  Container _buildTextField({String label, String hint, String valueText, bool isPassword = false, FocusNode focusNode, int index}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: TextField(
        focusNode: focusNodes[index],
        controller: _textEditingController[valueText],
        cursorColor: Theme.of(context).accentColor,
        obscureText: isPassword,
        textInputAction: label == "Path" ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          suffixIcon: valueText == "passwordOrKey" && !_passwordWasChanged && _textEditingController[valueText].text != ""
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _textEditingController[valueText].text = "";
                    _connection.setter(valueText, "");
                    setState(() => _passwordWasChanged = true);
                  },
                )
              : null,
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
          labelText: label,
          hintText: hint,
          errorText: !_addressIsEntered && label == "Address*" ? "Please enter an address" : null,
        ),
        onChanged: (String value) {
          _connection.setter(valueText, value);
          if (valueText == "passwordOrKey") {
            setState(() => _passwordWasChanged = true);
          }
        },
        onSubmitted: (String value) {
          if (index < focusNodes.length - 1) FocusScope.of(context).requestFocus(focusNodes[index + 1]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        elevation: 8.0,
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                "Edit SFTP connection",
                style: TextStyle(fontFamily: "GoogleSans", fontSize: 17.0, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        elevation: 4.0,
        child: Icon(Icons.done),
        onPressed: () {
          if (_connection.address != null && _connection.address != "") {
            FavoritesPage.connections[_favoritesIndex] = _connection;
            MyHomePage.addToJson(_connection, true);
            Navigator.pop(context);
          } else {
            setState(() {
              _addressIsEntered = false;
            });
          }
        },
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    _buildTextField(label: "Name", valueText: "name", index: 0),
                    _buildTextField(label: "Address*", valueText: "address", index: 1),
                    _buildTextField(label: "Port", hint: "22", valueText: "port", index: 2),
                    _buildTextField(label: "Username", valueText: "username", index: 3),
                    _buildTextField(label: "Password or Key", valueText: "passwordOrKey", isPassword: true, index: 4),
                    _buildTextField(label: "Path", valueText: "path", index: 5),
                  ],
                ),
              ),
              SizedBox(
                height: 60.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
