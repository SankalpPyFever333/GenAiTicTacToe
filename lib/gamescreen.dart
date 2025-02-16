import 'package:advanced_tic_tac_toe/genai.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GamesGridBorad extends StatefulWidget {
  final TicTacToeAI ai;
  const GamesGridBorad({super.key, required this.ai});

  @override
  State<GamesGridBorad> createState() => _GamesGridBoradState();
}

class _GamesGridBoradState extends State<GamesGridBorad>
    with TickerProviderStateMixin {
  late List<List<String>> gameState;
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isAiResponds = false;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward(); // Start animation
    resetGame();
  }

  void onUserClick(int row, int col) async {
    if (gameState[row][col] != "-" || isAiResponds || gameEnded) return;

    setState(() {
      gameState[row][col] = "X";
      isAiResponds = true;
      playPopSound();
    });

    if (checkWin("X")) {
      showWinAnimation("User Wins! 🎉");
      return;
    }

    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate AI delay

    String currentState = gameState.map((row) => row.join(' ')).join('\n');
    List<int>? aiMove;
    int retryCount = 0;

    do {
      String? aiResponse = await widget.ai.sendGameState(currentState);
      if (aiResponse == null) {
        debugPrint("AI did not respond.");
        setState(() => isAiResponds = false);
        return;
      }

      aiMove = aiResponse
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',')
          .map(int.parse)
          .toList();

      retryCount++;
    } while (retryCount < 5 && (gameState[aiMove[0]][aiMove[1]] != "-"));

    if (aiMove.isNotEmpty && gameState[aiMove[0]][aiMove[1]] == "-") {
      setState(() {
        gameState[aiMove![0]][aiMove[1]] = "O";
        isAiResponds = false;
        playPopSound();
      });

      if (checkWin("O")) {
        showWinAnimation("AI Wins! 🤖");
        return;
      }
    }

    if (!gameState.expand((e) => e).contains("-")) {
      showWinAnimation("It's a Draw! 🤝");
    }
  }

  void resetGame() {
    setState(() {
      gameState = List.generate(3, (_) => List.generate(3, (_) => '-'));
      isAiResponds = false;
      gameEnded = false;
    });
  }

  bool checkWin(String player) {
    for (int i = 0; i < 3; i++) {
      if (gameState[i][0] == player &&
          gameState[i][1] == player &&
          gameState[i][2] == player) return true;
      if (gameState[0][i] == player &&
          gameState[1][i] == player &&
          gameState[2][i] == player) return true;
    }
    return (gameState[0][0] == player &&
            gameState[1][1] == player &&
            gameState[2][2] == player) ||
        (gameState[0][2] == player &&
            gameState[1][1] == player &&
            gameState[2][0] == player);
  }

  Future<void> playPopSound() async {
    await _audioPlayer.play(AssetSource('sounds/pop.wav'));
  }

  void showWinAnimation(String message) {
    setState(() {
      gameEnded = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(
          message,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              resetGame();
              Navigator.pop(context);
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width / 4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animationController,
              child: Text(
                'Tic Tac Toe',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: gridSize,
              height: gridSize,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  int row = index ~/ 3;
                  int col = index % 3;
                  return GestureDetector(
                    onTap: () => !isAiResponds ? onUserClick(row, col) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: gameState[row][col] == 'X'
                            ? Colors.purple.shade100
                            : gameState[row][col] == 'O'
                                ? Colors.blue.shade100
                                : Colors.white,
                        border:
                            Border.all(color: Colors.purple.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Text(
                          gameState[row][col],
                          key: ValueKey(gameState[row][col]),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => resetGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Restart',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
