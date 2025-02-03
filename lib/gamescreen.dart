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
  // defining board state:
  late List<List<String>> gameState;
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool showText = false;

  bool isAiResponds = false;
  String? aiResponse;

  void onUserClick(int row, int col) async {
    if (gameState[row][col] != "-" || isAiResponds) {
      return;
    }
    setState(() {
      gameState[row][col] = "X";
      playPopSound();
      isAiResponds = true;
    });

    // check win condition after user move and also after AI move:

    if (checkWin("X")) {
      debugPrint("User wins");

      return;
    }

    // converting gameState to String format which will be accepted by the Ai:
    String currentState = gameState.map((row) => row.join(' ')).join('\n');

    // send this state to Ai:
    String? aiResponse;
    List<int> aiMove;

    do {
      aiResponse = await widget.ai.sendGameState(currentState);
      if (aiResponse == null) {
        debugPrint("AI is not responding");
        isAiResponds = false;
        return;
      }
      aiMove = aiResponse
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',')
          .map(int.parse)
          .toList();

      print(aiMove);
    } while (gameState[aiMove[0]][aiMove[1]] != "-");

    setState(() {
      gameState[aiMove[0]][aiMove[1]] = "O";
      playPopSound();
      isAiResponds = false;
    });

    if (checkWin("O")) {
      debugPrint("Ai won");
      return;
    }

    if (!gameState.expand((e) => e).contains("-")) {
      debugPrint("match draw");
      return;
    }

    debugPrint("game is going on");
  }

  void resetGame() {
    setState(() {
      gameState = List.generate(3, (_) => List.generate(3, (_) => '-'));
      isAiResponds = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    resetGame();
  }

  bool checkWin(String player) {
    for (int i = 0; i < 3; i++) {
      if (gameState[i][0] == player &&
          gameState[i][1] == player &&
          gameState[i][2] == player) {
        return true;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (gameState[0][i] == player &&
          gameState[1][i] == player &&
          gameState[2][i] == player) {
        return true;
      }
    }
    if (gameState[0][0] == player &&
        gameState[1][1] == player &&
        gameState[2][2] == player) {
      return true;
    }
    if (gameState[0][2] == player &&
        gameState[1][1] == player &&
        gameState[2][0] == player) {
      return true;
    }

    return false;
  }

  Future<void> playPopSound() async {
    await _audioPlayer.play(AssetSource('sounds/pop.wav')); // Play pop sound
  }

// problems I noticed:
//  1.stop user's move until we get the response from ai.
// 2. send game state to ai again if the move getting which is already made by the user.
// 4. add transitions and animation to text.
// 5. don't allow user click if he had already clicked on the container.

  @override
  Widget build(BuildContext context) {
    double gridSize =
        MediaQuery.of(context).size.width / 4; // Responsive grid size
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Text Transition Animation for "Tic Tac Toe" Title
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value,
                  child: Text(
                    'Tic Tac Toe',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Game Grid
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
                    onTap: () => !isAiResponds
                        ? onUserClick(row, col)
                        : ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Wait , AI is responding"))),
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

            // Add a Reset Button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => resetGame());
              },
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
    super.dispose();
  }
}
