// lib/infrastructure/repositories/profile_repository_impl.dart
import '../../domain/entities/profile_entity.dart';
import '../../domain/interfaces/i_profile_repository.dart';
import '../api/api_service.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  @override
  Future<ProfileEntity> getProfile() async {
    return await ApiService.getProfile();
  }
}
