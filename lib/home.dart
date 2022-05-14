import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizard/profile.dart';

import 'consts.dart';
import 'providers.dart';

class QuizardAppBar extends StatelessWidget with PreferredSizeWidget {
  QuizardAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.language,
                        color: defaultColor,
                        size: appbarIconSize,
                      ),
                      onTap: null, // TODO: Go to Change Language screen
                    ),
                    InkWell(
                      child: Icon(
                        Icons.info_outline,
                        color: defaultColor,
                        size: appbarIconSize,
                      ),
                      onTap: null, // TODO: Go to Rules screen
                    )
                  ],
                ))));
  }

  @override
  Size get preferredSize => const Size(0, appbarSize);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final profileScreen = Profile();
  final playScreen = const Play();
  final leaderboardScreen = const Leaderboard();

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Hide navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    void _onOptionTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    Widget _chooseWidget() {
      if (_currentIndex == 1) {
        return playScreen;
      }
      if (_currentIndex == 2) {
        return leaderboardScreen;
      }
      return profileScreen;
    }

    return Scaffold(
        appBar: QuizardAppBar(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gamepad),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.crown),
              label: 'Leaderboard',
            ),
          ],
          currentIndex: _currentIndex,
          backgroundColor: defaultColor,
          selectedItemColor: backgroundColor,
          unselectedItemColor: secondaryColor,
          onTap: _onOptionTapped,
        ),
        body: _chooseWidget());
  }
}

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  @override
  Widget build(BuildContext context) {
    InkWell _playOptionButton(String imgPath) {
      return InkWell(
        splashColor: defaultColor,
        onTap: () {}, // TODO: Support games!
        child: Padding(
            padding: const EdgeInsets.all(7),
            child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: playOptionColor,
                  boxShadow: const [
                    BoxShadow(color: defaultColor, spreadRadius: 2),
                  ],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image(image: AssetImage(imgPath))))),
      );
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Image(image: AssetImage('images/titles/quizard.png')),
              Text(
                'Good luck, ${loginModel.username}!',
                style: const TextStyle(fontSize: 18),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/quick_play.png'),
                      _playOptionButton('images/titles/create_public.png'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/join_existing.png'),
                      _playOptionButton('images/titles/create_private.png'),
                    ],
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: secondaryColor,
                        minimumSize: const Size.fromHeight(50)), // max width
                    child: const Text('Log out',
                        style: TextStyle(color: defaultColor)),
                    onPressed: () {
                      AuthModel.instance().signOut().then((value) {
                        loginModel.logOut();
                        // Hide StatusBar, Show navigation buttons
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                            overlays: [SystemUiOverlay.bottom]);
                        Navigator.of(context).pop();
                      });
                    },
                  )),
              Container()
            ]),
      );
    });
  }
}

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 114;

    return Container(
        color: secondaryBackgroundColor,
        height: screenHeight,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              child: const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                      child: Text(
                    "Coming soon.",
                    style: TextStyle(fontSize: 24, color: defaultColor),
                  ))),
              decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(boxRadiusConst))))
        ]));
  }
}
