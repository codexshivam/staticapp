import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../core/theme/app_colors.dart';
import '../widgets/search_field.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../widgets/user_list_tile.dart';
import '../models/confession.dart';
import '../models/user.dart';
import '../services/appwrite/appwrite_db_service.dart';
import 'confession_detail_screen.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  final ScrollController _dateScrollController = ScrollController();
  String _searchQuery = '';
  String _selectedDate = '';

  List<Confession> _displayedConfessions = [];
  List<AppUser> _displayedUsers = [];
  bool _isLoading = false;
  final Map<String, List<Confession>> _dateCache = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = _formatDateString(now);
    _loadConfessionsForDate(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.animateTo(
          _dateScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _loadConfessionsForDate(String date) async {
    if (_dateCache.containsKey(date)) {
      setState(() {
        _displayedConfessions = _dateCache[date]!;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AppwriteDbService.instance.getConfessionsByDate(
        date,
      );
      if (mounted) {
        setState(() {
          _displayedConfessions = result;
          _dateCache[date] = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _displayedConfessions = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadConfessionsForDate(_selectedDate);
      setState(() => _displayedUsers = []);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dateScrollController.hasClients) {
          _dateScrollController.animateTo(
            _dateScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final confessions = await AppwriteDbService.instance.searchConfessions(
        query,
      );
      final users = await AppwriteDbService.instance.searchUsers(query);

      if (mounted) {
        setState(() {
          _displayedConfessions = confessions;
          _displayedUsers = users;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _displayedConfessions = [];
          _displayedUsers = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateScrollController.dispose();
    super.dispose();
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

  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, String>> _generateCalendarDays() {
    final List<Map<String, String>> days = [];
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6)); // Last 7 days
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final yyyymmdd = _formatDateString(date);
      final label = labels[date.weekday % 7];
      days.add({'date': yyyymmdd, 'label': label, 'num': '${date.day}'});
    }

    return days;
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_selectedDate) ?? DateTime.now();
    final now = DateTime.now();
    final firstDate = DateTime(2026, 5, 10);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now)
          ? now
          : (initialDate.isBefore(firstDate) ? firstDate : initialDate),
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentRed,
              onPrimary: Colors.white,
              surface: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final dateStr = _formatDateString(picked);
      setState(() => _selectedDate = dateStr);
      _loadConfessionsForDate(dateStr);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dateScrollController.hasClients) {
          _dateScrollController.animateTo(
            _dateScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  List<Confession> get _filteredConfessions =>
      _isLoading && _displayedConfessions.isEmpty
      ? Confession.generateManyMockConfessions(8, forFollowing: false)
      : _displayedConfessions;
  List<AppUser> get _filteredUsers => _displayedUsers;

  Future<void> _openDetail(Confession confession) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
    
    if (deleted == true) {
      setState(() {
        _displayedConfessions.removeWhere((c) => c.id == confession.id);
        _dateCache.remove(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10.0),

              Text(
                'Explore',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              SearchField(
                controller: _searchController,
                hintText: 'Search voices and users',
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _performSearch(val);
                },
                onClear: () {
                  setState(() => _searchQuery = '');
                  _performSearch('');
                },
              ),

              const SizedBox(height: 20),

              if (_searchQuery.isNotEmpty) ...[
                if (_filteredUsers.isNotEmpty) ...[
                  const SectionTitle(title: 'Matching Users'),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserListTile(
                        user: user,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(user: user),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                SectionTitle(
                  title: 'Matching Voices',
                  subtitle: 'Matching "$_searchQuery"',
                ),
                const SizedBox(height: 12),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState(
                        'No voices or confessions match your search.',
                      )
                    : SizedBox(
                        height: 300,
                        child: Skeletonizer(
                          enabled: _isLoading,
                          containersColor: AppColors.cardBg,
                          effect: const ShimmerEffect(
                            baseColor: Color(0xFFDFDAD4),
                            highlightColor: Color(0xFFF0EDE9),
                          ),
                          child: Builder(
                            builder: (context) {
                              final chunks = _chunkList(
                                _filteredConfessions,
                                4,
                              );
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: chunks.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final chunk = chunks[index];
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: chunk.map((conf) {
                                        return ConfessionCard(
                                          confession: conf,
                                          isHorizontal: false,
                                          onTap: () => _openDetail(conf),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
              ] else ...[
                const SizedBox(height: 8),
                const SectionTitle(
                  title: 'Select Prefered Date',
                  subtitle: 'Browse voices by date',
                ),
                const SizedBox(height: 18),
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _dateScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _generateCalendarDays().map((day) {
                              final isSelected = _selectedDate == day['date']!;

                              return GestureDetector(
                                onTap: () {
                                  final dateStr = day['date']!;
                                  setState(() => _selectedDate = dateStr);
                                  _loadConfessionsForDate(dateStr);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.pureBlack
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day['label']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        day['num']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
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
                      const SizedBox(width: 4),
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.divider,
                        indent: 8,
                        endIndent: 8,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Feather.calendar,
                          color: AppColors.accentRed,
                          size: 20,
                        ),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                SectionTitle(
                  title: 'Voices on Selected Date',
                  subtitle: 'Shared on ${_formatDateLabel(_selectedDate)}',
                ),
                const SizedBox(height: 14),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState(
                        'No voices or confessions shared on this day.',
                      )
                    : SizedBox(
                        height: 300,
                        child: Skeletonizer(
                          enabled: _isLoading,
                          containersColor: AppColors.cardBg,
                          effect: const ShimmerEffect(
                            baseColor: Color(0xFFDFDAD4),
                            highlightColor: Color(0xFFF0EDE9),
                          ),
                          child: Builder(
                            builder: (context) {
                              final chunks = _chunkList(
                                _filteredConfessions,
                                4,
                              );
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: chunks.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final chunk = chunks[index];
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: chunk.map((conf) {
                                        return ConfessionCard(
                                          confession: conf,
                                          isHorizontal: false,
                                          onTap: () => _openDetail(conf),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.nights_stay_outlined,
            color: AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
}
