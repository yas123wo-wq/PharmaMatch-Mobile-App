// lib/infrastructure/repositories/drug_repository_impl.dart
import '../../domain/entities/drug_entity.dart';
import '../../domain/interfaces/i_drug_repository.dart';
import '../api/api_service.dart';

class DrugRepositoryImpl implements IDrugRepository {
  @override
  Future<List<DrugEntity>> getDrugs({String? query, String? activeIngredient, int page = 1, int limit = 50}) async {
    return await ApiService.getDrugs(query: query, activeIngredient: activeIngredient, page: page, limit: limit);
  }

  @override
  Future<List<DrugEntity>> searchAlternatives(String query) async {
    return await ApiService.searchAlternatives(query);
  }

  @override
  Future<DrugEntity> getDrugById(int id) async {
    return await ApiService.getDrugById(id);
  }

  @override
  Future<List<String>> getActiveIngredients({String? query}) async {
    return await ApiService.getActiveIngredients(query: query);
  }

  @override
  Future<DrugEntity> addDrug(Map<String, dynamic> drugData) async {
    return await ApiService.addDrug(drugData);
  }

  @override
  Future<DrugEntity> updateDrug(int id, Map<String, dynamic> drugData) async {
    return await ApiService.updateDrug(id, drugData);
  }
}
