// lib/presentation/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/profile_entity.dart';
import '../../application/services/profile_app_service.dart';
import '../../infrastructure/repositories/profile_repository_impl.dart';
import '../../infrastructure/api/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileAppService _profileAppService;

  ProfileProvider({ProfileAppService? profileAppService})
      : _profileAppService = profileAppService ?? ProfileAppService(ProfileRepositoryImpl());

  ProfileEntity _profile = ProfileEntity.mock;
  bool _isLoading = false;
  String _error = '';

  ProfileEntity get profile => _profile;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _profileAppService.getProfile();
      _error = '';
    } catch (e) {
      _error = e is ApiException ? e.message : 'خطأ في تحميل الملف الشخصي';
    }
    _isLoading = false;
    notifyListeners();
  }
}
