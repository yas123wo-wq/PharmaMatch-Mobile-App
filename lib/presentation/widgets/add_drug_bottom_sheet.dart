// lib/presentation/widgets/add_drug_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../infrastructure/api/api_service.dart';
import '../providers/drug_provider.dart';

class AddDrugBottomSheet extends StatefulWidget {
  const AddDrugBottomSheet({super.key});

  @override
  State<AddDrugBottomSheet> createState() => _AddDrugBottomSheetState();
}

class _AddDrugBottomSheetState extends State<AddDrugBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _activeIngredientController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String _selectedCategory = 'مسكنات';
  DateTime? _selectedExpiryDate;

  bool _isSubmitting = false;
  String? _statusBannerMessage;
  bool _isBannerSuccess = false;

  final List<String> _categories = [
    'مسكنات',
    'مضادات حيوية',
    'فيتامينات',
    'أدوية السكري',
    'أدوية الضغط',
    'أخرى',
  ];

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
        _statusBannerMessage = null;
      });

      final drugData = {
        'tradeName': _nameController.text.trim(),
        'name': _nameController.text.trim(),
        'scientificName': _activeIngredientController.text.trim(),
        'active_ingredient': _activeIngredientController.text.trim(),
        'categoryName': _selectedCategory,
        'category': _selectedCategory,
        'location': _locationController.text.isNotEmpty ? _locationController.text.trim() : 'غير محدد',
        'price': _priceController.text.trim(),
        'stock': _stockController.text.trim(),
        'initialQuantity': _stockController.text.trim(),
        'expiryDate': _selectedExpiryDate?.toIso8601String(),
        'expiry_date': _selectedExpiryDate?.toIso8601String(),
      };

      try {
        await ApiService.addDrug(drugData);
        
        if (mounted) {
          context.read<DrugProvider>().loadDrugs();
          
          setState(() {
            _isSubmitting = false;
            _statusBannerMessage = 'تم إضافة الدواء بنجاح وحفظه في قاعدة البيانات!';
            _isBannerSuccess = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الدواء بنجاح وحفظه في قاعدة البيانات'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e is ApiException ? e.message : 'فشل الحفظ: يرجى الاتصال بالسيرفر.';
          setState(() {
            _isSubmitting = false;
            _statusBannerMessage = errorMsg;
            _isBannerSuccess = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $errorMsg'),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _activeIngredientController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'إضافة دواء جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // اسم الدواء
              _buildTextField(
                controller: _nameController,
                label: 'اسم الدواء',
                icon: Icons.medication_rounded,
                validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال اسم الدواء' : null,
              ),
              const SizedBox(height: 16),
              
              // المادة الفعالة
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return await ApiService.getActiveIngredients(query: textEditingValue.text);
                },
                onSelected: (String selection) {
                  _activeIngredientController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.addListener(() {
                    _activeIngredientController.text = controller.text;
                  });
                  return _buildTextField(
                    controller: controller,
                    focusNode: focusNode,
                    label: 'المادة الفعالة',
                    icon: Icons.science_rounded,
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال/اختيار المادة الفعالة' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // الفئة
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              
              // تاريخ الانتهاء
              InkWell(
                onTap: _pickExpiryDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(
                    _selectedExpiryDate != null
                        ? '${_selectedExpiryDate!.year}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.day}'
                        : 'اختر تاريخ الانتهاء',
                    style: TextStyle(
                      color: _selectedExpiryDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // السعر والكمية
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'السعر',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'الكمية',
                      icon: Icons.inventory_2_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // الموقع / الرف
              _buildTextField(
                controller: _locationController,
                label: 'الموقع (الرف) - اختياري',
                icon: Icons.place_rounded,
                validator: (v) => null,
              ),
              
              const SizedBox(height: 24),

              if (_statusBannerMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isBannerSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isBannerSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isBannerSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                        color: _isBannerSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusBannerMessage!,
                          style: TextStyle(
                            color: _isBannerSuccess ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'حفظ الدواء',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
