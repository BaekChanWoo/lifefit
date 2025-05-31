import 'package:flutter/material.dart';

class StepProgressBar extends StatefulWidget {
  final int currentSteps;
  final int goalSteps;

  const StepProgressBar({
    Key? key,
    required this.currentSteps,
    this.goalSteps = 10000,
  }) : super(key: key);

  @override
  State<StepProgressBar> createState() => _StepProgressBarState();
}

class _StepProgressBarState extends State<StepProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get isGoalReached => widget.currentSteps >= widget.goalSteps;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (isGoalReached) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant StepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    //목표 달성 애니메이션
    if (!oldWidget.currentSteps.isNaN &&
        oldWidget.currentSteps < widget.goalSteps &&
        isGoalReached) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (widget.currentSteps / widget.goalSteps).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        //걸음 수 진행도 막대
        LinearProgressIndicator(
          value: progress,
          minHeight: 17,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
          borderRadius: BorderRadius.circular(4.5),
        ),

        const SizedBox(height: 7),

        //목표 달성 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.currentSteps} / ${widget.goalSteps} 걸음',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),

            if (isGoalReached)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Row(
                  children: const [
                    Icon(Icons.local_fire_department,
                        color: Colors.redAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '목표 달성!',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
