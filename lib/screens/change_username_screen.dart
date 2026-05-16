import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';

class ChangeUsernameScreen extends StatefulWidget {
  final String currentHandle;

  const ChangeUsernameScreen({super.key, required this.currentHandle});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  bool _isLoading = false;
  bool _isChecking = false;
  bool? _isAvailable;
  String? _errorText;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final rawHandle = widget.currentHandle.startsWith('@')
        ? widget.currentHandle.substring(1)
        : widget.currentHandle;
    _usernameController = TextEditingController(text: rawHandle);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final text = value.trim().replaceAll('@', '');

    if (text.isEmpty) {
      setState(() {
        _isChecking = false;
        _isAvailable = null;
        _errorText = null;
      });
      return;
    }

    if (text.length < 3) {
      setState(() {
        _isChecking = false;
        _isAvailable = false;
        _errorText = 'Username must be at least 3 characters';
      });
      return;
    }

    final currentRaw = widget.currentHandle.replaceAll('@', '');
    if (text.toLowerCase() == currentRaw.toLowerCase()) {
      setState(() {
        _isChecking = false;
        _isAvailable = true;
        _errorText = null;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _isAvailable = null;
      _errorText = null;
    });

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final handle = '@$text';
        final available = await AppwriteDbService.instance.checkHandleAvailable(handle);
        if (mounted) {
          setState(() {
            _isChecking = false;
            _isAvailable = available;
            _errorText = available ? null : 'This username is already taken';
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isChecking = false;
            _isAvailable = null;
            _errorText = null;
          });
        }
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isChecking) return;
    if (_isAvailable == false) return;

    final text = _usernameController.text.trim().replaceAll('@', '');
    final newHandle = '@$text';

    if (newHandle.toLowerCase() == widget.currentHandle.toLowerCase()) {
      Navigator.pop(context, widget.currentHandle);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthStateService.instance.currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(handle: newHandle);
        await AppwriteDbService.instance.updateUserProfile(updatedUser);
        AuthStateService.instance.updateUser(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully! ❤️'),
            backgroundColor: AppColors.pureBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, newHandle);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildUsernameSuffix() {
    if (_isChecking) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.pureBlack,
          ),
        ),
      );
    }
    if (_isAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (_isAvailable == false) {
      return const Icon(Icons.error, color: AppColors.accentRed);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.pureBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Username',
          style: TextStyle(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Current Username',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    widget.currentHandle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'New Username',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  cursorColor: AppColors.pureBlack,
                  style: const TextStyle(fontSize: 15),
                  onChanged: _onUsernameChanged,
                  decoration: InputDecoration(
                    hintText: 'e.g. dreamer',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixText: '@',
                    suffixIcon: _buildUsernameSuffix(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.pureBlack, width: 1.5),
                    ),
                    errorText: _errorText,
                    helperText: _isAvailable == true ? 'Username is available.' : null,
                    helperStyle: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  validator: (value) {
                    final text = value?.trim().replaceAll('@', '') ?? '';
                    if (text.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (text.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (_isAvailable == false) {
                      return 'This username is already taken';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: (_isLoading || _isChecking || _isAvailable == false) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pureBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Username',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
