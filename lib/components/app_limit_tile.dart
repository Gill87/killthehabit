import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rehabit/services/android_screen_time_service.dart';

class AppLimitTile extends StatefulWidget {
  final String packageName;
  final int limitMinutes;
  final int usedMinutes;
  final VoidCallback onDelete;

  const AppLimitTile({
    super.key,
    required this.packageName,
    required this.limitMinutes,
    required this.onDelete,
    required this.usedMinutes,
  });

  @override
  State<AppLimitTile> createState() => _AppLimitTileState();
}

class _AppLimitTileState extends State<AppLimitTile> {
  
  String _formatLimit(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hrs = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hrs hr${hrs > 1 ? 's' : ''}';
      return '$hrs hr${hrs > 1 ? 's' : ''} $mins min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.limitMinutes > 0
        ? (widget.usedMinutes / widget.limitMinutes).clamp(0.0, 1.0)
        : 0.0;

    return Slidable(
      key: ValueKey(widget.packageName),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    widget.packageName.isNotEmpty
                        ? (AndroidScreenTimeService.getFriendlyAppName(widget.packageName))[0]
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  AndroidScreenTimeService.getFriendlyAppName(widget.packageName), // Replace with friendly app name if needed
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Limit: ${_formatLimit(widget.limitMinutes)}'),
              ),
            ),
            SizedBox(
              width: 100, // fixed width for right side progress bar
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearProgressIndicator(
                    minHeight: 20,
                    borderRadius: BorderRadius.circular(8),
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: progress >= 1.0
                        ? Colors.redAccent
                        : Colors.blueAccent,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.usedMinutes}m / ${widget.limitMinutes}m',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}