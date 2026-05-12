import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../mock_data/sample_data.dart';
import '../models/confession.dart';
import 'confession_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late List<Confession> _savedConfessions;

  @override
  void initState() {
    super.initState();
    _savedConfessions = SampleData.mockConfessions.where((c) => c.isSaved).toList();
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
      
      // Update global mock data reference too
      final idxInGlobal = SampleData.mockConfessions.indexWhere((c) => c.id == conf.id);
      if (idxInGlobal != -1) {
        SampleData.mockConfessions[idxInGlobal] = SampleData.mockConfessions[idxInGlobal].copyWith(isSaved: false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed confession from saved journal ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              Text(
                'My Saved Journal',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              const SectionTitle(
                title: 'Bookmarked Whispers ❤️',
                subtitle: 'unspoken words you chose to remember',
              ),
              const SizedBox(height: 14),

              Expanded(
                child: _savedConfessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _savedConfessions.length,
                        itemBuilder: (context, index) {
                          final conf = _savedConfessions[index];
                          
                          // Dismissible container to slide away to delete
                          return Dismissible(
                            key: Key(conf.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (dir) => _unsaveConfession(index, conf),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: AppColors.accentRed.withOpacity(0.15),
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
            ],
          ),
        ),
      ),
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
              'your saved confessions will appear here ❤️',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'listen to other stories late at night and bookmark them to save them in your emotional diary.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
