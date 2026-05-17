import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../widgets/confession_card.dart';
import '../models/user.dart';
import '../models/confession.dart';
import '../core/navigation/playback_manager.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';
import 'confession_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late List<Confession> _savedConfessions;
  final PlaybackManager _pm = PlaybackManager();

  bool _isSelectMode = false;
  final Set<String> _selectedHistoryIds = {};

  @override
  void initState() {
    super.initState();
    _savedConfessions = [];
    _loadSavedConfessions();
    _pm.addListener(_onPlaybackChange);
  }

  Future<void> _loadSavedConfessions() async {
    final currentUser = AuthStateService.instance.currentUser;
    if (currentUser == null || currentUser.savedConfessionIds.isEmpty) {
      if (mounted) {
        setState(() {
          _savedConfessions = [];
        });
      }
      return;
    }
    try {
      final saved = await AppwriteDbService.instance.getSavedConfessions(
        currentUser.savedConfessionIds,
      );
      if (mounted) {
        setState(() {
          _savedConfessions = saved;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _savedConfessions = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _pm.removeListener(_onPlaybackChange);
    super.dispose();
  }

  void _onPlaybackChange() {
    if (mounted) setState(() {});
  }

  void _openDetail(Confession confession) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
  }

  void _unsaveConfession(int index, Confession conf) {
    setState(() {
      _savedConfessions.removeAt(index);

      final idxInGlobal = Confession.mockConfessions.indexWhere(
        (c) => c.id == conf.id,
      );
      if (idxInGlobal != -1) {
        Confession.mockConfessions[idxInGlobal] = Confession
            .mockConfessions[idxInGlobal]
            .copyWith(isSaved: false);
      }

      final currentUser =
          AuthStateService.instance.currentUser ?? AppUser.fallbackUser;
      final savedIds = List<String>.from(currentUser.savedConfessionIds);
      savedIds.remove(conf.id);
      final updatedUser = currentUser.copyWith(savedConfessionIds: savedIds);
      if (AuthStateService.instance.currentUser != null) {
        AuthStateService.instance.updateUser(updatedUser);
        AppwriteDbService.instance.updateSavedConfessions(
          currentUser.id,
          savedIds,
        );
      } else {
        AppUser.fallbackUser = updatedUser;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed voice from saved'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  Map<String, List<Confession>> _groupHistoryByDate(
    List<Confession> confessions,
  ) {
    final Map<String, List<Confession>> grouped = {};
    for (var c in confessions) {
      final listenTime = c.listenedAt ?? c.createdAt;
      final dateStr = DateFormat('yyyy-MM-dd').format(listenTime);
      final dateLabel = _formatDateLabel(dateStr);
      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(c);
    }
    return grouped;
  }

  String _formatDateLabel(String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) {
      return 'Today (${DateFormat('MMM d').format(parsed)})';
    }
    if (diffDays == 1) {
      return 'Yesterday (${DateFormat('MMM d').format(parsed)})';
    }

    return DateFormat('MMM d').format(parsed);
  }

  void _deleteSelectedHistory() {
    if (_selectedHistoryIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: const Text(
          'Delete Selected',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedHistoryIds.length} selected recording(s) from your history?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _pm.removeMultipleFromHistory(_selectedHistoryIds);
              setState(() {
                _selectedHistoryIds.clear();
                _isSelectMode = false;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selected history recordings deleted'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.pureBlack,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: const Text(
          'Clear Listen History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear your entire listen history? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _pm.clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listen history cleared'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.pureBlack,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    indicatorColor: AppColors.pureBlack,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.pureBlack,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                    isScrollable: false,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2.0,
                    tabs: const [
                      Tab(text: 'Saved'),
                      Tab(text: 'History'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: TabBarView(
                    children: [_buildSavedTab(), _buildHistoryTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.pureBlack,
            backgroundColor: AppColors.cardBg,
            onRefresh: _loadSavedConfessions,
            child: _savedConfessions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [const SizedBox(height: 100), _buildEmptyState()],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _savedConfessions.length,
                    itemBuilder: (context, index) {
                      final conf = _savedConfessions[index];
                      return Dismissible(
                        key: Key(conf.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (dir) => _unsaveConfession(index, conf),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.accentRed,
                          ),
                        ),
                        child: ConfessionCard(
                          confession: conf,
                          onTap: () => _openDetail(conf),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final history = _pm.history;

    if (history.isEmpty) {
      return _buildHistoryEmptyState();
    }

    final grouped = _groupHistoryByDate(history);
    final dateKeys = grouped.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHistoryHeaderControls(history),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: dateKeys.length,
            itemBuilder: (context, dateIndex) {
              final dateLabel = dateKeys[dateIndex];
              final confs = grouped[dateLabel]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accentRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        children: confs.map((conf) {
                          final isSelected = _selectedHistoryIds.contains(
                            conf.id,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Dismissible(
                              key: Key('history_${conf.id}'),
                              direction: _isSelectMode
                                  ? DismissDirection.none
                                  : DismissDirection.endToStart,
                              onDismissed: (dir) {
                                _pm.removeFromHistory(conf.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Removed from listen history',
                                    ),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.pureBlack,
                                  ),
                                );
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.accentRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.accentRed,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (_isSelectMode) ...[
                                    IconButton(
                                      icon: Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? AppColors.accentRed
                                            : AppColors.textSecondary,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedHistoryIds.remove(conf.id);
                                          } else {
                                            _selectedHistoryIds.add(conf.id);
                                          }
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: ConfessionCard(
                                      confession: conf,
                                      onTap: () {
                                        if (_isSelectMode) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedHistoryIds.remove(
                                                conf.id,
                                              );
                                            } else {
                                              _selectedHistoryIds.add(conf.id);
                                            }
                                          });
                                        } else {
                                          _openDetail(conf);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeaderControls(List<Confession> history) {
    if (_isSelectMode) {
      final allIds = history.map((c) => c.id).toList();
      final isAllSelected = _selectedHistoryIds.length == history.length;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _isSelectMode = false;
                    _selectedHistoryIds.clear();
                  });
                },
              ),
              const SizedBox(width: 4),
              Text(
                '${_selectedHistoryIds.length} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isAllSelected
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                  color: AppColors.textPrimary,
                ),
                tooltip: isAllSelected ? 'Deselect All' : 'Select All',
                onPressed: () {
                  setState(() {
                    if (isAllSelected) {
                      _selectedHistoryIds.clear();
                    } else {
                      _selectedHistoryIds.addAll(allIds);
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.accentRed,
                ),
                tooltip: 'Delete Selected',
                onPressed: _selectedHistoryIds.isEmpty
                    ? null
                    : _deleteSelectedHistory,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listen History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your recently played recordings',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Feather.list,
                color: AppColors.textPrimary,
                size: 21.0,
              ),
              tooltip: 'Select Multiple',
              onPressed: () {
                setState(() {
                  _isSelectMode = true;
                  _selectedHistoryIds.clear();
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Feather.trash_2,
                color: AppColors.textPrimary,
                size: 21.0,
              ),
              tooltip: 'Clear History',
              onPressed: _clearAllHistory,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_outline,
              color: AppColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Your saved voices will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse and bookmark them to listen to them later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Your listen history is empty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Voices you play will be recorded in your history.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
