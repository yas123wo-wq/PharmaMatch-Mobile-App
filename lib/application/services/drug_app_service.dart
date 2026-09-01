// lib/application/services/drug_app_service.dart
import '../../domain/entities/drug_entity.dart';
import '../../domain/interfaces/i_drug_repository.dart';

class DrugAppService {
  final IDrugRepository _repository;

  DrugAppService(this._repository);

  Future<List<DrugEntity>> getDrugs({String? query, String? activeIngredient}) {
    return _repository.getDrugs(query: query, activeIngredient: activeIngredient);
  }

  Future<List<DrugEntity>> searchAlternatives(String query) {
    return _repository.searchAlternatives(query);
  }

  Future<DrugEntity> getDrugById(int id) {
    return _repository.getDrugById(id);
  }

  Future<List<String>> getActiveIngredients({String? query}) {
    return _repository.getActiveIngredients(query: query);
  }

  Future<DrugEntity> addDrug(Map<String, dynamic> drugData) {
    return _repository.addDrug(drugData);
  }
}
