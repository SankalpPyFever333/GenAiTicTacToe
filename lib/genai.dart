import 'package:google_generative_ai/google_generative_ai.dart';

class TicTacToeAI {
  late GenerativeModel model;
  late ChatSession chat;

  TicTacToeAI(String apiKey) {
    model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system(
          '1. It is tic tac toe game of 3X3 grid.\n2. You will tell me only the pair of indices which represent the box where you want to put your response.\n3. Grid have zero-based indexing.'),
    );

    chat = model.startChat(history: [
      Content.multi([
        TextPart('X - -\n- - -\n- - -'),
      ]),
      Content.model([
        TextPart('(1, 1)\n'),
      ]),
      Content.multi([
        TextPart('X X -\n- O -\n- - -'),
      ]),
      Content.model([
        TextPart('(0, 2)\n'),
      ]),
      Content.multi([
        TextPart('X X O\n- O -\nX - -'),
      ]),
      Content.model([
        TextPart('(2, 1)\n'),
      ]),
    ]); // we are not providing the history bcoz I am providing the complete board state , so AI doesn't require history for making his next move
  }

  // send your current game state to Ai:

  Future<String?> sendGameState(String gameState) async {
    final content = Content.text(gameState);
    final response = await chat.sendMessage(content);
    return response.text;
  }
}
