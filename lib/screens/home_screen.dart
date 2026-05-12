import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../mock_data/sample_data.dart';
import 'confession_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, dynamic confession) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ConfessionDetailScreen(confession: confession),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = const Offset(0.0, 0.05);
          final end = Offset.zero;
          final curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = PlaybackManager();
    // Default active confession to first item if none selected
    final activeConf = pm.activeConfession ?? SampleData.mockConfessions[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Confessions',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.pureBlack,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.pureBlack, size: 20),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: Currently Playing Active Player
            _buildActivePlayer(context, pm, activeConf),
            
            const SizedBox(height: 24),

            // SECTION 2: Confessions in 24 Hours ❤️ (Horizontal Scroll)
            const SectionTitle(
              title: 'Confessions in 24 Hours ❤️',
              subtitle: 'whispers recorded since sunset...',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: SampleData.last24HoursConfessions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final conf = SampleData.last24HoursConfessions[index];
                  return ConfessionCard(
                    confession: conf,
                    isHorizontal: true,
                    onTap: () => _openDetail(context, conf),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // SECTION 3: From People You Follow ❤️ (Vertical List)
            const SectionTitle(
              title: 'From People You Follow ❤️',
              subtitle: 'pages from diaries you hold close',
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: SampleData.followingConfessions.length,
              itemBuilder: (context, index) {
                final conf = SampleData.followingConfessions[index];
                return ConfessionCard(
                  confession: conf,
                  isHorizontal: false,
                  onTap: () => _openDetail(context, conf),
                );
              },
            ),

            const SizedBox(height: 36),

            // SECTION 4: Centered Footer Text
            Center(
              child: Column(
                children: [
                  Text(
                    'We love Confessions ❤️',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'thank you for protecting these secrets.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active Top Player Card
  Widget _buildActivePlayer(BuildContext context, PlaybackManager pm, dynamic defaultConf) {
    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final conf = pm.activeConfession ?? defaultConf;
        final isPlaying = pm.isPlaying;
        final progress = pm.progress;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.pureBlack,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isPlaying ? AppColors.accentRed : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPlaying ? 'listening late night...' : 'last heard story',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.background.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _openDetail(context, conf),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'OPEN ROOM ❤️',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Confession Title & Author
              Text(
                conf.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'by ${conf.authorName} • ${conf.authorHandle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.background.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 16),
              
              // Waveform Indicator (dynamic fills if playing)
              _buildWaveform(conf.waveformData, progress, isPlaying),
              const SizedBox(height: 12),

              // Player timeline controls
              Row(
                children: [
                  GestureDetector(
                    onTap: () => pm.togglePlay(conf),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.pureBlack,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Seek/Timeline bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2.0),
                          child: SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pm.activeConfession?.id == conf.id ? pm.elapsedString : '0:00',
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              conf.durationString,
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Waveform drawing
  Widget _buildWaveform(List<double> data, double progress, bool isPlaying) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(data.length, (index) {
          final barProgress = index / data.length;
          final isFilled = barProgress <= progress;

          return Expanded(
            child: Container(
              height: data[index] * 30,
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                color: isFilled 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
