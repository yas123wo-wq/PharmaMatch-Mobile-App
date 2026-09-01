// lib/domain/interfaces/i_profile_repository.dart
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<ProfileEntity> getProfile();
}
