import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';

class FieldBlockName extends StatelessWidget {
  const FieldBlockName({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Название:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        ),
        SizedBox(width: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CustomTextField(hintText: 'Введите название пака'),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.initialText,
    this.hintText,
    this.onEdit,
    this.onRemove,
  });

  final String? initialText;
  final String? hintText;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 24.0, color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 24.0, color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: _buildSuffixIcons(context),
      ),
    );
  }

  Widget? _buildSuffixIcons(BuildContext context) {
    final List<Widget> icons = [];

    if (onEdit != null) {
      icons.add(
        IconButton(
          icon: const Icon(Icons.edit, size: 40, color: Colors.white),
          onPressed: onEdit,
        ),
      );
    }

    if (onRemove != null) {
      icons.add(
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 40, color: Colors.white),
          onPressed: onRemove,
        ),
      );
    }

    if (icons.isEmpty) return null;

    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }
}

String _generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString() +
      (1000 + (DateTime.now().microsecond % 9000)).toString();
}

Future<BlocEntity?> showCustomInputDialog(
  BuildContext context, {
  required BlocEntity? parent,
  String title = "Введите текст",
  String hintText = "Текст",
  String initialText = "",
  bool Function(String name)? isNameUnique,
  BlocEntity? tempChild,
}) {
  final textController = TextEditingController(text: initialText);
  final formKey = GlobalKey<FormState>();

  return showDialog<BlocEntity>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            cursorColor: Colors.white,
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 16.0, color: Colors.white30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Поле не может быть пустым";
              }
              if (isNameUnique != null && !isNameUnique(value)) {
                if (parent is PackEntity) {
                  return "Раунд с таким названием уже существует";
                } else if (parent is RoundEntity) {
                  return "Тема с таким названием уже существует в этом раунде";
                }
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: Navigator.of(context).pop,
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (parent is RoundEntity) {
                  // Если tempChild есть и это ThemeEntity, сохраняем старый id
                  final String themeId =
                      (tempChild is ThemeEntity) ? tempChild.id : _generateId();
                  Navigator.of(context).pop(
                    ThemeEntity(
                      id: themeId,
                      blockName: textController.text,
                      parentName: parent.blockName,
                    ),
                  );
                } else {
                  final String entityId = tempChild?.id ?? _generateId();
                  Navigator.of(context).pop(
                    BlocEntity(
                      id: entityId,
                      blockName: textController.text,
                      parentName: parent?.blockName ?? '',
                    ),
                  );
                }
              }
            },
            child: const Text("ОК"),
          ),
        ],
      );
    },
  );
}

Future<QuestionEntity?> showAddQuestionDialog(
  BuildContext context, {
  required BlocEntity? parent,
  QuestionEntity? tempQuestion,
  bool Function(int cost)? isCostUnique,
}) async {
  final formKey = GlobalKey<FormState>();
  final costController = TextEditingController(
    text: '${tempQuestion?.cost ?? ''}',
  );

  return await showDialog<QuestionEntity>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Введите вопрос"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              TextFormField(
                controller: costController,
                keyboardType: TextInputType.number,
                cursorColor: Colors.white,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Стоимость",
                  labelStyle: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white70,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите стоимость";
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return "Введите корректное число > 0";
                  }
                  if (isCostUnique != null && !isCostUnique(number)) {
                    return "Вопрос с такой стоимостью уже существует в этой теме";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: Navigator.of(context).pop,
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final cost = int.parse(costController.text.trim());

                final newQuestion = QuestionEntity(
                  id: _generateId(),
                  cost: cost,
                  blockName: '$cost',
                  parentName: parent?.blockName ?? '',
                  themeId: parent?.id ?? '',
                );

                Navigator.of(context).pop(newQuestion);
              }
            },
            child: const Text("ОК"),
          ),
        ],
      );
    },
  );
}
