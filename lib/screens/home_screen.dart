import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../models/confession.dart';
import '../services/firebase/firebase_db_service.dart';
import '../services/auth_state_service.dart';
import '../models/user.dart';
import 'confession_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaybackManager _pm = PlaybackManager();

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _followingScrollController = ScrollController();

  List<Confession> _loaded24Hours = [];
  List<Confession> _loadedFollowing = [];

  int _offset24h = 0;
  int _offsetFollowing = 0;
  static const int _pageSize = 16;

  bool _isLoadingMore24h = false;
  bool _isLoadingMoreFollowing = false;
  bool _hasMore24h = true;
  bool _hasMoreFollowing = true;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _mainScrollController.addListener(_onMainScroll);
    _horizontalScrollController.addListener(_onHorizontalScroll);
    _followingScrollController.addListener(_onFollowingScroll);
  }

  Future<void> _loadInitialData() async {
    try {
      final confessions = await FirebaseDbService.instance.getConfessions(limit: _pageSize, offset: 0);
      final currentUser = AuthStateService.instance.currentUser;
      List<Confession> following = [];
      if (currentUser != null && currentUser.followingIds.isNotEmpty) {
        following = await FirebaseDbService.instance.getFollowingConfessions(
          currentUser.followingIds, limit: _pageSize, offset: 0);
      }
      if (mounted) {
        setState(() {
          _loaded24Hours = confessions;
          _loadedFollowing = following;
          _offset24h = confessions.length;
          _offsetFollowing = following.length;
          _hasMore24h = confessions.length >= _pageSize;
          _hasMoreFollowing = following.length >= _pageSize;
          _isInitialLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loaded24Hours = Confession.generateManyMockConfessions(16, forFollowing: false);
          _loadedFollowing = Confession.generateManyMockConfessions(16, forFollowing: true);
          _isInitialLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _horizontalScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  void _onMainScroll() {}

  void _onHorizontalScroll() {
    if (_horizontalScrollController.position.pixels >=
        _horizontalScrollController.position.maxScrollExtent - 80) {
      _lazyLoadMore24h();
    }
  }

  void _onFollowingScroll() {
    if (_followingScrollController.position.pixels >=
        _followingScrollController.position.maxScrollExtent - 80) {
      _lazyLoadMoreFollowing();
    }
  }

  Future<void> _lazyLoadMoreFollowing() async {
    if (_isLoadingMoreFollowing || !_hasMoreFollowing) return;
    setState(() => _isLoadingMoreFollowing = true);
    try {
      final currentUser = AuthStateService.instance.currentUser;
      List<Confession> more = [];
      if (currentUser != null && currentUser.followingIds.isNotEmpty) {
        more = await FirebaseDbService.instance.getFollowingConfessions(
          currentUser.followingIds, limit: _pageSize, offset: _offsetFollowing);
      }
      if (mounted) {
        setState(() {
          _loadedFollowing.addAll(more);
          _offsetFollowing += more.length;
          _hasMoreFollowing = more.length >= _pageSize;
          _isLoadingMoreFollowing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMoreFollowing = false);
    }
  }

  Future<void> _lazyLoadMore24h() async {
    if (_isLoadingMore24h || !_hasMore24h) return;
    setState(() => _isLoadingMore24h = true);
    try {
      final more = await FirebaseDbService.instance.getConfessions(limit: _pageSize, offset: _offset24h);
      if (mounted) {
        setState(() {
          _loaded24Hours.addAll(more);
          _offset24h += more.length;
          _hasMore24h = more.length >= _pageSize;
          _isLoadingMore24h = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore24h = false);
    }
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
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  List<List<Confession>> _chunkList(List<Confession> list, int chunkSize) {
    List<List<Confession>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 10,
        title: Text(
          ' thestatic',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 26,
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
            icon: const Icon(
              Feather.menu,
              color: AppColors.pureBlack,
              size: 21.50,
            ),
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
            _buildActivePlayer(context, _pm),

            const SizedBox(height: 30),

            const SectionTitle(
              title: 'Recent Confessions ',
              subtitle: 'Confessions made in the last 24 hours',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: Builder(
                builder: (context) {
                  final chunks = _chunkList(_loaded24Hours, 4);

                  return ListView.separated(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: chunks.length + (_isLoadingMore24h ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: chunk.map((conf) {
                            return ConfessionCard(
                              confession: conf,
                              isHorizontal: false,
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

            const SizedBox(height: 24),

            const SectionTitle(
              title: 'From People You Follow',
              subtitle: 'Confessions from people you follow',
            ),
            const SizedBox(height: 12),
            _loadedFollowing.isEmpty
                ? _buildEmptyFollowingState(context)
                : SizedBox(
                    height: 300,
                    child: Builder(
                      builder: (context) {
                        final chunks = _chunkList(_loadedFollowing, 4);

                        return ListView.separated(
                          controller: _followingScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              chunks.length + (_isLoadingMoreFollowing ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 14),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: chunk.map((conf) {
                                  return ConfessionCard(
                                    confession: conf,
                                    isHorizontal: false,
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

            const SizedBox(height: 50),

            Center(
              child: Column(
                children: [
                  Text(
                    'We ❤️ Confessions and You!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlayer(BuildContext context, PlaybackManager pm) {
    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final conf = pm.activeConfession;

        if (conf == null) {
          return _buildWelcomeBanner(context);
        }

        final isPlaying = pm.isPlaying;
        final progress = pm.progress;

        return GestureDetector(
          onTap: () => _openDetail(context, conf),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.pureBlack,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? AppColors.accentRed
                                : AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPlaying ? 'Now Playing...' : 'Last Played',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.background.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'VIEW DETAILS',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                FutureBuilder<AppUser?>(
                  future: FirebaseDbService.instance.getUserProfile(conf.authorId),
                  builder: (context, snapshot) {
                    final author = snapshot.data;
                    final authorName = author?.displayName ?? 'Anonymous';
                    final authorHandle = author?.handle ?? '';

                    return Text(
                      'by $authorName • $authorHandle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.background.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    );
                  }
                ),

                const SizedBox(height: 16),

                _buildWaveform(conf.waveformData, progress, isPlaying),
                const SizedBox(height: 12),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => pm.togglePlay(conf, context: context),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: SizedBox(
                              height: 3,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pm.activeConfession?.id == conf.id
                                    ? pm.elapsedString
                                    : '0:00',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                conf.durationString,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
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
          ),
        );
      },
    );
  }

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
          ),
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
            'Listen to untold feelings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "A safe and non judgemental space where people share their deepest thoughts, secrets, and messages. Tap any voice confession below to start listening.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.background.withOpacity(0.65),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFollowingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            color: AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            "Your feed is quiet...",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Follow other users to listen to their voice stories late at night.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

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
                color: isFilled ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
