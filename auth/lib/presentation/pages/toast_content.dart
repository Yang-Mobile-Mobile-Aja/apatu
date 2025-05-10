import 'package:flutter/material.dart';

class ToastContent extends StatelessWidget {
  const ToastContent({super.key, required this.toastMessage});
  final String toastMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      // margin: const EdgeInsets.symmetric(horizontal: 5),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_rounded,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            toastMessage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
