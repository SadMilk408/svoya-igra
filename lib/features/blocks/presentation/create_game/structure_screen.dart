import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/structure_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/widgets.dart';

import 'edit_questions/edit_question.dart';
import 'dart:developer';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key, required this.parent});

  final BlocEntity? parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e), // Темно-синий цвет
        foregroundColor: Colors.white,
        title: const Text(
          'Структура игры',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<GameStructureBloc, GameStructureState>(
        listener: (context, state) {
          log('XYI 3 ${state.toString()}');
          if (state is GameStructureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<GameStructureBloc, GameStructureState>(
          builder: (context, state) {
            final tempList = state.getChilds(parent);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      parent?.blockName ?? '',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: BlockList(parent: parent, tempList: tempList),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BlockList extends StatelessWidget {
  const BlockList({super.key, required this.parent, required this.tempList});

  final BlocEntity? parent;
  final List<BlocEntity> tempList;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            getChildsTitle(parent),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child:
              tempList.isEmpty
                  ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Список пуст',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте элементы, используя кнопку ниже',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    itemCount: tempList.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          final nextParent = getNextParent(
                            parent,
                            tempList[index],
                          );

                          if (nextParent != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        StructureScreen(parent: nextParent),
                              ),
                            );
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditQuestion(
                                      tempChild:
                                          tempList[index] as QuestionEntity,
                                    ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    tempList[index].blockName,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    EditButton(
                                      parent: parent,
                                      tempChild: tempList[index],
                                      index: index,
                                    ),
                                    DeleteButton(
                                      parent: parent,
                                      tempChild: tempList[index],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: 20),
        _AddButtonWidget(parent: parent),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.parent,
    required this.tempChild,
    required this.index,
  });

  final BlocEntity? parent;
  final BlocEntity? tempChild;
  final int index;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        BlocEntity? result;

        if (parent is ThemeEntity) {
          final state = context.read<GameStructureBloc>().state;
          final existingQuestions =
              state.gameStructure.questions
                  .where(
                    (q) => q.themeId == parent?.id && q.id != tempChild?.id,
                  )
                  .map((q) => q.cost)
                  .toSet();

          result = await showAddQuestionDialog(
            context,
            parent: parent,
            tempQuestion: tempChild as QuestionEntity,
            isCostUnique: (cost) => !existingQuestions.contains(cost),
          );
        } else {
          final state = context.read<GameStructureBloc>().state;
          final existingNames =
              state
                  .getChilds(parent)
                  .where((e) => e.id != tempChild?.id)
                  .map((e) => e.blockName)
                  .toSet();

          result = await showCustomInputDialog(
            context,
            parent: parent,
            initialText: tempChild?.blockName ?? '',
            isNameUnique: (name) => !existingNames.contains(name),
            tempChild: tempChild,
          );
        }

        if (result != null) {
          final event = chooseEditEvent(
            parent: parent,
            tempChild: tempChild,
            changedChild: result,
            index: index,
          );

          if (event != null && context.mounted) {
            context.read<GameStructureBloc>().add(event);
          }
        }
      },
      icon: Icon(Icons.edit),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.parent,
    required this.tempChild,
  });

  final BlocEntity? parent;
  final BlocEntity tempChild;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final event = chooseRemoveEvent(
          tempParent: parent,
          deletedChild: tempChild,
        );

        if (event != null) {
          context.read<GameStructureBloc>().add(event);
        }
      },
      icon: Icon(Icons.delete),
    );
  }
}

class _AddButtonWidget extends StatelessWidget {
  const _AddButtonWidget({this.parent});
  final BlocEntity? parent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        onPressed: () async {
          BlocEntity? result;

          if (parent is ThemeEntity) {
            final state = context.read<GameStructureBloc>().state;
            final existingQuestions =
                state.gameStructure.questions
                    .where((q) => q.themeId == parent?.id)
                    .map((q) => q.cost)
                    .toSet();

            result = await showAddQuestionDialog(
              context,
              parent: parent,
              isCostUnique: (cost) => !existingQuestions.contains(cost),
            );
          } else {
            final state = context.read<GameStructureBloc>().state;
            final existingNames =
                state.getChilds(parent).map((e) => e.blockName).toSet();

            result = await showCustomInputDialog(
              parent: parent,
              context,
              isNameUnique: (name) => !existingNames.contains(name),
            );
          }

          if (result != null) {
            if (context.mounted) {
              final event = chooseAddedEvent(
                tempParent: parent,
                newChild: result,
              );

              if (event != null) {
                context.read<GameStructureBloc>().add(event);
              }
            }
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 36,
          weight: 800,
        ),
      ),
    );
  }
}
