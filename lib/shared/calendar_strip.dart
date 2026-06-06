import 'package:flutter/material.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool showCard;
  final bool showArrows; // ✏️

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.showCard = false,
    this.showArrows = false, // ✏️
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late ScrollController _scrollController;
  late DateTime _focusedDate;

  static const activeColor = Color.fromARGB(255, 0, 138, 218);
  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate;
    final today = DateTime.now();
    _days = List.generate(60, (i) => today.subtract(Duration(days: 30 - i)));
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    const itemWidth = 48.0;
    final index = _days.indexWhere(
      (d) =>
          d.year == _focusedDate.year &&
          d.month == _focusedDate.month &&
          d.day == _focusedDate.day,
    );
    if (index != -1) {
      final offset = (index * itemWidth) - 150;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 144).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 144).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _monthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[month - 1];
  }

  Widget _buildStrip() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _days.map((day) {
          final isSelected =
              day.year == widget.selectedDate.year &&
              day.month == widget.selectedDate.month &&
              day.day == widget.selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() => _focusedDate = day);
              widget.onDateSelected(day);
            },
            child: Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    _dayLabels[day.weekday - 1],
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? activeColor : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStripWithArrows() {
    return Row(
      children: [
        // left arrow
        GestureDetector(
          onTap: _scrollLeft,
          child: Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 24),
        ),

        // strip
        Expanded(child: _buildStrip()),

        // right arrow
        GestureDetector(
          onTap: _scrollRight,
          child: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.showArrows ? _buildStripWithArrows() : _buildStrip(); // ✏️

    if (widget.showCard) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_monthName(widget.selectedDate.month)} ${widget.selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              const SizedBox(height: 10),
              content,
            ],
          ),
        ),
      );
    }

    return content;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}