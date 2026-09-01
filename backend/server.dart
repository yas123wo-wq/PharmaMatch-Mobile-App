import 'dart:convert';
import 'dart:io';

// This is our simulated database
List<Map<String, dynamic>> drugsDB = [
  {
    'id': 1,
    'name': 'بنادول إضافي',
    'active_ingredient': 'باراسيتامول 500mg',
    'category': 'مسكنات',
    'location': 'A-1 رف',
    'price': 14.75,
    'stock': 15,
    'expiry_date': '2028-12-01T00:00:00.000',
    'match_percentage': 95,
    'match_level': 'high',
    'is_available': true,
  },
  {
    'id': 2,
    'name': 'فيفادول إكسترا',
    'active_ingredient': 'باراسيتامول 500mg + كافيين',
    'category': 'مسكنات',
    'location': 'A-3 رف',
    'price': 11.50,
    'stock': 8,
    'expiry_date': '2027-09-01T00:00:00.000',
    'match_percentage': 89,
    'match_level': 'medium',
    'is_available': true,
  },
];

void main() async {
  final port = 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('✅ Server is running on http://0.0.0.0:$port');

  await for (HttpRequest request in server) {
    // Add CORS headers for web compatibility
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');

    // Handle preflight requests
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;

    try {
      if (path == '/v1/drugs' && request.method == 'GET') {
        final query = request.uri.queryParameters['q'] ?? '';
        
        List<Map<String, dynamic>> results = drugsDB;
        if (query.isNotEmpty) {
          results = drugsDB.where((d) {
            final name = d['name'].toString().toLowerCase();
            final active = d['active_ingredient'].toString().toLowerCase();
            final q = query.toLowerCase();
            return name.contains(q) || active.contains(q);
          }).toList();
        }

        final responseBody = jsonEncode({'data': results});
        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.ok
          ..write(responseBody);

      } else if (path == '/v1/drugs' && request.method == 'POST') {
        final content = await utf8.decoder.bind(request).join();
        final Map<String, dynamic> body = jsonDecode(content);

        final newDrug = {
          'id': DateTime.now().millisecondsSinceEpoch % 100000,
          'name': body['name'] ?? '',
          'active_ingredient': body['active_ingredient'] ?? '',
          'category': body['category'] ?? '',
          'location': body['location'] ?? '',
          'price': double.tryParse(body['price']?.toString() ?? '0') ?? 0.0,
          'stock': int.tryParse(body['stock']?.toString() ?? '0') ?? 0,
          'expiry_date': body['expiry_date'],
          'is_available': true,
        };

        drugsDB.insert(0, newDrug);

        final responseBody = jsonEncode({'data': newDrug});
        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.created
          ..write(responseBody);
          
      } else if (path == '/v1/profile' && request.method == 'GET') {
        final profile = {
          'data': {
            'id': 1,
            'name': 'د. أحمد عبد الرحمن',
            'role': 'مالك الصيدلية وإداري المخزون',
            'pharmacy_name': 'صيدلية الشفاء الحديثة',
            'license_number': 'PH-99281-A',
            'phone': '+966 50 123 4567',
            'expired_drugs_count': 1,
            'total_alternatives': 420,
          }
        };
        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode(profile));
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found');
      }
    } catch (e) {
      print('Error processing request: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error');
    } finally {
      await request.response.close();
    }
  }
}
