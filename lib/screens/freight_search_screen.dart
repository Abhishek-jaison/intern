import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class FreightSearchScreen extends StatefulWidget {
  const FreightSearchScreen({super.key});

  @override
  State<FreightSearchScreen> createState() => _FreightSearchScreenState();
}

class _FreightSearchScreenState extends State<FreightSearchScreen> {
  // Form controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _boxesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<String> _originSuggestions = [];
  List<String> _destinationSuggestions = [];
  bool _showOriginSuggestions = false;
  bool _showDestinationSuggestions = false;

  Future<List<String>> _fetchUniversities(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?name=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((uni) => uni['name'].toString()).toList();
    }
    return [];
  }

  void _onOriginChanged(String value) async {
    setState(() {
      _showOriginSuggestions = true;
    });
    _originSuggestions = await _fetchUniversities(value);
    setState(() {});
  }

  void _onDestinationChanged(String value) async {
    setState(() {
      _showDestinationSuggestions = true;
    });
    _destinationSuggestions = await _fetchUniversities(value);
    setState(() {});
  }
  DateTime? _cutOffDate;
  bool _includeNearbyOrigin = false;
  bool _includeNearbyDestination = false;
  bool _isFCL = false;
  bool _isLCL = false;
  String? _selectedContainerSize;
  String? _selectedCommodity;

  // Container dimensions (hardcoded for this example)
  final Map<String, Map<String, String>> _containerDimensions = {
    '20" DC': {
      'Internal Length': '5.89 M',
      'Internal Width': '2.35 M',
      'Internal Height': '2.38 M',
    },
    '40" DC': {
      'Internal Length': '12.05 M',
      'Internal Width': '2.35 M',
      'Internal Height': '2.38 M',
    },
    '40" HC': {
      'Internal Length': '12.05 M',
      'Internal Width': '2.35 M',
      'Internal Height': '2.69 M',
    },
    '45" HC': {
      'Internal Length': '13.55 M',
      'Internal Width': '2.35 M',
      'Internal Height': '2.69 M',
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 234, 248, 1), // Light purple background
      appBar: AppBar(
        title: Text(
          'Search the best Freight Rates',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'History',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Origin and Destination Fields in same row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _originController,
                            onChanged: _onOriginChanged,
                            decoration: InputDecoration(
                              labelText: 'Origin',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                            ),
                          ),
                          if (_showOriginSuggestions && _originSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _originSuggestions.take(3).map((suggestion) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _originController.text = suggestion;
                                      _showOriginSuggestions = false;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      suggestion,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _destinationController,
                            onChanged: _onDestinationChanged,
                            decoration: InputDecoration(
                              labelText: 'Destination',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                            ),
                          ),
                          if (_showDestinationSuggestions && _destinationSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _destinationSuggestions.take(3).map((suggestion) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _destinationController.text = suggestion;
                                      _showDestinationSuggestions = false;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      suggestion,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Checkboxes below the fields
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _includeNearbyOrigin,
                              onChanged: (value) => setState(() => _includeNearbyOrigin = value ?? false),
                              activeColor: Colors.blue[300],
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Include nearby origin ports',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _includeNearbyDestination,
                              onChanged: (value) => setState(() => _includeNearbyDestination = value ?? false),
                              activeColor: Colors.blue[300],
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Include nearby destination ports',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Commodity Dropdown and Cut-off Date
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Commodity',
                        value: _selectedCommodity,
                        items: _commodities,
                        onChanged: (value) => setState(() => _selectedCommodity = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField('Cut Off Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Shipment Type
                Text(
                  'Shipment Type :',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isFCL,
                            onChanged: (value) => setState(() => _isFCL = value ?? false),
                            activeColor: Colors.blue[300],
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FCL',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isLCL,
                            onChanged: (value) => setState(() => _isLCL = value ?? false),
                            activeColor: Colors.blue[300],
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LCL',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Container Size, Boxes and Weight in one row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Container Size',
                        value: _selectedContainerSize,
                        items: _containerSizes,
                        onChanged: (value) => setState(() => _selectedContainerSize = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _boxesController,
                        decoration: InputDecoration(
                          labelText: 'No of Boxes',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (Kg)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Weight note
                Text(
                  'To obtain accurate rate for spot rate with guaranteed space and booking, please ensure your container count and weight per container is accurate.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Container Dimensions
                Text(
                  'Container Internal Dimensions :',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContainerDimensions(),
                const SizedBox(height: 24),

                // Search Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search',
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  final List<String> _containerSizes = [
    '20" DC',
    '40" DC',
    '40" HC',
    '45" HC',
    '20" FR',
    '40" FR',
    '20" OT',
    '40" OT',
    '20" RF',
    '40" RF',
  ];

  final List<String> _commodities = [
    'General Cargo',
    'Hazardous Goods',
    'Perishables',
    'Electronics',
    'Textiles',
    'Machinery',
    'Chemicals',
    'Food Products',
  ];

  Widget _buildDropdownField(String label, {String? value, required List<String> items, required void Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(color: Colors.grey[700]),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(String label) {
    return TextField(
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _cutOffDate = date);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
      ),
      controller: TextEditingController(
        text: _cutOffDate != null
            ? DateFormat('yyyy-MM-dd').format(_cutOffDate!)
            : '',
      ),
    );
  }


  Widget _buildContainerDimensions() {
    // Use selected container dimensions or default to 20" DC
    final dimensions = _containerDimensions[_selectedContainerSize] ?? _containerDimensions['20" DC']!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Internal Dimensions',
        //   style: GoogleFonts.inter(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500,
        //     color: Colors.grey[800],
        //   ),
        // ),
        // const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dimensions.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(width: 32),
            Image.asset(
              'container_image.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
    );
  }

}
