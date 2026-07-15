import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool showCard;
  final bool showArrows;
  final String uid;
  final String babyId;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.uid,
    required this.babyId,
    this.showCard = false,
    this.showArrows = false,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late ScrollController _scrollController;
  late DateTime _focusedDate;
  bool _expanded = false; // toggles strip vs full month grid
  late DateTime _visibleMonth; // month currently shown when expanded

  static const activeColor = Color(0xFF363434);
  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate;
    _visibleMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    final today = DateTime.now();
    _days = List.generate(60, (i) => today.subtract(Duration(days: 30 - i)));
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _toggleExpanded() {
    // ADDED
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _visibleMonth = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
        );
      }
    });
  }

  void _prevMonth() => setState(
    () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1),
  ); // ADDED
  void _nextMonth() => setState(
    () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1),
  ); // ADDED

  String _fmt(DateTime d) => // ADDED
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ADDED: which days in _visibleMonth have a saved plan, using your {baby_id}_{YYYY-MM-DD} doc ID convention
  Stream<Set<int>> _plannedDaysStream() {
    final start = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final end = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final startId = '${widget.babyId}_${_fmt(start)}';
    final endId = '${widget.babyId}_${_fmt(end)}';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('recommendations')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startId)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => int.tryParse(d.id.split('_').last.split('-').last))
              .whereType<int>()
              .toSet(),
        );
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
      (_scrollController.offset - 144).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 144).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
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
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? activeColor
                          : Colors
                                .grey
                                .shade400, // CHANGED: label now reflects selection too, not just the number circle
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
          child: Icon(
            Icons.chevron_left,
            color: Colors.grey.shade400,
            size: 24,
          ),
        ),

        // strip
        Expanded(child: _buildStrip()),

        // right arrow
        GestureDetector(
          onTap: _scrollRight,
          child: Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
            size: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.showArrows ? _buildStripWithArrows() : _buildStrip();

    if (widget.showCard) {
      return GestureDetector(
        onTap: _toggleExpanded,
        behavior: HitTestBehavior.opaque,
        child: Card(
          color: Color(0xFFFDF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                AnimatedCrossFade(
                  // CHANGED: swaps strip <-> grid instead of always showing `content`
                  firstChild: content,
                  secondChild: _buildMonthGrid(),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return content;
  }

  // ADDED: replaces the old inline header Row.
  // Collapsed: just the current month/year, no icons — the whole card handles the tap now.
  // Expanded: Prev (faded, left) — Current (bold, center) — Next (faded, right), arrows flank both sides.
  Widget _buildHeader() {
    if (!_expanded) {
      return Text(
        '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: activeColor,
        ),
      );
    }

    final prevMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);

    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_left, size: 20, color: activeColor),
          onPressed:
              _prevMonth, // still works independently — IconButton's own tap wins over the outer GestureDetector, same as day cells
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _prevMonth,
                  child: Text(
                    '${_monthName(prevMonth.month)} ${prevMonth.year}',
                    overflow: TextOverflow.ellipsis, // ADDED
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: activeColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: _nextMonth,
                  child: Text(
                    '${_monthName(nextMonth.month)} ${nextMonth.year}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: activeColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_right, size: 20, color: activeColor),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  // ADDED: full month grid — dot marks days with a plan, Sunday dates tinted with your brand accent
  Widget _buildMonthGrid() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstOfMonth.weekday - 1;
    const accent = Color.fromARGB(255, 144, 121, 84);

    return Column(
      children: [
        Row(
          children: _dayLabels
              .map(
                (l) => Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        StreamBuilder<Set<int>>(
          stream: _plannedDaysStream(),
          builder: (context, snapshot) {
            final plannedDays = snapshot.data ?? <int>{};
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: leadingBlanks + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingBlanks) return const SizedBox.shrink();
                final day = index - leadingBlanks + 1;
                final date = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  day,
                );
                final isSelected =
                    date.year == widget.selectedDate.year &&
                    date.month == widget.selectedDate.month &&
                    date.day == widget.selectedDate.day;
                final hasPlan = plannedDays.contains(day);
                final isSunday = date.weekday == DateTime.sunday;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusedDate = date;
                      _expanded =
                          false; // collapses back to the strip after picking, same as tapping a strip day
                    });
                    widget.onDateSelected(date);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToSelected(),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? activeColor : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isSunday ? accent : const Color(0xFF363434)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasPlan && !isSelected
                              ? accent
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
