// lib/domain/interfaces/i_drug_repository.dart
import '../entities/drug_entity.dart';

abstract class IDrugRepository {
  Future<List<DrugEntity>> getDrugs({String? query, String? activeIngredient, int page, int limit});
  Future<List<DrugEntity>> searchAlternatives(String query);
  Future<DrugEntity> getDrugById(int id);
  Future<List<String>> getActiveIngredients({String? query});
  Future<DrugEntity> addDrug(Map<String, dynamic> drugData);
}
