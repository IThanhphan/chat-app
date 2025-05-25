import 'package:flutter/material.dart';

class EmojiPickerSheet extends StatelessWidget {
  final bool dark;
  final void Function(String) onSelect;

  const EmojiPickerSheet({
    super.key,
    required this.dark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '😂',
      '🤣',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😍',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😜',
      '😝',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🥳',
      '😏',
      '😒',
      '😞',
      '😔',
      '😢',
      '😭',
      '😤',
      '😠',
      '😡',
      '🤬',
      '😳',
      '🥺',
      '👍',
      '👎',
      '👏',
      '🙌',
      '🙏',
      '💪',
      '👊',
      '✌️',
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '💯',
      '✨',
      '🎉',
      '🎂',
      '🎁',
      '🎈',
      '🎶',
      '💤',
      '👀',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: dark ? Colors.black : Colors.white,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children:
            emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelect(emoji);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              );
            }).toList(),
      ),
    );
  }
}
