import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/emissions_api_service.dart';
import '../../services/ml_service_io.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'emission_result_screen.dart';

class EmissionLoggerScreen extends StatefulWidget {
  const EmissionLoggerScreen({super.key});

  @override
  State<EmissionLoggerScreen> createState() => _EmissionLoggerScreenState();
}

class _EmissionLoggerScreenState extends State<EmissionLoggerScreen> {
  final _apiService = EmissionsApiService();
  final _mlService = MLService();

  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _modelFocus = FocusNode();
  final _yearFocus = FocusNode();
  String _lastModelQuery = '';
  final _daysUsedCtrl = TextEditingController();
  int? _selectedHours;
  int? _selectedMinutes;

  List<Map<String, dynamic>> _cachedModels = [];
  List<String> _availableYears = [];

  bool _isLoading = false;
  String _statusMessage = '';

  String _capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _initMlService();
  }

  Future<void> _initMlService() async {
    await _mlService.init();
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _modelFocus.dispose();
    _yearFocus.dispose();
    _daysUsedCtrl.dispose();
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _calculateAndLogEmissions() async {
    final modelInput = _modelCtrl.text.trim();
    final yearInput = _yearCtrl.text.trim();
    final daysInput = double.tryParse(_daysUsedCtrl.text.trim());
    final hoursInput = (_selectedHours ?? 0) + ((_selectedMinutes ?? 0) / 60.0);

    if (modelInput.isEmpty ||
        yearInput.isEmpty ||
        daysInput == null ||
        hoursInput <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching vehicle specifications...';
    });

    // 1. Fetch parameters from API
    final specs = await _apiService.getVehicleSpecs(modelInput, yearInput);
    if (specs == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve vehicle specs. Check Make/Model.'),
        ),
      );
      return;
    }

    setState(() {
      _statusMessage = 'Calculating Emissions via ML Model...';
    });

    // 2. TFLite Prediction (All 3 Models)
    int yInt = int.tryParse(yearInput) ?? 2010;
    int calculatedAge = DateTime.now().year - yInt;
    if (calculatedAge < 0) calculatedAge = 0;

    int getFuelTypeNew(int originalFuelType) {
      if (originalFuelType == 4) return 0; // Electric
      if (originalFuelType == 2) return 3; // Diesel
      // Treat everything else as Petrol/Hybrid. For fallback:
      return 2; // Petrol
    }

    final double? totalEmissionsOriginal = await _mlService
        .predictEmissionsOriginal(
          specs['engine_size'],
          specs['cylinders'],
          specs['fuel_type'],
          daysInput,
          hoursInput,
        );

    final double? totalEmissionsHeuristic = await _mlService
        .predictEmissionsHeuristic(
          specs['engine_size'],
          specs['cylinders'],
          specs['fuel_type'],
          yInt,
          daysInput,
          hoursInput,
        );

    final double? totalEmissionsNew = await _mlService.predictEmissionsNew(
      specs['engine_size'],
      calculatedAge,
      getFuelTypeNew(specs['fuel_type']),
      daysInput,
      hoursInput,
    );

    if (totalEmissionsOriginal == null ||
        totalEmissionsHeuristic == null ||
        totalEmissionsNew == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error predicting emissions locally')),
      );
      return;
    }

    setState(() {
      _statusMessage = 'Logging to Firebase...';
    });

    final double totalEmissionsAvg =
        (totalEmissionsOriginal + totalEmissionsHeuristic + totalEmissionsNew) /
        3;

    // 3. Save to Firebase
    try {
      await FirestoreService.instance.logVehicleEmission(
        totalEmissionGrams: totalEmissionsAvg,
        model: modelInput,
        year: yearInput,
        daysUsed: daysInput,
        hoursPerDay: hoursInput,
      );

      setState(() => _isLoading = false);

      final double kgOriginal = totalEmissionsOriginal / 1000;
      final double kgHeuristic = totalEmissionsHeuristic / 1000;
      final double kgNew = totalEmissionsNew / 1000;
      final double kgAvg = totalEmissionsAvg / 1000;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmissionResultScreen(
            emissionKg: kgAvg,
            emissionKgOriginal: kgOriginal,
            emissionKgHeuristic: kgHeuristic,
            emissionKgNew: kgNew,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log to Firebase')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.h.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Log Emissions',
          style: AppTextStyles.headlineMedium.copyWith(
            color: context.h.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: context.h.textPrimary),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.green),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.h.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Estimate your CO2 emissions based on your car specifications and usage using our accurate database and ML engine.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.h.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildInputLabel('Vehicle Model'),
                  RawAutocomplete<String>(
                    textEditingController: _modelCtrl,
                    focusNode: _modelFocus,
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      String query = textEditingValue.text;
                      if (query.length < 3)
                        return const Iterable<String>.empty();

                      _lastModelQuery = query;
                      await Future.delayed(const Duration(milliseconds: 250));
                      if (_lastModelQuery != query)
                        return const Iterable<String>.empty();

                      final results = await _apiService.searchVehicles(query);
                      _cachedModels = results;
                      final uniqueNames = results
                          .map((e) => _capitalizeWords(e['name'].toString()))
                          .toSet()
                          .toList();
                      return uniqueNames;
                    },
                    onSelected: (String selection) {
                      _modelCtrl.text = selection;
                      final matched = _cachedModels
                          .where(
                            (e) =>
                                _capitalizeWords(e['name'].toString()) ==
                                selection,
                          )
                          .toList();
                      _availableYears = matched
                          .map((e) => e['year'].toString())
                          .toSet()
                          .toList();
                      _availableYears.sort(
                        (a, b) => b.compareTo(a),
                      ); // Descending
                      setState(() {});
                    },
                    fieldViewBuilder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return _buildTextField(
                            textEditingController,
                            'Search e.g. Honda Civic',
                            focusNode: focusNode,
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(14),
                          color: context.h.card,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 250,
                              maxWidth: MediaQuery.of(context).size.width - 40,
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: context.h.divider, height: 1),
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      option,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: context.h.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Make Year'),
                  RawAutocomplete<String>(
                    textEditingController: _yearCtrl,
                    focusNode: _yearFocus,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (_availableYears.isEmpty)
                        return const Iterable<String>.empty();
                      return _availableYears.where(
                        (y) => y.contains(textEditingValue.text),
                      );
                    },
                    onSelected: (String selection) {
                      _yearCtrl.text = selection;
                    },
                    fieldViewBuilder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return _buildTextField(
                            textEditingController,
                            'Type or select a year',
                            isNumber: true,
                            focusNode: focusNode,
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(14),
                          color: context.h.card,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth: MediaQuery.of(context).size.width - 40,
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: context.h.divider, height: 1),
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      option,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: context.h.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Days Used'),
                  _buildTextField(
                    _daysUsedCtrl,
                    'e.g. 30',
                    isNumber: true,
                    allowDecimal: true,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Avg Time Used / Day'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeDropdown(
                          value: _selectedHours,
                          hint: 'Hrs',
                          items: List.generate(25, (i) => i),
                          onChanged: (val) =>
                              setState(() => _selectedHours = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeDropdown(
                          value: _selectedMinutes,
                          hint: 'Mins',
                          items: List.generate(60, (i) => i),
                          onChanged: (val) =>
                              setState(() => _selectedMinutes = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _calculateAndLogEmissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: AppColors.black,
                          width: 2,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Calculate & Log',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: context.h.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    bool allowDecimal = false,
    FocusNode? focusNode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.h.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: isNumber
            ? TextInputType.numberWithOptions(decimal: allowDecimal)
            : TextInputType.text,
        inputFormatters: isNumber && !allowDecimal
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: AppTextStyles.bodyLarge.copyWith(color: context.h.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: context.h.textSecondary.withValues(alpha: 0.5),
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTimeDropdown({
    required int? value,
    required String hint,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.h.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        items: items.map((i) {
          return DropdownMenuItem<int>(
            value: i,
            child: Text(
              '$i $hint',
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.h.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: context.h.card,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: context.h.textSecondary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: context.h.textSecondary.withValues(alpha: 0.5),
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
