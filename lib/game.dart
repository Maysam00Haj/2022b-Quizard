import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'providers.dart';
import 'consts.dart';

class Question extends StatelessWidget {
  final String _questionText;
  final int _questionIndex;

  const Question(this._questionText, this._questionIndex, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 400,
        height: 250,
        decoration: const BoxDecoration(
          color: secondaryColor,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Question' ' $_questionIndex\n',
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          Text(
            _questionText,
            style: const TextStyle(fontSize: 28),
            textAlign: TextAlign.center,
          ),
        ]), //Text
        alignment: Alignment.center,
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 18)),
    ]);
  }
}

class Answer extends StatefulWidget {
  const Answer(
      {Key? key, required this.answerText, required this.questionScore})
      : super(key: key);
  final String answerText;
  final int questionScore;

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  Color buttonColor = secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: 400,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: buttonColor),
        child: Text(
          widget.answerText,
          style: const TextStyle(color: defaultColor),
        ),
        onPressed: () async {
          final gameModel = Provider.of<GameModel>(context, listen: false);
          await FirebaseFirestore.instance
              .collection('$strVersion/custom_games')
              .doc(gameModel.pinCode)
              .get()
              .then((game) async {
            int i = gameModel.playerIndex;
            String selectedAnswer = game["player$i"]["selected_answer"];
            if (selectedAnswer == "") {
              setState(() {
                if (widget.questionScore < 10) {
                  buttonColor = redColor;
                } else {
                  buttonColor = greenColor;
                }
              });
              gameModel.setDataToPlayer(
                  "selected_answer", widget.answerText, i);
              await FirebaseFirestore.instance
                  .collection('$strVersion/custom_games')
                  .doc(gameModel.pinCode)
                  .update({"player$i": gameModel.players[i]});
            }
            Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (context) => const Game()));
          });
        },
      ),
    );
  }
}

// Should be the score-board class.
class Result extends StatelessWidget {
  const Result({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Score ' '100',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: ElevatedButton(
                  child: const Text(
                    'Exit Quiz',
                  ),
                  onPressed: () {
                    final gameModel =
                        Provider.of<GameModel>(context, listen: false);
                    gameModel.resetData();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                            builder: (context) => const HomePage()));
                  },
                ),
              )
            ],
          ),
        ));
  }
}

// The second game screen is where we select the right answer (hopefully).
// The list of questions is here only temporarily.
// Almost nothing is fully implemented.

class SecondGameScreen extends StatefulWidget {
  const SecondGameScreen({Key? key}) : super(key: key);

  @override
  State<SecondGameScreen> createState() => _SecondGameScreenState();
}

class _SecondGameScreenState extends State<SecondGameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final game = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);

    Consumer<GameModel> _quizBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        gameModel.quizOptionsUpdate();
        return Column(
          children: gameModel.currentQuizOptions,
        );
      });
    }

    Padding _secondScreenBody() {
      game.get().then((value) {});
      return Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              _quizBody(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 45)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(
                  Icons.timer,
                  size: 40.0,
                ),
                Text(
                  '00:17',
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              ])
            ]), //Scaffold
          ));
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: _secondScreenBody()); //MaterialApp
  }
}

// The first game screen is where we answer a question wrongly.
// Almost nothing is fully implemented.

class FirstGameScreen extends StatefulWidget {
  const FirstGameScreen({Key? key}) : super(key: key);

  @override
  State<FirstGameScreen> createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);

    Future<void> _submitFalseAnswer() async {
      if (gameModel.falseAnswerController.text != "") {
        int i = gameModel.playerIndex;
        String submittedFalseAnswer = gameModel.falseAnswerController.text;
        gameModel.setDataToPlayer("false_answer", submittedFalseAnswer, i);
        await gameRef.update({"player$i": gameModel.players[i]});
        gameModel.enableSubmitFalseAnswer = false;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const Game()));
      }
    }

    Consumer<GameModel> _firstScreenBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(children: <Widget>[
              Question(gameModel.gameQuestions[gameModel.currentQuestionIndex],
                  gameModel.currentQuestionIndex + 1),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: TextFormField(
                      controller: gameModel.falseAnswerController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: secondaryColor,
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                        hintText: 'Enter a false answer...',
                      ))),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 80),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: defaultColor,
                          minimumSize: const Size.fromHeight(50)), // max width
                      child:
                          const Text('Submit', style: TextStyle(fontSize: 18)),
                      onPressed: gameModel.enableSubmitFalseAnswer
                          ? _submitFalseAnswer
                          : null)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 45)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(
                  Icons.timer,
                  size: 40.0,
                ),
                Text(
                  '00:17',
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              ])
            ]));
      });
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(child: _firstScreenBody()));
  }
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    Consumer<GameModel> _bodyBuild() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        final gameRef = FirebaseFirestore.instance
            .collection("$strVersion/custom_games")
            .doc(gameModel.pinCode);
        return StreamBuilder<DocumentSnapshot>(
            stream: gameRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data != null) {
                  gameModel.update(data);
                }
              }

              final falseAnswers = gameModel.getFalseAnswers();
              final selectedAnswers = gameModel.getSelectedAnswers();

              if (!falseAnswers.contains('') && gameModel.currentPhase == 1) {
                gameRef.update({
                  "game_phase": 2,
                });
                gameModel.currentPhase = 2;
                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondGameScreen(),
                    ),
                  ),
                );
              } else if (!selectedAnswers.contains('') &&
                  gameModel.currentPhase == 2) {
                gameModel.resetFalseAnswers();
                gameModel.resetSelectedAnswers();
                for (int i = 0; i < maxPlayers; i++) {
                  gameRef.update({"player$i": gameModel.players[i]});
                }
                gameModel.currentPhase = 1;
                gameModel.currentQuestionIndex++;
                gameRef.update({
                  "game_phase": 1,
                  "question_index": gameModel.currentQuestionIndex
                });
                gameModel.enableSubmitFalseAnswer = true;
                gameModel.falseAnswerController.text = '';
                gameModel.currentQuizOptions = [];
                if (gameModel.currentQuestionIndex < roundsPerGame) {
                  WidgetsBinding.instance?.addPostFrameCallback(
                    (_) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FirstGameScreen(),
                      ),
                    ),
                  );
                } else {
                  WidgetsBinding.instance?.addPostFrameCallback(
                    (_) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Result(),
                      ),
                    ),
                  );
                }
              }

              if (gameModel.currentPhase == 1) {
                String result = "";
                int i = gameModel.playerIndex;
                String falseAnswer = gameModel.players[i]["false_answer"];

                if (falseAnswer != "") {
                  result = "False answer submitted";
                }

                return Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Center(
                          child: Text(
                        result,
                        style: const TextStyle(fontSize: 24),
                      ))),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                        children: [
                          const Text("Waiting for other players...",
                              style: TextStyle(fontSize: 24)),
                          Container(height: 25),
                          const CircularProgressIndicator()
                        ],
                      ))
                ]);
              }

              if (gameModel.currentPhase == 2) {
                var result = Stack(children: const [Text("")]);
                int i = gameModel.playerIndex;
                String selectedAnswer = gameModel.players[i]["selected_answer"];
                int j = gameModel.currentQuestionIndex;
                String correctAnswer = gameModel.gameAnswers[j];
                if (selectedAnswer == correctAnswer) {
                  result = Stack(
                    children: [
                      // The text border
                      Text(
                        'Correct Answer!',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = defaultColor,
                        ),
                      ),
                      // The text inside
                      const Text(
                        'Correct Answer!',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ],
                  );
                } else if (selectedAnswer != "") {
                  result = Stack(
                    children: [
                      // The text border
                      Text(
                        'Wrong Answer',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = defaultColor,
                        ),
                      ),
                      // The text inside
                      const Text(
                        'Wrong Answer',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: redColor,
                        ),
                      ),
                    ],
                  );
                }
                return Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Center(child: result)),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                        children: [
                          const Text("Waiting for other players...",
                              style: TextStyle(fontSize: 24)),
                          Container(height: 25),
                          const CircularProgressIndicator()
                        ],
                      ))
                ]);
              }

              return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 150.0),
                  child: Center(child: CircularProgressIndicator()));
            });
      });
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(child: _bodyBuild()));
  }
}
