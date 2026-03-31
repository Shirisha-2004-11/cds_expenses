import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ScannedReceipt {
  final String amount;
  final String merchant;
  final String date;
  final String category;
  final int confidence;

  ScannedReceipt({
    required this.amount,
    required this.merchant,
    required this.date,
    required this.category,
    required this.confidence,
  });

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) {
    return ScannedReceipt(
      amount: json['amount']?.toString() ?? "0",
      merchant: json['merchant']?.toString() ?? "",
      date: json['date']?.toString() ?? "",
      category: json['category']?.toString().toLowerCase() ?? "food",
      confidence: json['confidence'] ?? 0,
    );
  }
}

// ─── UI SCREEN ──────────────────────────────────────────────────────────────
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // 🔑 API KEY - Replace with yours from Google AI Studio
  static const String _apiKey = 'AIzaSyBYJ4X4EKzN7dXvCPqlb0TIZTRIKLLW2Z8';

  // State Variables
  // ignore: unused_field
  File? _selectedImage;
  bool _isScanning = false;
  bool _isAutoFilled = false;
  String _selectedCategory = "food";

  // Controllers
  final TextEditingController _amountController = TextEditingController(
    text: "0",
  );
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // ─── GEMINI INTEGRATION LOGIC ──────────────────────────────────────────────
  Future<void> _scanReceipt() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return;

    setState(() {
      _selectedImage = File(photo.path);
      _isScanning = true;
      _isAutoFilled = false;
    });

    try {
      final imageBytes = await photo.readAsBytes();

      // Initialize Gemini 1.5 Flash with JSON Output mode
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = TextPart("""
        Analyze this bill image and extract details into JSON.
        Fields required:
        - merchant (Name of shop/app)
        - date (Format: Month Day, e.g. April 25)
        - amount (Total numeric value as string)
        - category (Strictly one of: 'food', 'travel', 'supplies', 'bills')
        - confidence (Percentage 1-100)
        Return ONLY valid JSON.
      """);

      final response = await model.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', imageBytes)]),
      ]);

      if (response.text != null) {
        final data = ScannedReceipt.fromJson(jsonDecode(response.text!));

        setState(() {
          _amountController.text = data.amount;
          _merchantController.text = data.merchant;
          _dateController.text = data.date;
          _selectedCategory = data.category;
          _isAutoFilled = true;
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Scan Error: $e")));
    }
  }

  // ─── UI BUILDER ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Amount Display
            Text(
              "₹ ${_amountController.text}",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 25),

            // Scan Banner
            _buildScanBanner(),

            if (_isScanning)
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: LinearProgressIndicator(color: Color(0xFF2D6A5A)),
              ),

            const SizedBox(height: 25),
            _buildFieldLabel("Category"),
            _buildCategoryRow(),

            const SizedBox(height: 20),
            _buildFieldLabel("Merchant"),
            _buildTextField(
              _merchantController,
              "e.g. Swiggy, Starbucks",
              Icons.store,
            ),

            const SizedBox(height: 20),
            _buildFieldLabel("Date"),
            _buildTextField(
              _dateController,
              "April 25",
              Icons.calendar_today,
              isAuto: _isAutoFilled,
            ),

            const SizedBox(height: 20),
            _buildFieldLabel("Notes"),
            _buildTextField(
              _notesController,
              "Lunch with team...",
              Icons.notes,
            ),

            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ─── UI HELPERS ────────────────────────────────────────────────────────────
  Widget _buildScanBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEDD9A3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF2D6A5A), size: 30),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Scan receipt to auto-fill",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "AI will extract all details automatically",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _scanReceipt,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A5A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    final List<Map<String, dynamic>> cats = [
      {
        "id": "food",
        "icon": "🍔",
        "label": "Food",
        "color": const Color(0xFFFFEDD5),
      },
      {
        "id": "travel",
        "icon": "✈️",
        "label": "Travel",
        "color": const Color(0xFFDCEEFF),
      },
      {
        "id": "supplies",
        "icon": "📦",
        "label": "Supplies",
        "color": const Color(0xFFF0EDFF),
      },
      {
        "id": "bills",
        "icon": "💜",
        "label": "Bills",
        "color": const Color(0xFFFFE4F5),
      },
    ];

    return Row(
      children: cats.map((c) {
        bool isSelected = _selectedCategory == c['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = c['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? c['color'] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  Text(c['icon'], style: const TextStyle(fontSize: 18)),
                  Text(
                    c['label'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isAuto = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, size: 20, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: isAuto
              ? const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "✨ Auto",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D6A5A),
          shape: const StadiumBorder(),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Save Expense",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}