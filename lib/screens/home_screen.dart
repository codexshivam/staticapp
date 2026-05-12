import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../mock_data/sample_data.dart';
import '../models/confession.dart';
import 'confession_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaybackManager _pm = PlaybackManager();
  
  // Scroll Controllers for pagination
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Lazy loaded lists
  List<Confession> _loaded24Hours = [];
  List<Confession> _loadedFollowing = [];

  // Pagination pools
  late final List<Confession> _all24HoursPool;
  late final List<Confession> _allFollowingPool;

  // Pagination bounds
  int _limit24Hours = 16;
  int _limitFollowing = 6;

  bool _isLoadingMore24h = false;
  bool _isLoadingMoreFollowing = false;

  bool _hasMore24h = true;
  bool _hasMoreFollowing = true;

  @override
  void initState() {
    super.initState();

    // Pre-populate mock databases of 60+ items each
    _all24HoursPool = SampleData.generateManyMockConfessions(60, forFollowing: false);
    _allFollowingPool = SampleData.generateManyMockConfessions(60, forFollowing: true);

    // Initial chunk
    _loaded24Hours = _all24HoursPool.take(_limit24Hours).toList();
    _loadedFollowing = _allFollowingPool.take(_limitFollowing).toList();

    // Bind scroll controllers to trigger loaders
    _mainScrollController.addListener(_onMainScroll);
    _horizontalScrollController.addListener(_onHorizontalScroll);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Detect bottom of page scroll for vertical Following feed
  void _onMainScroll() {
    if (_mainScrollController.position.pixels >= _mainScrollController.position.maxScrollExtent - 150) {
      _lazyLoadMoreFollowing();
    }
  }

  // Detect end of list scroll for horizontal New Confessions
  void _onHorizontalScroll() {
    if (_horizontalScrollController.position.pixels >= _horizontalScrollController.position.maxScrollExtent - 80) {
      _lazyLoadMore24h();
    }
  }

  void _lazyLoadMoreFollowing() {
    if (_isLoadingMoreFollowing || !_hasMoreFollowing) return;

    setState(() {
      _isLoadingMoreFollowing = true;
    });

    // Simulate standard 600ms network delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      
      final nextLimit = _limitFollowing + 6;
      final hasMore = nextLimit < _allFollowingPool.length;
      final newItems = _allFollowingPool.take(nextLimit).toList();

      setState(() {
        _limitFollowing = nextLimit;
        _loadedFollowing = newItems;
        _isLoadingMoreFollowing = false;
        _hasMoreFollowing = hasMore;
      });
    });
  }

  void _lazyLoadMore24h() {
    if (_isLoadingMore24h || !_hasMore24h) return;

    setState(() {
      _isLoadingMore24h = true;
    });

    // Simulate standard 600ms network delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      final nextLimit = _limit24Hours + 8;
      final hasMore = nextLimit < _all24HoursPool.length;
      final newItems = _all24HoursPool.take(nextLimit).toList();

      setState(() {
        _limit24Hours = nextLimit;
        _loaded24Hours = newItems;
        _isLoadingMore24h = false;
        _hasMore24h = hasMore;
      });
    });
  }

  List<List<Confession>> _chunkList(List<Confession> list, int chunkSize) {
    List<List<Confession>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  void _openDetail(BuildContext context, Confession confession) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ConfessionDetailScreen(confession: confession),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
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
        controller: _mainScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: Currently Playing Active Player / Welcome Banner
            _buildActivePlayer(context, _pm),
            
            const SizedBox(height: 24),

            // SECTION 2: Confessions in 24 Hours ❤️ (Horizontal Scroll)
            const SectionTitle(
              title: 'New Confessions ❤️',
              subtitle: 'Confessions recorded in the last 24 hours',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 270, // 4 items of ~60px height + gap spacing
              child: Builder(
                builder: (context) {
                  final chunks = _chunkList(_loaded24Hours, 4);

                  return ListView.separated(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: chunks.length + (_isLoadingMore24h ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      if (index == chunks.length) {
                        return Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.pureBlack,
                            ),
                          ),
                        );
                      }

                      final chunk = chunks[index];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: chunk.map((conf) {
                            return ConfessionCard(
                              confession: conf,
                              isHorizontal: false, // Force vertical/list-tile layout inside columns!
                              onTap: () => _openDetail(context, conf),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // SECTION 3: From People You Follow ❤️ (Vertical List)
            const SectionTitle(
              title: 'Following Feed ❤️',
              subtitle: 'Confessions from creators you follow',
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _loadedFollowing.length + (_isLoadingMoreFollowing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _loadedFollowing.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pureBlack,
                        ),
                      ),
                    ),
                  );
                }
                final conf = _loadedFollowing[index];
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
                    'Confessions ❤️',
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
                    'Thank you for sharing anonymously.',
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

  // Active Top Player Card / Welcome Banner
  Widget _buildActivePlayer(BuildContext context, PlaybackManager pm) {
    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final conf = pm.activeConfession;

        // Display Welcome Message Hero if no track was loaded (New User)
        if (conf == null) {
          return _buildWelcomeBanner(context);
        }

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
                        isPlaying ? 'Now Playing...' : 'Last Played',
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
                        'VIEW DETAILS ❤️',
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

  // Welcome Banner empty state when activeConfession is null
  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'WELCOME TO CONFESSIONS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.background.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Listen to untold feelings ❤️',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "An anonymous space where people share their deepest thoughts, secrets, and messages. Tap any voice confession below to start listening.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.background.withOpacity(0.65),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
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
