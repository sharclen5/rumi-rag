import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  final double? progress; // ADDED: null = simulate, 0.0-1.0 = real progress
  final String? message; // ADDED: optional label under the bar

  const Loading({super.key, this.progress, this.message});
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _simController;

  @override 
  void initState() {
    super.initState();
    _simController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..forward();
  }

  @override
  void dispose() {
    _simController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 242, 218, 177),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.progress != null)
                _buildBar(widget.progress!)
              else
                AnimatedBuilder(
                  animation: _simController,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(_simController.value);
                    return _buildBar(0.9 * t);
                  },
                ),
              const SizedBox(height: 16),
              if (widget.message != null)
                Text(
                  widget.message!,
                  style: const TextStyle(
                    color: Color(0xFF363434),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(double value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: const Color(0xFFE8D5B7),
            color: const Color(0xFF363434),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            color: Color(0xFF363434),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
