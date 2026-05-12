import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/search_field.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../widgets/user_list_tile.dart';
import '../mock_data/sample_data.dart';
import '../models/confession.dart';
import '../models/user.dart';
import 'confession_detail_screen.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Date selection state (Default is '2026-05-12' - Today)
  String _selectedDate = '2026-05-12';

  // Mock Calendar Dates list (Past 7 days)
  final List<Map<String, String>> _calendarDays = [
    {'date': '2026-05-06', 'label': 'W', 'num': '6'},
    {'date': '2026-05-07', 'label': 'T', 'num': '7'},
    {'date': '2026-05-08', 'label': 'F', 'num': '8'},
    {'date': '2026-05-09', 'label': 'S', 'num': '9'},
    {'date': '2026-05-10', 'label': 'S', 'num': '10'},
    {'date': '2026-05-11', 'label': 'M', 'num': '11'},
    {'date': '2026-05-12', 'label': 'T', 'num': '12'}, // Today
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter confessions based on calendar date or search query
  List<Confession> get _filteredConfessions {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      return SampleData.mockConfessions.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.authorName.toLowerCase().contains(q);
      }).toList();
    } else {
      return SampleData.mockConfessions.where((c) => c.dateText == _selectedDate).toList();
    }
  }

  // Filter users based on search query
  List<AppUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return SampleData.mockUsers.where((u) {
      return u.displayName.toLowerCase().contains(q) || u.handle.toLowerCase().contains(q);
    }).toList();
  }

  void _openDetail(Confession confession) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
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
              // Premium Title
              Text(
                'Explore',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Search Box
               SearchField(
                controller: _searchController,
                hintText: 'Search confessions or usernames...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              const SizedBox(height: 16),

              // Conditional UI: If searching, show search results. Else, show elegant date filtering.
              if (_searchQuery.isNotEmpty) ...[
                // SEARCH RESULTS FOR PEOPLE
                if (_filteredUsers.isNotEmpty) ...[
                  const SectionTitle(title: 'Matching Users ❤️'),
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

                // SEARCH RESULTS FOR AUDIO FILES
                SectionTitle(
                  title: 'Matching Confessions ❤️',
                  subtitle: 'Confessions matching "${_searchQuery}"',
                ),
                const SizedBox(height: 12),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState('No confessions match your search. Try another query.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredConfessions.length,
                        itemBuilder: (context, index) {
                          final conf = _filteredConfessions[index];
                          return ConfessionCard(
                            confession: conf,
                            onTap: () => _openDetail(conf),
                          );
                        },
                      ),
              ] else ...[
                // MINIMAL CALENDAR STRIP
                const SectionTitle(
                  title: 'Filter by Date ❤️',
                  subtitle: 'Browse confessions posted on previous days',
                ),
                const SizedBox(height: 12),
                Container(
                  height: 72,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _calendarDays.map((day) {
                      final isSelected = _selectedDate == day['date']!;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = day['date']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.pureBlack : Colors.transparent,
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
                                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                day['num']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // CONFESSIONS ON SELECTED DATE
                SectionTitle(
                  title: 'Confessions on Selected Date ❤️',
                  subtitle: 'Shared on ${_formatDateLabel(_selectedDate)}',
                ),
                const SizedBox(height: 12),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState('No confessions shared on this day.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredConfessions.length,
                        itemBuilder: (context, index) {
                          final conf = _filteredConfessions[index];
                          return ConfessionCard(
                            confession: conf,
                            onTap: () => _openDetail(conf),
                          );
                        },
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
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.nights_stay_outlined, color: AppColors.textSecondary, size: 28),
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

  String _formatDateLabel(String date) {
    if (date == '2026-05-12') return 'Today (May 12)';
    if (date == '2026-05-11') return 'Yesterday (May 11)';
    
    final dayNum = date.split('-').last;
    return 'May $dayNum';
  }
}
