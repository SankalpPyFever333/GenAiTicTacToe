import 'package:advanced_tic_tac_toe/genai.dart';
import 'package:flutter/material.dart';

class GamesGridBorad extends StatefulWidget {
  final TicTacToeAI ai;
  const GamesGridBorad({super.key, required this.ai});

  @override
  State<GamesGridBorad> createState() => _GamesGridBoradState();
}

class _GamesGridBoradState extends State<GamesGridBorad> {
  // defining board state:
  List<List<String>> gameState = [
    [
      '-',
      '-',
      '-',
    ],
    [
      '-',
      '-',
      '-',
    ],
    [
      '-',
      '-',
      '-',
    ]
  ];

  bool showText = false;
  List<bool> isVisible = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  void onUserClick(int row, int col) async {
    if (gameState[row][col] == "-") {
      setState(() {
        gameState[row][col] = "X";
      });
    }

    // converting gameState to String format which will be accepted by the Ai:
    String currentState = gameState.map((row) => row.join(' ')).join('\n');

    // send this state to Ai:
    String? aiResponse = await widget.ai.sendGameState(currentState);

    if (aiResponse != null) {
      final aiMove = aiResponse
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',')
          .map(int.parse)
          .toList();

      // update the board state with AI move:
      setState(() {
        gameState[aiMove[0]][aiMove[1]] = "O";
      });
    } else {
      print("AI Response is null");
    }
  }

// problems I noticed:
//  1.stop user's move until we get the response from ai.
// 2. send game state to ai again if the move getting which is already made by the user.
// 3. apply win condition.
// 4. add transitions and animation to text.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 4, // Dynamically set width
          height: MediaQuery.of(context).size.width / 4,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: 9,
            itemBuilder: (context, index) {
              int row = index ~/ 3;
              int col = index % 3;
              return GestureDetector(
                onTap: () => onUserClick(row, col),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.shade700, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    gameState[row][col],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
