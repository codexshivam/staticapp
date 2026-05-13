import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../core/theme/app_colors.dart';

class LegalDocumentScreen extends StatefulWidget {
  final String title;
  final String remoteConfigKey;
  final String localAssetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.remoteConfigKey,
    required this.localAssetPath,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      String configText = remoteConfig.getString(widget.remoteConfigKey);
      
      if (configText.isNotEmpty && !configText.startsWith('http')) {
        setState(() {
          _content = configText;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Failed to load from remote config, using offline fallback: $e');
    }

    try {
      final localText = await rootBundle.loadString(widget.localAssetPath);
      setState(() {
        _content = localText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Could not load document offline. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.pureBlack))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
    );
  }
}
