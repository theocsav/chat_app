import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                const Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                const SizedBox(width: 25),
                // Username
                Text(text),
              ],
            ),
          ),
        ),
        // add Divider
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey,
        ),
      ],
    );
  }

}
