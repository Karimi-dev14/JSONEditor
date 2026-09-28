import 'package:flutter/material.dart';

class CustomBoolSelector extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomBoolSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 100, 
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: value ? Colors.amberAccent : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'true',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: value ? Colors.black : Colors.white60,
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.white24),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: !value ? Colors.redAccent.shade200 : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'false',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: !value ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}