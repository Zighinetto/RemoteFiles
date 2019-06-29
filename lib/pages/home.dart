import 'dart:io';
import 'package:flutter/material.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'pages.dart';

class HomePage extends StatefulWidget {
  static TabViewPage favoritesPage = TabViewPage("favorites.json", true);
  static TabViewPage recentlyAddedPage = TabViewPage(
    "recently_added.json",
    false,
  );

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;

  AnimationController _rotationController1;
  AnimationController _rotationController2;
  int _tabIndex = 0;
  bool _tabBarWasAnimated = false;

  _tabOnChange() {
    if (_tabIndex != _tabController.index) {
      if (_tabController.index == 0) {
        _rotationController1.forward(from: .0);
      } else if (_tabController.index == 1) {
        _rotationController2.forward(from: .0);
      }
      setState(() {
        _tabIndex = _tabController.index;
        _tabBarWasAnimated = true;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabOnChange);
    _rotationController1 =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _rotationController2 =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    getApplicationDocumentsDirectory().then((Directory dir) {
      setState(() {
        HomePage.favoritesPage.dir = dir;
        HomePage.recentlyAddedPage.dir = dir;
        HomePage.favoritesPage.jsonFile = File(
          HomePage.favoritesPage.dir.path +
              "/" +
              HomePage.favoritesPage.jsonFileName,
        );
        HomePage.recentlyAddedPage.jsonFile = File(
          HomePage.recentlyAddedPage.dir.path +
              "/" +
              HomePage.recentlyAddedPage.jsonFileName,
        );
        HomePage.favoritesPage.jsonFileExists =
            HomePage.favoritesPage.jsonFile.existsSync();
        HomePage.recentlyAddedPage.jsonFileExists =
            HomePage.recentlyAddedPage.jsonFile.existsSync();
        if (HomePage.favoritesPage.jsonFileExists) {
          HomePage.favoritesPage.connections = [];
          HomePage.favoritesPage.connections
              .addAll(HomePage.favoritesPage.getConnectionsFromJson());
        }
        if (HomePage.recentlyAddedPage.jsonFileExists) {
          HomePage.recentlyAddedPage.connections = [];
          HomePage.recentlyAddedPage.connections
              .addAll(HomePage.recentlyAddedPage.getConnectionsFromJson());
        }
      });
    });
    SettingsVariables.initState();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CustomTheme>(context).setThemeValue(
        await Provider.of<CustomTheme>(context).getThemeValue(),
      );
    });
    return Scaffold(
      key: HomePage.scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 2.8,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(18.0),
          child: TabBar(
            indicator: MD2Indicator(
              indicatorSize: MD2IndicatorSize.normal,
              indicatorHeight: 3.4,
              indicatorColor: Theme.of(context).accentColor,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2.0,
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[600]
                    : Colors.grey[400],
            labelStyle: TextStyle(
              fontFamily: SettingsVariables.accentFont,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: RotationTransition(
                  turns:
                      Tween(begin: .0, end: .2).animate(_rotationController1),
                  child: Icon(Icons.star_border),
                ),
                text: "Favorites",
              ),
              Tab(
                icon: RotationTransition(
                  turns: _tabBarWasAnimated
                      ? Tween(begin: -.5, end: -1.0)
                          .animate(_rotationController2)
                      : Tween(begin: .0, end: -1.0)
                          .animate(_rotationController2),
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.restore),
                  ),
                ),
                text: "Recently added",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: CustomIconButton(
                  icon: Icon(OMIcons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: 1.0,
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                color: Theme.of(context).dividerColor,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(40.0),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 14.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        Provider.of<CustomTheme>(context).isLightTheme()
                            ? "assets/app_icon_black.png"
                            : "assets/app_icon_white.png",
                        width: 24.0,
                      ),
                      SizedBox(width: 7.0),
                      Text(
                        "RemoteFiles",
                        style: TextStyle(
                          fontFamily: SettingsVariables.accentFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  AboutAppDialog(context, packageInfo.version).show();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: StatefulBuilder(builder: (context, setState) {
        return FloatingActionRow(
          heroTag: "fab",
          children: <Widget>[
            FloatingActionRowButton(
              icon: Icon(Icons.flash_on),
              onPressed: () {
                QuickConnectionSheet(
                  context,
                  onFail: () {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text(
                          "Unable to connect",
                        ),
                      ),
                    );
                  },
                ).show();
              },
            ),
            FloatingActionRowDivider(),
            FloatingActionRowButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return EditConnectionPage(isNew: true);
                    },
                  ),
                );
              },
            ),
          ],
        );
      }),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            HomePage.favoritesPage,
            HomePage.recentlyAddedPage,
          ],
        ),
      ),
    );
  }
}
