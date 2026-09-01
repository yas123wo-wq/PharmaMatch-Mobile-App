// lib/application/services/profile_app_service.dart
import '../../domain/entities/profile_entity.dart';
import '../../domain/interfaces/i_profile_repository.dart';

class ProfileAppService {
  final IProfileRepository _repository;

  ProfileAppService(this._repository);

  Future<ProfileEntity> getProfile() {
    return _repository.getProfile();
  }
}
