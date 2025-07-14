import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/players_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/presentation/game/widgets/question_content_display.dart';

class QuestionScreen extends StatefulWidget {
  final QuestionEntity question;
  final int cost;

  const QuestionScreen({super.key, required this.question, required this.cost});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showConfirmAnswerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2233AA),
            title: const Text(
              'Показать ответ?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Вы уверены, что хотите показать ответ?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showAnswer = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Показать'),
              ),
            ],
          ),
    );
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder:
          (context) => BlocBuilder<PlayersBloc, PlayersState>(
            builder: (context, state) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2233AA),
                title: Text(
                  'Изменить счет (вопрос за ${widget.cost})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.gameSession.players.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final player = state.gameSession.players[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Текущие очки: ${player.score}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.read<PlayersBloc>().add(
                                      AddScoreToPlayer(player.id, -widget.cost),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${player.score}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    context.read<PlayersBloc>().add(
                                      AddScoreToPlayer(player.id, widget.cost),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text('Закрыть'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionData = widget.question.questionData;
    if (questionData == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2233AA),
        foregroundColor: Colors.white,
        title: Text(
          'Вопрос за ${widget.cost}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1A6B), // Глубокий синий
              Color(0xFF2233AA), // Насыщенный синий
            ],
          ),
        ),
        child: Column(
          children: [
            // Контент вопроса/ответа
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                child:
                    _showAnswer
                        ? QuestionContentDisplay(data: questionData.answer)
                        : QuestionContentDisplay(data: questionData.question),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          if (state.gameSession.players.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'show_answer_button',
                  onPressed: _showConfirmAnswerDialog,
                  backgroundColor: const Color(0xFF2233AA),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.visibility),
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'show_answer_button',
                onPressed: _showConfirmAnswerDialog,
                backgroundColor: const Color(0xFF2233AA),
                foregroundColor: Colors.white,
                child: const Icon(Icons.visibility),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'players_button',
                onPressed: _showScoreDialog,
                backgroundColor: const Color(0xFF2233AA),
                foregroundColor: Colors.white,
                child: const Icon(Icons.people),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B), // Глубокий синий фон
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e), // Темно-синий AppBar
        foregroundColor: Colors.white,
        title: Text(
          'Вопрос за ${widget.cost}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1A6B), // Глубокий синий
              Color(0xFF2233AA), // Насыщенный синий
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2233AA), // Насыщенный синий
                  Color(0xFF1A2AFF), // Светлее
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0A1A6B), // Темно-синий бордер
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'Вопрос не найден',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Данные вопроса отсутствуют',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
