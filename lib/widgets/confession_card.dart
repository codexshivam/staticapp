import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../models/confession.dart';

class ConfessionCard extends StatelessWidget {
  final Confession confession;
  final bool isHorizontal;
  final VoidCallback? onTap;

  const ConfessionCard({
    super.key,
    required this.confession,
    this.isHorizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pm = PlaybackManager();

    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final isActive = pm.activeConfession?.id == confession.id;
        final isPlaying = isActive && pm.isPlaying;
        final progress = isActive ? pm.progress : 0.0;

        if (isHorizontal) {
          return _buildHorizontalCard(context, isActive, isPlaying, progress, pm);
        } else {
          return _buildVerticalCard(context, isActive, isPlaying, progress, pm);
        }
      },
    );
  }

  Widget _buildHorizontalCard(
    BuildContext context,
    bool isActive,
    bool isPlaying,
    double progress,
    PlaybackManager pm,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: isActive ? AppColors.pureBlack.withOpacity(0.3) : AppColors.divider,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Avatar/Author & play button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confession.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        confession.authorName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => pm.togglePlay(confession),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.pureBlack : AppColors.background,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 16,
                      color: isActive ? AppColors.cardBg : AppColors.pureBlack,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Custom visual Waveform
            _buildWaveform(confession.waveformData, progress, height: 28),
            const SizedBox(height: 10),
            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isActive ? pm.elapsedString : '0:00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  confession.durationString,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    bool isActive,
    bool isPlaying,
    double progress,
    PlaybackManager pm,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: isActive ? AppColors.pureBlack.withOpacity(0.3) : AppColors.divider,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Play Button Block
            GestureDetector(
              onTap: () => pm.togglePlay(confession),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.pureBlack : AppColors.background,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isActive ? AppColors.cardBg : AppColors.pureBlack,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Middle Details Block (waveform, titles)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          confession.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        confession.timestamp,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'by ${confession.authorName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Small waveform
                  _buildWaveform(confession.waveformData, progress, height: 18),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Right Stats/Durations
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isActive ? pm.elapsedString : confession.durationString,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.pureBlack : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Text(
                      '${confession.likesCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Waveform drawing helper
  Widget _buildWaveform(List<double> data, double progress, {required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(data.length, (index) {
          final barProgress = index / data.length;
          final isFilled = barProgress <= progress;
          
          final barHeight = data[index] * height;

          return Expanded(
            child: Container(
              height: barHeight.clamp(2.0, height),
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                color: isFilled 
                    ? AppColors.pureBlack 
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
