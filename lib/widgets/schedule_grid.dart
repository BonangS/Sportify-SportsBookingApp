import 'package:flutter/material.dart';
import 'package:Sportify/utils/app_colors.dart';

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({super.key});

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  // Set untuk menyimpan jam yang dipilih
  final Set<int> _selectedSlots = {};
  // Dummy data untuk jam yang sudah di-booking
  final Set<int> _bookedSlots = {11, 12, 17};

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 16, // dari jam 08:00 sampai 23:00
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final hour = 8 + index;
        final isBooked = _bookedSlots.contains(hour);
        final isSelected = _selectedSlots.contains(hour);

        return GestureDetector(
          onTap:
              isBooked
                  ? null // Tidak bisa di-tap jika sudah dibooking
                  : () {
                    setState(() {
                      if (isSelected) {
                        _selectedSlots.remove(hour);
                      } else {
                        _selectedSlots.add(hour);
                      }
                    });
                  },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary
                      : isBooked
                      ? AppColors.bookedSlot
                      : AppColors.availableSlot,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                '$hour:00',
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : isBooked
                          ? Colors.grey.shade600
                          : AppColors.primary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
