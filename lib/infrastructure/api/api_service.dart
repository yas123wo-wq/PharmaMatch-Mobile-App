// lib/infrastructure/api/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/drug_model.dart';
import '../models/profile_model.dart';

/// خدمة الربط مع الـ Backend API
class ApiService {
  // ─── Configuration ──────────────────────────────────────────────────────────
  static String _serverHost = '192.168.8.185';
  static int _serverPort = 5033;
  static bool _useHttps = false;

  static String get baseUrl => _useHttps
      ? 'https://$_serverHost:7033/api'
      : 'http://$_serverHost:$_serverPort/api';

  static const Duration timeout = Duration(seconds: 10);

  static void setServerHost(String host, {int? port, bool? useHttps}) {
    _serverHost = host;
    if (port != null) _serverPort = port;
    if (useHttps != null) _useHttps = useHttps;
  }

  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'ar',
  };

  // ─── Auth Token ──────────────────────────────────────────────────────────
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ─── Generic HTTP Methods ───────────────────────────────────────────────────

  static Future<dynamic> _get(String endpoint) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      var response = await http
          .get(uri, headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 307 || response.statusCode == 308 || response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectedUri = Uri.parse(redirectUrl);
          response = await http
              .get(redirectedUri, headers: _headers)
              .timeout(timeout);
        }
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('تعذر الاتصال بسيرفر ASP.NET على ($baseUrl)');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    } on FormatException {
      throw ApiException('خطأ في تنسيق البيانات الواردة');
    }
  }

  static Future<dynamic> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      var response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(timeout);

      if (response.statusCode == 307 || response.statusCode == 308 || response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectedUri = Uri.parse(redirectUrl);
          response = await http
              .post(redirectedUri, headers: _headers, body: jsonEncode(body))
              .timeout(timeout);
        }
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('تعذر الاتصال بسيرفر ASP.NET على ($baseUrl)');
    } on HttpException {
      throw ApiException('خطأ في الاتصال بالخادم');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (statusCode == 401) {
      throw ApiException('غير مصرح – يرجى تسجيل الدخول مجددًا', code: 401);
    } else if (statusCode == 404) {
      throw ApiException('البيانات المطلوبة غير موجودة', code: 404);
    } else if (statusCode == 500) {
      throw ApiException('خطأ في الخادم، يرجى المحاولة لاحقًا', code: 500);
    } else {
      throw ApiException('خطأ غير متوقع (كود: $statusCode) ${response.body}', code: statusCode);
    }
  }

  // ─── Drugs API ──────────────────────────────────────────────────────────────

  static Future<List<DrugModel>> getDrugs({
    String? query,
    String? activeIngredient,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = StringBuffer('');
      if (query != null && query.isNotEmpty) {
        params.write('?q=${Uri.encodeComponent(query)}');
      }
      final data = await _get('/ProductMedicines$params');
      List list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['data'] ?? data['medicines'] ?? [];
      }
      return list.map((e) => DrugModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('API Error in getDrugs: $e');
      rethrow;
    }
  }

  static Future<List<DrugModel>> searchAlternatives(String query) async {
    try {
      final data = await _get('/ProductMedicines/alternatives?q=${Uri.encodeComponent(query)}');
      List list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['data'] ?? data['results'] ?? [];
      }
      return list.map((e) => DrugModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('API Error in searchAlternatives: $e');
      rethrow;
    }
  }

  static Future<DrugModel> getDrugById(int id) async {
    try {
      final data = await _get('/ProductMedicines/$id');
      if (data is List && data.isNotEmpty) {
        return DrugModel.fromJson(data[0] as Map<String, dynamic>);
      }
      final mapData = data is Map ? (data['data'] ?? data) : data;
      return DrugModel.fromJson(mapData as Map<String, dynamic>);
    } catch (e) {
      print('API Error in getDrugById: $e');
      rethrow;
    }
  }

  static Future<List<String>> getActiveIngredients({String? query}) async {
    try {
      final q = query != null ? '?q=${Uri.encodeComponent(query)}' : '';
      final data = await _get('/ActiveIngredients$q');
      List list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['data'] ?? data['ingredients'] ?? [];
      }
      return list.map((e) {
        if (e is Map) {
          return (e['scientificName'] ?? e['name'] ?? e.toString()).toString();
        }
        return e.toString();
      }).toList();
    } catch (e) {
      print('API Error in getActiveIngredients: $e');
      return _mockActiveIngredients;
    }
  }

  static Future<DrugModel> addDrug(Map<String, dynamic> drugData) async {
    try {
      final payload = {
        'tradeName': drugData['tradeName'] ?? drugData['name'],
        'name': drugData['name'] ?? drugData['tradeName'],
        'scientificName': drugData['scientificName'] ?? drugData['active_ingredient'] ?? drugData['activeIngredient'],
        'activeIngredient': drugData['activeIngredient'] ?? drugData['active_ingredient'] ?? drugData['scientificName'],
        'categoryName': drugData['categoryName'] ?? drugData['category'],
        'category': drugData['category'] ?? drugData['categoryName'],
        'price': double.tryParse(drugData['price'].toString()) ?? 0.0,
        'stock': int.tryParse(drugData['stock'].toString()) ?? 10,
        'initialQuantity': int.tryParse(drugData['stock'].toString()) ?? 10,
        'expiryDate': drugData['expiry_date'] ?? drugData['expiryDate'],
        'batchNumber': drugData['batchNumber'] ?? 'BN-MOBILE-NEW',
      };

      final data = await _post('/ProductMedicines', payload);
      final mapData = data is Map ? (data['data'] ?? data) : data;
      return DrugModel.fromJson(mapData as Map<String, dynamic>);
    } catch (e) {
      print('API Error in addDrug: $e');
      rethrow;
    }
  }

  // ─── Profile API ────────────────────────────────────────────────────────────

  static Future<ProfileModel> getProfile() async {
    try {
      final data = await _get('/profile');
      return ProfileModel.fromJson(data['data'] ?? data);
    } catch (_) {
      return ProfileModel.mock;
    }
  }

  // ─── Mock Data ───────────────────────────────────────────────────

  static final List<DrugModel> _cachedMockDrugs = [
    DrugModel(
      id: 1,
      name: 'بنادول إضافي',
      activeIngredient: 'باراسيتامول 500mg',
      category: 'قسم المسكنات',
      location: 'A-1 رف',
      price: 14.75,
      stock: 15,
      expiryDate: DateTime(2028, 12, 1),
      matchPercentage: 95,
      matchLevel: 'high',
      isAvailable: true,
    ),
    DrugModel(
      id: 2,
      name: 'فيفادول إكسترا',
      activeIngredient: 'باراسيتامول 500mg + كافيين',
      category: 'قسم المسكنات',
      location: 'A-3 رف',
      price: 11.50,
      stock: 8,
      expiryDate: DateTime(2027, 9, 1),
      matchPercentage: 89,
      matchLevel: 'medium',
      isAvailable: true,
    ),
    DrugModel(
      id: 3,
      name: 'أدول كولد أند فلو',
      activeIngredient: 'باراسيتامول + سودوإيفيدرين',
      category: 'قسم البرد والإنفلونزا',
      location: 'B-2 رف',
      price: 18.00,
      stock: 5,
      expiryDate: DateTime(2026, 6, 1),
      matchPercentage: 78,
      matchLevel: 'low',
      isAvailable: true,
    ),
    DrugModel(
      id: 4,
      name: 'برافيرال',
      activeIngredient: 'باراسيتامول 665mg',
      category: 'قسم المسكنات',
      location: 'A-2 رف',
      price: 9.50,
      stock: 20,
      expiryDate: DateTime(2028, 3, 1),
      matchPercentage: 85,
      matchLevel: 'high',
      isAvailable: true,
    ),
    DrugModel(
      id: 5,
      name: 'سيتامول',
      activeIngredient: 'باراسيتامول 500mg',
      category: 'قسم المسكنات',
      location: 'A-4 رف',
      price: 7.25,
      stock: 0,
      expiryDate: DateTime(2025, 11, 1),
      matchPercentage: 92,
      matchLevel: 'high',
      isAvailable: false,
    ),
  ];

  static const List<String> _mockActiveIngredients = [
    'باراسيتامول',
    'إيبوبروفين',
    'أميوكسيسيلين',
    'أزيثرومايسين',
    'سيتيريزين',
    'لوراتادين',
    'أوميبرازول',
    'ميتفورمين',
    'أملوديبين',
    'ليسينوبريل',
  ];
}

class ApiException implements Exception {
  final String message;
  final int? code;

  const ApiException(this.message, {this.code});

  @override
  String toString() => 'ApiException: $message (code: $code)';
}
