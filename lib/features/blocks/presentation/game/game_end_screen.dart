import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/players_bloc.dart';
import 'package:smartest_man/features/blocks/presentation/hello_page.dart';
import 'package:smartest_man/features/blocks/presentation/game/players_setup_screen.dart';

class GameEndScreen extends StatelessWidget {
  const GameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A6B),
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
        child: BlocBuilder<PlayersBloc, PlayersState>(
          builder: (context, state) {
            final players = state.gameSession.players;

            // Сортируем игроков по убыванию очков
            final sortedPlayers = List.from(players)
              ..sort((a, b) => b.score.compareTo(a.score));

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Заголовок
                    const Text(
                      'ИГРА ОКОНЧЕНА!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Подзаголовок
                    const Text(
                      'Финальные результаты',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Список игроков
                    Expanded(
                      child: ListView.separated(
                        itemCount: sortedPlayers.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final player = sortedPlayers[index];
                          final isWinner = index == 0;

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors:
                                    isWinner
                                        ? [
                                          Colors.yellow.withValues(alpha: 0.3),
                                          Colors.orange.withValues(alpha: 0.2),
                                        ]
                                        : [
                                          const Color(0xFF2233AA),
                                          const Color(0xFF1A2AFF),
                                        ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isWinner
                                        ? Colors.yellow.withValues(alpha: 0.8)
                                        : const Color(0xFF0A1A6B),
                                width: isWinner ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Место
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        isWinner
                                            ? Colors.yellow.withValues(
                                              alpha: 0.9,
                                            )
                                            : Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isWinner
                                              ? Colors.orange
                                              : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isWinner
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Информация об игроке
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (isWinner) ...[
                                            const Icon(
                                              Icons.emoji_events,
                                              color: Colors.yellow,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Expanded(
                                            child: Text(
                                              player.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isWinner
                                                        ? Colors.yellow
                                                        : Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Очки: ${player.score}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isWinner
                                                  ? Colors.yellow.withValues(
                                                    alpha: 0.8,
                                                  )
                                                  : Colors.white.withValues(
                                                    alpha: 0.8,
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Счет в большом блоке
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isWinner
                                            ? Colors.yellow.withValues(
                                              alpha: 0.9,
                                            )
                                            : Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${player.score}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isWinner
                                              ? Colors.black
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Кнопки
                    Column(
                      children: [
                        // Кнопка новой игры
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Сбрасываем игру
                              context.read<PlayersBloc>().add(ResetGame());

                              // Переходим к настройке игроков
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const PlayersSetupScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Новая игра',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Кнопка возврата в главное меню
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelloPage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'В главное меню',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
