import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/structure_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/players_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/presentation/game/widgets/widgets.dart';
import 'package:smartest_man/features/blocks/presentation/game/game_end_screen.dart';
import 'question_screen.dart';

class GameBoardScreen extends StatefulWidget {
  final RoundEntity? selectedRound;

  const GameBoardScreen({super.key, this.selectedRound});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  RoundEntity? _currentRound;
  final Map<String, QuestionState> _questionStates = {};

  // --- Новое состояние для показа диалога тем ---
  bool _showThemesDialog = false;

  @override
  void initState() {
    super.initState();
    _currentRound = widget.selectedRound;
  }

  void _onRoundSelected(RoundEntity round, List<ThemeEntity> themes) async {
    setState(() {
      _currentRound = round;
      _showThemesDialog = true;
    });
    // Ждём закрытия диалога
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThemesRevealDialog(themes: themes),
    );
    setState(() {
      _showThemesDialog = false;
    });
  }

  void _checkRoundCompletion() {
    final structureState = context.read<GameStructureBloc>().state;

    // Получаем все вопросы текущего раунда
    final themes =
        structureState.gameStructure.themes
            .where((theme) => theme.parentName == _currentRound!.blockName)
            .toList();
    final questions =
        structureState.gameStructure.questions
            .where(
              (question) => themes.any((theme) => theme.id == question.themeId),
            )
            .toList();

    // Проверяем, все ли вопросы выбраны
    final answeredQuestions =
        questions
            .where(
              (question) =>
                  _questionStates[question.id] == QuestionState.selected,
            )
            .length;

    if (answeredQuestions == questions.length) {
      // Раунд завершен, показываем диалог
      _showRoundCompletionDialog();
    }
  }

  void _showRoundCompletionDialog() {
    final structureState = context.read<GameStructureBloc>().state;
    final currentRoundIndex =
        context.read<PlayersBloc>().state.gameSession.currentRoundIndex;
    final nextRoundIndex = currentRoundIndex + 1;

    // Проверяем, есть ли следующий раунд
    final hasNextRound =
        nextRoundIndex < structureState.gameStructure.rounds.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2233AA),
            title: Text(
              hasNextRound ? 'Раунд завершен!' : 'Игра окончена!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              hasNextRound
                  ? 'Все вопросы этого раунда сыграны. Перейти к следующему раунду?'
                  : 'Все раунды завершены! Показать финальные результаты?',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              if (hasNextRound) ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Остаемся в текущем раунде
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text('Остаться'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _goToNextRound(nextRoundIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Следующий раунд'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _goToGameEnd();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Результаты'),
                ),
              ],
            ],
          ),
    );
  }

  void _goToNextRound(int nextRoundIndex) {
    final structureState = context.read<GameStructureBloc>().state;
    final nextRound = structureState.gameStructure.rounds[nextRoundIndex];

    // Обновляем текущий раунд в BLOC
    context.read<PlayersBloc>().add(SetCurrentRound(nextRoundIndex));

    // Очищаем состояния вопросов
    setState(() {
      _questionStates.clear();
      _currentRound = nextRound;
    });

    // Показываем темы нового раунда
    final themes =
        structureState.gameStructure.themes
            .where((theme) => theme.parentName == nextRound.blockName)
            .toList();

    _onRoundSelected(nextRound, themes);
  }

  void _goToGameEnd() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameEndScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameStructureBloc, GameStructureState>(
      builder: (context, structureState) {
        return BlocBuilder<PlayersBloc, PlayersState>(
          builder: (context, playersState) {
            // Если раунд не выбран, выбираем первый раунд из списка
            if (_currentRound == null &&
                structureState.gameStructure.rounds.isNotEmpty) {
              final firstRound = structureState.gameStructure.rounds[0];
              final themes =
                  structureState.gameStructure.themes
                      .where(
                        (theme) => theme.parentName == firstRound.blockName,
                      )
                      .toList();

              // Автоматически выбираем первый раунд
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _onRoundSelected(firstRound, themes);
              });

              return const Scaffold(
                backgroundColor: Color(0xFF0A1A6B),
                body: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (_currentRound == null) {
              return _buildRoundSelector(structureState);
            }

            final themes =
                structureState.gameStructure.themes
                    .where(
                      (theme) => theme.parentName == _currentRound!.blockName,
                    )
                    .toList();
            final questions =
                structureState.gameStructure.questions
                    .where(
                      (question) => themes.any(
                        (theme) => theme.blockName == question.parentName,
                      ),
                    )
                    .toList();

            // Показываем диалог тем, если нужно
            if (_showThemesDialog) {
              // (Диалог уже показан через showDialog, просто возвращаем пустоту)
              return const SizedBox.shrink();
            }

            return _buildGameBoard(themes, questions);
          },
        );
      },
    );
  }

  Widget _buildRoundSelector(GameStructureState state) {
    final rounds = state.gameStructure.rounds;
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите раунд',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ...rounds.map(
                (round) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      // Получаем темы для выбранного раунда
                      final themes =
                          BlocProvider.of<GameStructureBloc>(context)
                              .state
                              .gameStructure
                              .themes
                              .where(
                                (theme) => theme.parentName == round.blockName,
                              )
                              .toList();
                      _onRoundSelected(round, themes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      round.blockName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard(
    List<ThemeEntity> themes,
    List<QuestionEntity> questions,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B),
      body: GameBoardGrid(
        themes: themes,
        questions: questions,
        questionStates: _questionStates,
        onQuestionTap: (question) => _onQuestionTap(question, questions),
      ),
    );
  }

  void _onQuestionTap(
    QuestionEntity question,
    List<QuestionEntity> allQuestions,
  ) {
    // Используем ID вопроса как уникальный ключ
    final questionKey = question.id;

    // Используем стоимость из модели вопроса
    final cost = question.cost;

    // Переходим на страницу вопроса
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(question: question, cost: cost),
      ),
    ).then((_) {
      // После возврата с страницы вопроса устанавливаем состояние как выбранный
      setState(() {
        _questionStates[questionKey] = QuestionState.selected;
      });

      // Проверяем завершение раунда
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkRoundCompletion();
      });
    });
  }
}

// --- Диалог анимированного показа тем ---
class ThemesRevealDialog extends StatefulWidget {
  final List<ThemeEntity> themes;
  const ThemesRevealDialog({super.key, required this.themes});

  @override
  State<ThemesRevealDialog> createState() => _ThemesRevealDialogState();
}

class _ThemesRevealDialogState extends State<ThemesRevealDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextTheme() {
    if (_currentIndex < widget.themes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeTextStyle = const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [
        Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
      ],
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B), // Глубокий синий фон как в игре
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _nextTheme,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.themes.length,
            itemBuilder: (context, index) {
              return Center(
                child: Container(
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
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.themes[index].blockName,
                    style: themeTextStyle,
                    textAlign: TextAlign.center,
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
