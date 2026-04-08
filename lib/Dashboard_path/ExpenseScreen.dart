import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/api_config.dart'; // ← ADDED
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../colors/dashboard_colors.dart';
// ignore: unused_import
import '../fonts/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_save_button.dart';
// ignore: unused_import
import '../widgets/common/dashboard_section_label.dart';
// ignore: unused_import
import '../widgets/common/dashboard_text_field.dart';
// ignore: unused_import
import '../widgets/common/dashboard_icon_box.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────
int globalScanCount = 0;

enum ScanState { idle, scanning, scanned, failed }

class ScannedReceipt {
  final String amount;
  final String merchant;
  final String date;
  final String category;
  final int confidence;
  final List<ReceiptLine> lines;

  const ScannedReceipt({
    required this.amount,
    required this.merchant,
    required this.date,
    required this.category,
    required this.confidence,
    required this.lines,
  });

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) {
    final amount = json['amount']?.toString() ?? "0";
    final merchant = json['merchant']?.toString() ?? "";
    final date = json['date']?.toString() ?? "";
    final category = json['category']?.toString().toLowerCase() ?? "others";
    final confidence = json['confidence'] ?? 0;

    debugPrint('ScannedReceipt: ${jsonEncode(json)}');

    return ScannedReceipt(
      amount: amount,
      merchant: merchant,
      date: date,
      category: category,
      confidence: confidence,
      lines: [
        if (merchant.isNotEmpty) ReceiptLine('Merchant', merchant),
        if (date.isNotEmpty) ReceiptLine('Date', date),
        ReceiptLine('Total', '₹ $amount'),
      ],
    );
  }
}

class ReceiptLine {
  final String label;
  final String value;
  const ReceiptLine(this.label, this.value);
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class AddExpensePage extends StatefulWidget {
  /// Called after a successful save so the dashboard can update instantly.
  final void Function(String category, String merchant, String date,
      String note, double amount, String paymentMethod)? onExpenseAdded;

  const AddExpensePage({super.key, this.onExpenseAdded});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage>
    with TickerProviderStateMixin {
  // 🔑 Gemini API Keys
  final List<String> _apiKeys = [
    'AIzaSyD81_WGLPcDkPRlCZaOmRAsGqGMleEwkto', // ← REPLACE with your own Gemini API keys
  ];

  int _currentKeyIndex = 0;

  // ── Scan Limit ──────────────────────────────────────────────────────────
  int get _scanCount => globalScanCount;
  static const int _scanLimit = 250;
  static final bool _enforceScanLimit = false;

  // ── State Variables ──────────────────────────────────────────────────────
  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'UPI';
  bool _isSaving = false;
  final List<Map<String, String>> _customCategories = [];
  ScanState _scanState = ScanState.idle;

  final _merchantController = TextEditingController();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ScannedReceipt? _scannedReceipt;
  bool _autoFilled = false;

  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _scanAnimController;
  late AnimationController _fillAnimController;
  late Animation<double> _fillAnimation;

  // ── Payment method options ───────────────────────────────────────────────
  final List<String> _paymentMethods = [
    'UPI',
    'CASH',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'NET_BANKING',
  ];

  // Matches backend IDs: 1-Food 2-Travel 3-Supplies 4-Bills 5-Entertainment
  // 6-Medical 7-Education 8-Rent 9-Petrol 10-Electricity 11-Home Services
  final List<Map<String, String>> _baseCategories = [
    {'label': 'Food',          'emoji': '🍔'},
    {'label': 'Travel',        'emoji': '✈️'},
    {'label': 'Supplies',      'emoji': '🛒'},
    {'label': 'Bills',         'emoji': '💡'},
    {'label': 'Entertainment', 'emoji': '🎮'},
    {'label': 'Medical',       'emoji': '💊'},
    {'label': 'Education',     'emoji': '🎓'},
    {'label': 'Rent',          'emoji': '🏠'},
    {'label': 'Petrol',        'emoji': '⛽'},
    {'label': 'Electricity',   'emoji': '⚡'},
    {'label': 'Home Services', 'emoji': '🔧'},
  ];

  // Maps category name (case-insensitive) -> real category ID from the backend
  Map<String, int> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _fillAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillAnimController,
      curve: Curves.easeOut,
    );

    _loadCategories();
  }

  // Load real category IDs from backend
  Future<void> _loadCategories() async {
    try {
      final headers = await ApiConfig.authHeaders;
      final response = await http
          .get(Uri.parse(ApiConfig.categories), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = decoded is List
            ? decoded
            : ((decoded['data'] ?? decoded['categories'] ?? []) as List);

        final map = <String, int>{};
        for (final item in list) {
          final name = (item['name'] ?? item['categoryName'] ?? '').toString().toLowerCase().trim();
          final id = item['id'] ?? item['categoryId'];
          if (name.isNotEmpty && id != null) {
            map[name] = (id as num).toInt();
          }
        }
        if (mounted) setState(() => _categoryMap = map);
        debugPrint('Loaded categories: $map');
      }
    } catch (e) {
      debugPrint('Could not load categories: $e');
    }
  }

  // Resolve the selected category label -> its real backend ID
  int _resolvedCategoryId() {
    final key = _selectedCategory.toLowerCase().trim();
    if (_categoryMap.containsKey(key)) return _categoryMap[key]!;
    for (final entry in _categoryMap.entries) {
      if (entry.key.contains(key) || key.contains(entry.key)) return entry.value;
    }
    return _categoryMap.values.isNotEmpty ? _categoryMap.values.first : 1;
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _fillAnimController.dispose();
    _merchantController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ─── Save Expense to API ──────────────────────────────────────────────────

  Future<void> _saveExpense() async {
    // Validation
    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_merchantController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a merchant name')),
      );
      return;
    }

    // Convert date "April 23" → "2026-04-23"
    String expenseDate;
    try {
      final parsed = DateFormat('MMMM d').parse(_dateController.text.trim());
      expenseDate = DateFormat('yyyy-MM-dd').format(
        DateTime(DateTime.now().year, parsed.month, parsed.day),
      );
    } catch (_) {
      expenseDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    // ── DEBUG: trace exactly what is sent and what backend returns ──────────
    final resolvedId = _resolvedCategoryId();
    debugPrint('══════════════ SAVE EXPENSE DEBUG ══════════════');
    debugPrint('Selected category  : $_selectedCategory');
    debugPrint('Category map       : $_categoryMap');
    debugPrint('Resolved categoryId: $resolvedId');

    final bodyMap = {
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'merchant': _merchantController.text.trim(),
      'expenseDate': expenseDate,
      'description': _noteController.text.trim(),
      'paymentMethod': _selectedPaymentMethod,
      'categoryName': _selectedCategory,   // ✅ field name backend expects
      'categoryId': resolvedId,
    };
    debugPrint('Request body       : ${jsonEncode(bodyMap)}');
    debugPrint('Posting to         : ${ApiConfig.expenses}');

    final body = jsonEncode(bodyMap);

    setState(() => _isSaving = true);

    try {
      final headers = await ApiConfig.authHeaders;

      final response = await http.post(
        Uri.parse(ApiConfig.expenses),
        headers: headers,
        body: body,
      );

      debugPrint('Response status    : ${response.statusCode}');
      debugPrint('Response body      : ${response.body}');
      debugPrint('════════════════════════════════════════════════');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final saved = jsonDecode(response.body);
          final savedCat = saved['category'] ?? saved['categoryName'] ?? saved['categoryId'] ?? '?';
          debugPrint('Backend saved category as: $savedCat');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved! Backend category: $savedCat'),
              backgroundColor: const Color(0xFF2D6A5A),
              duration: const Duration(seconds: 4),
            ),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense saved!'), backgroundColor: Color(0xFF2D6A5A)),
          );
        }
        // ── Notify dashboard so all pages update immediately ──
        widget.onExpenseAdded?.call(
          _selectedCategory,
          _merchantController.text.trim(),
          expenseDate,
          _noteController.text.trim(),
          double.tryParse(_amountController.text.trim()) ?? 0.0,
          _selectedPaymentMethod,
        );
        Navigator.pop(context);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.'), backgroundColor: Colors.redAccent),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}: ${response.body}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Category Helpers ─────────────────────────────────────────────────────

  /// Known merchant → correct category overrides.
  /// When a scanned bill's merchant matches any key (case-insensitive substring),
  /// this category is used instead of whatever the AI returned.
  static const Map<String, String> _merchantCategoryOverrides = {
    // Medical (ID 6)
    'apollo'        : 'Medical',
    'medplus'       : 'Medical',
    'netmeds'       : 'Medical',
    'pharmeasy'     : 'Medical',
    '1mg'           : 'Medical',
    'practo'        : 'Medical',
    'fortis'        : 'Medical',
    'manipal'       : 'Medical',
    'narayana'      : 'Medical',
    'max hospital'  : 'Medical',
    'aiims'         : 'Medical',
    'cipla'         : 'Medical',
    'clinic'        : 'Medical',
    'hospital'      : 'Medical',
    'pharmacy'      : 'Medical',
    'diagnostic'    : 'Medical',
    // Food (ID 1)
    'swiggy'        : 'Food',
    'zomato'        : 'Food',
    'udipi'         : 'Food',
    'udupi'         : 'Food',
    'dominos'       : 'Food',
    'pizza hut'     : 'Food',
    'mcdonald'      : 'Food',
    'kfc'           : 'Food',
    'subway'        : 'Food',
    'burger king'   : 'Food',
    'starbucks'     : 'Food',
    'cafe coffee'   : 'Food',
    'haldiram'      : 'Food',
    'barbeque'      : 'Food',
    'restaurant'    : 'Food',
    'dhaba'         : 'Food',
    // Travel (ID 2)
    'ola'           : 'Travel',
    'uber'          : 'Travel',
    'rapido'        : 'Travel',
    'bmtc'          : 'Travel',
    'irctc'         : 'Travel',
    'indigo'        : 'Travel',
    'air india'     : 'Travel',
    'spicejet'      : 'Travel',
    'goibibo'       : 'Travel',
    'makemytrip'    : 'Travel',
    'redbus'        : 'Travel',
    'metro'         : 'Travel',
    'namma metro'   : 'Travel',
    // Bills (ID 4)
    'airtel'        : 'Bills',
    'jio'           : 'Bills',
    'bsnl'          : 'Bills',
    'vodafone'      : 'Bills',
    'broadband'     : 'Bills',
    // Petrol (ID 9)
    'bpcl'          : 'Petrol',
    'hpcl'          : 'Petrol',
    'iocl'          : 'Petrol',
    'bharat petroleum': 'Petrol',
    'indian oil'    : 'Petrol',
    'hindustan petroleum': 'Petrol',
    'nayara'        : 'Petrol',
    'petrol'        : 'Petrol',
    'fuel'          : 'Petrol',
    'diesel'        : 'Petrol',
    // Electricity (ID 10)
    'bescom'        : 'Electricity',
    'bbmp'          : 'Electricity',
    'bwssb'         : 'Electricity',
    'electricity'   : 'Electricity',
    'tneb'          : 'Electricity',
    'mseb'          : 'Electricity',
    'tata power'    : 'Electricity',
    'adani electricity': 'Electricity',
    // Supplies (ID 3)
    'bigbasket'     : 'Supplies',
    'blinkit'       : 'Supplies',
    'zepto'         : 'Supplies',
    'dmart'         : 'Supplies',
    'reliance fresh': 'Supplies',
    'spencer'       : 'Supplies',
    'nilgiris'      : 'Supplies',
    'amazon'        : 'Supplies',
    'flipkart'      : 'Supplies',
    'myntra'        : 'Supplies',
    'lifestyle'     : 'Supplies',
    'max fashion'   : 'Supplies',
    'westside'      : 'Supplies',
    'nykaa'         : 'Supplies',
    // Entertainment (ID 5)
    'pvr'           : 'Entertainment',
    'inox'          : 'Entertainment',
    'netflix'       : 'Entertainment',
    'hotstar'       : 'Entertainment',
    'amazon prime'  : 'Entertainment',
    'spotify'       : 'Entertainment',
    'bookmyshow'    : 'Entertainment',
    // Education (ID 7)
    'byju'          : 'Education',
    'unacademy'     : 'Education',
    'coursera'      : 'Education',
    'udemy'         : 'Education',
    'vedantu'       : 'Education',
    'school'        : 'Education',
    'college'       : 'Education',
    'university'    : 'Education',
    // Rent (ID 8)
    'rent'          : 'Rent',
    'hostel'        : 'Rent',
    // Home Services (ID 11)
    'urban company' : 'Home Services',
    'urbanclap'     : 'Home Services',
    'plumber'       : 'Home Services',
    'electrician'   : 'Home Services',
    'carpenter'     : 'Home Services',
    'cleaning'      : 'Home Services',
    'pest control'  : 'Home Services',
    'painting'      : 'Home Services',
  };

  /// Checks the merchant name (and optionally extra text) against the override
  /// table. If matched, returns the correct category label; otherwise falls
  /// back to [aiCategory] (what the scan AI returned).
  String _resolveCategoryFromMerchant(String merchant, String aiCategory) {
    final m = merchant.toLowerCase().trim();
    for (final entry in _merchantCategoryOverrides.entries) {
      if (m.contains(entry.key)) return entry.value;
    }
    return aiCategory; // AI category trusted only when no override matches
  }

  String _formatCategory(String raw) {
    return raw
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _getEmojiForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('petrol') || c.contains('fuel') || c.contains('gas') || c.contains('diesel') || c.contains('bpcl') || c.contains('hpcl') || c.contains('iocl') || c.contains('bharat petroleum') || c.contains('indian oil') || c.contains('hindustan petroleum')||c.contains('nayara energy')) return '⛽';
    if (c.contains('medical') || c.contains('doctor') || c.contains('hospital') || c.contains('pharmacy') || c.contains('clinic') || c.contains('apollo') || c.contains('medplus') || c.contains('netmeds')) return '💊';
    if (c.contains('grocery') || c.contains('vegetable') || c.contains('supermarket') || c.contains('bigbasket') || c.contains('zepto') || c.contains('blinkit') || c.contains('dmart')) return '🥦';
    if (c.contains('gym') || c.contains('fitness') || c.contains('workout') || c.contains('cult')) return '🏋️';
    if (c.contains('electricity') || c.contains('power') || c.contains('bescom') || c.contains('tneb')) return '⚡';
    if (c.contains('internet') || c.contains('wifi') || c.contains('broadband') || c.contains('jio') || c.contains('airtel') || c.contains('bsnl')) return '🌐';
    if (c.contains('insurance')) return '🛡️';
    if (c.contains('shopping') || c.contains('clothes') || c.contains('fashion') || c.contains('amazon') || c.contains('flipkart') || c.contains('myntra')) return '🛍️';
    if (c.contains('food') || c.contains('restaurant') || c.contains('swiggy') || c.contains('zomato') || c.contains('dining')) return '🍔';
    if (c.contains('travel') || c.contains('flight') || c.contains('train') || c.contains('bus') || c.contains('ola') || c.contains('uber') || c.contains('rapido')) return '✈️';
    if (c.contains('rent') || c.contains('house') || c.contains('home') || c.contains('housing')) return '🏠';
    if (c.contains('education') || c.contains('school') || c.contains('college') || c.contains('tuition') || c.contains('course')) return '🎓';
    if (c.contains('entertainment') || c.contains('movie') || c.contains('netflix') || c.contains('hotstar') || c.contains('amazon prime')) return '🎬';
    if (c.contains('salon') || c.contains('spa') || c.contains('beauty') || c.contains('grooming')) return '💈';
    if (c.contains('pet')) return '🐾';
    if (c.contains('bill') || c.contains('utility')) return '💡';
    if (c.contains('cafe') || c.contains('coffee') || c.contains('starbucks') || c.contains('chai')) return '☕';
    return '📌';
  }

  void _autoAddCategoryIfNew(String formattedLabel, String rawCategory) {
    final allLabels = [
      ..._baseCategories.map((c) => c['label']!),
      ..._customCategories.map((c) => c['label']!),
    ];
    if (!allLabels.contains(formattedLabel)) {
      setState(() {
        _customCategories.add({
          'label': formattedLabel,
          'emoji': _getEmojiForCategory(rawCategory),
        });
      });
    }
  }

  // ─── Gemini API Scanning ──────────────────────────────────────────────────

  Future<void> _startScan() async {
    print('==================================');
    print('_startScan called');
    print('  scanCount    : $_scanCount');
    print('  scanLimit    : $_scanLimit');
    print('  activeKey    : Key ${_currentKeyIndex + 1}');
    print('==================================');

    if (_scanState == ScanState.scanning) return;

    if (_enforceScanLimit && _scanCount >= _scanLimit) {
      if (_currentKeyIndex < _apiKeys.length - 1) {
        _currentKeyIndex++;
        globalScanCount = 0;
        await _startScan();
        return;
      } else {
        return;
      }
    }

    final source = await _showImageSourceDialog();
    if (source == null) return;

    setState(() {
      _scanState = ScanState.scanning;
      _autoFilled = false;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        setState(() => _scanState = ScanState.idle);
        return;
      }

      final imageBytes = await pickedFile.readAsBytes();
      final extension = pickedFile.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : extension == 'heic' ? 'image/heic' : 'image/jpeg';

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKeys[_currentKeyIndex],
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = TextPart("""
        You are an expert bill/receipt analyzer. Analyze this image carefully
        and extract the following into JSON.

        RULES (follow strictly):
        1. merchant — The exact name of the shop, company, app, or service.
        2. date     — Format: Month Day only (e.g. "March 18"). If not visible, return "".
        3. amount   — The final TOTAL amount as a plain number string (e.g. "485").
                      Do NOT include ₹ or Rs symbol. Just the number.
        4. category — You MUST return ONLY one of these exact category names:
                      Food, Travel, Supplies, Bills, Entertainment, Medical,
                      Education, Rent, Petrol, Electricity, Home Services
                      IMPORTANT RULES:
                      - Petrol/fuel/diesel stations → return 'Petrol'
                      - Electricity/power/EB/BESCOM/TNEB/MSEB bills → return 'Electricity'
                      - Plumber/electrician/carpenter/cleaning/Urban Company → return 'Home Services'
                      - Medical/pharmacy/hospital/clinic → return 'Medical'
                      - Grocery/supermarket/BigBasket/Zepto/DMart → return 'Supplies'
                      - Internet/WiFi/broadband/Jio/Airtel/phone bill → return 'Bills'
                      - Restaurant/food delivery/Swiggy/Zomato → return 'Food'
                      - Flight/train/bus/cab/Ola/Uber (NOT petrol) → return 'Travel'
                      - Amazon/Flipkart/shopping/clothes → return 'Supplies'
                      - Netflix/OTT/cinema/PVR → return 'Entertainment'
                      - School/college/tuition/course → return 'Education'
                      - House rent/hostel → return 'Rent'
                      - If nothing matches clearly, return 'Bills'
        5. confidence — A number 1-100 showing how confident you are.

        Return ONLY valid JSON like:
        {"merchant":"Bharat Petroleum","date":"March 18","amount":"485","category":"Petrol","confidence":98}

        No markdown, no explanation, no extra text. Just the JSON.
      """);

      final response = await model.generateContent([
        Content.multi([prompt, DataPart(mimeType, imageBytes)]),
      ]);

      if (!mounted) return;

      if (response.text != null) {
        final rawJson = jsonDecode(response.text!) as Map<String, dynamic>;
        final data = ScannedReceipt.fromJson(rawJson);

        // ── Merchant override: Apollo → Medical, BMTC → Travel, etc. ──────
        // The AI may mis-classify known merchants. Always check the merchant
        // name against our lookup table and use that result first.
        final aiFormattedCategory = _formatCategory(data.category);
        final overriddenCategory  = _resolveCategoryFromMerchant(data.merchant, aiFormattedCategory);

        _autoAddCategoryIfNew(overriddenCategory, data.category);

        setState(() {
          _scanState = ScanState.scanned;
          _scannedReceipt = data;
          _autoFilled = true;
          _selectedCategory = overriddenCategory; // ← uses override, not raw AI output
          globalScanCount += 1;
        });

        _amountController.text = data.amount;
        _merchantController.text = data.merchant;
        _dateController.text = data.date;
        _fillAnimController.forward();
      } else {
        setState(() => _scanState = ScanState.failed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Could not read receipt. Please enter manually.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanState = ScanState.failed);
      final errorMsg = e.toString();
      if (errorMsg.contains('429') || errorMsg.contains('RESOURCE_EXHAUSTED')) {
        if (_currentKeyIndex < _apiKeys.length - 1) {
          _currentKeyIndex++;
          globalScanCount = 0;
          await _startScan();
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get _displayAmount {
    final txt = _amountController.text;
    if (txt.isEmpty) return '0';
    return txt;
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2D6A5A)),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2D6A5A)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add Category Dialog ──────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    final textController = TextEditingController();
    String selectedEmoji = '📌';

    final List<String> quickEmojis = [
      '📌', '⛽', '🚗', '🏋️', '💈', '🐾', '🎁', '💻',
      '🌐', '🏖️', '👕', '☕', '🛡️', '⚡', '🥦', '🎬', '🍕', '🚌',
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'e.g. Petrol, Gym, Salon...',
                  hintStyle: const TextStyle(color: Color(0xFFB0B0B5), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF5F0EB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Pick an emoji', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8E))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickEmojis.map((e) {
                  final picked = selectedEmoji == e;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedEmoji = e),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: picked ? const Color(0xFFE8F5F0) : const Color(0xFFF5F0EB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: picked ? const Color(0xFF2D6A5A) : Colors.transparent, width: 1.5),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8E))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  final newLabel = _formatCategory(textController.text.trim());
                  setState(() {
                    _customCategories.add({'label': newLabel, 'emoji': selectedEmoji});
                    _selectedCategory = newLabel;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildAmountDisplay(),
                      const SizedBox(height: 16),
                      _buildScanBanner(),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Category'),
                      const SizedBox(height: 10),
                      _buildCategoryRow(),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Payment Method'),
                      const SizedBox(height: 10),
                      _buildPaymentMethod(),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Merchant'),
                      const SizedBox(height: 10),
                      _buildMerchantField(),
                      const SizedBox(height: 16),
                      _buildSectionLabel('Date'),
                      const SizedBox(height: 10),
                      _buildDatePickerField(),
                      const SizedBox(height: 16),
                      _buildSectionLabel('Notes (Optional)'),
                      const SizedBox(height: 10),
                      _buildTextField(_noteController, 'Add a short note...'),
                      if (_autoFilled) ...[
                        const SizedBox(height: 16),
                        _buildAutoFillBanner(),
                      ],
                      if (_scanState == ScanState.scanning) ...[
                        const SizedBox(height: 16),
                        _buildScanningOverlay(),
                      ],
                      if (_scanState == ScanState.scanned && _scannedReceipt != null) ...[
                        const SizedBox(height: 16),
                        _buildReceiptPreview(),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── UI Widgets ───────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF1C1C1E),
          ),
          const Expanded(
            child: Text(
              'Add Expense',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return GestureDetector(
      onTap: () => _showAmountInput(),
      child: Center(
        child: AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, _) {
            return Column(
              children: [
                Text(
                  '₹ $_displayAmount',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: _autoFilled ? const Color(0xFF2D6A5A) : const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Tap to enter amount', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8E))),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAmountInput() {
    final tempController = TextEditingController(text: _amountController.text);
    DateTime selectedDate = DateTime.now();
    // Parse existing date if set
    try {
      final parsed = DateFormat('MMMM d').parse(_dateController.text.trim());
      selectedDate = DateTime(DateTime.now().year, parsed.month, parsed.day);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: tempController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixText: '₹  ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF2D6A5A)),
                  filled: true,
                  fillColor: const Color(0xFFF5F0EB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              // ── Date Picker ────────────────────────────────────────────
              const Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8A8A8E))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime(DateTime.now().year + 1),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2D6A5A),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF1C1C1E),
                        ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setSheetState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2D6A5A)),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM d, yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E)),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFAAAAAA)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A5A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _amountController.text = tempController.text;
                      _dateController.text = DateFormat('MMMM d').format(selectedDate);
                      _autoFilled = false;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanBanner() {
    return GestureDetector(
      onTap: _startScan,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF3E3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDD9A3), width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scan receipt to auto-fill details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A5C00))),
                  const SizedBox(height: 3),
                  Text(
                    'Tap to open camera — Gemini AI will extract all details!',
                    style: TextStyle(fontSize: 11.5, color: const Color(0xFF7A5C00).withValues(alpha: 0.7), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFF2D6A5A), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8A8A8E), letterSpacing: 0.2),
    );
  }

  Widget _buildCategoryRow() {
    final List<Map<String, String>> allCategories = [..._baseCategories, ..._customCategories];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...allCategories.map((cat) {
            final isSelected = _selectedCategory == cat['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['label']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFEDD5) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE06B00).withValues(alpha: 0.4) : const Color(0xFFE5E0D8),
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      cat['label']!,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFE06B00) : const Color(0xFF6E6E73)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: _showAddCategoryDialog,
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 22, color: Color(0xFF2D6A5A)),
                  SizedBox(height: 4),
                  Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2D6A5A))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final Map<String, String> labels = {
      'UPI': '₹', 'CASH': '💵', 'CREDIT_CARD': '💳', 'DEBIT_CARD': '🏧', 'NET_BANKING': '🌐',
    };
    return GestureDetector(
      onTap: () => _showPaymentMethodPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: const Color(0xFFE8F5F0), borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(labels[_selectedPaymentMethod] ?? '₹',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D6A5A))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_selectedPaymentMethod.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E))),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) => ListTile(
              title: Text(method.replaceAll('_', ' '), style: const TextStyle(fontSize: 14)),
              trailing: method == _selectedPaymentMethod ? const Icon(Icons.check, color: Color(0xFF2D6A5A), size: 18) : null,
              onTap: () {
                setState(() => _selectedPaymentMethod = method);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
      ),
      child: TextField(
        controller: _merchantController,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E)),
        decoration: const InputDecoration(
          hintText: 'e.g. Amazon, Swiggy',
          hintStyle: TextStyle(color: Color(0xFFB0B0B5), fontSize: 14),
          border: InputBorder.none, isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── Date Picker Field ────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    // Parse existing date if any
    DateTime initial = DateTime.now();
    try {
      final parsed = DateFormat('MMMM d').parse(_dateController.text.trim());
      initial = DateTime(DateTime.now().year, parsed.month, parsed.day);
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D6A5A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1C1C1E),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MMMM d').format(picked);
      });
    }
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dateController.text.isEmpty ? 'e.g. April 25' : _dateController.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _dateController.text.isEmpty
                      ? const Color(0xFFB0B0B5)
                      : const Color(0xFF1C1C1E),
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2D6A5A)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B0B5), fontSize: 14),
          border: InputBorder.none, isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAutoFillBanner() {
    return FadeTransition(
      opacity: _fillAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D6A5A).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(color: Color(0xFF2D6A5A), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '✅ Detected: $_selectedCategory  •  ₹${_scannedReceipt?.amount}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E45), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      height: 130,
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _scanAnimController,
            builder: (context, _) {
              return Positioned(
                top: _scanAnimController.value * 120, left: 0, right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FD1A5).withValues(alpha: 0.8),
                    boxShadow: [BoxShadow(color: const Color(0xFF4FD1A5).withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)],
                  ),
                ),
              );
            },
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: const Color(0xFF2D6A5A), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 8),
                  Text('Gemini AI reading receipt...', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          ..._buildCornerBrackets(),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const color = Color(0xFF4FD1A5);
    const size = 18.0;
    const thick = 2.5;
    return [
      Positioned(top: 8, left: 8, child: _bracket(size, thick, color, true, true)),
      Positioned(top: 8, right: 8, child: _bracket(size, thick, color, true, false)),
      Positioned(bottom: 8, left: 8, child: _bracket(size, thick, color, false, true)),
      Positioned(bottom: 8, right: 8, child: _bracket(size, thick, color, false, false)),
    ];
  }

  Widget _bracket(double size, double thick, Color color, bool top, bool left) {
    return SizedBox(width: size, height: size, child: CustomPaint(painter: _BracketPainter(color, thick, top, left)));
  }

  Widget _buildReceiptPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E0D8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFF2D6A5A), size: 20),
              SizedBox(width: 8),
              Text('Scanned Receipt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEAE2)),
          const SizedBox(height: 10),
          ..._scannedReceipt!.lines.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text(line.label, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E73)))),
                Text(line.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E))),
              ],
            ),
          )),
          const Divider(height: 16, color: Color(0xFFEEEAE2)),
          Row(
            children: [
              const Expanded(child: Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)))),
              Text('₹ ${_scannedReceipt!.amount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D6A5A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A5A),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF2D6A5A).withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
        ),
      ),
    );
  }
}

// ─── Corner Bracket Painter ───────────────────────────────────────────────────

class _BracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  _BracketPainter(this.color, this.thickness, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height); path.lineTo(0, 0); path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0); path.lineTo(size.width, 0); path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0); path.lineTo(0, size.height); path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color || old.top != top || old.left != left;
}