import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final String title;
  final Map<String, List<String>> fields;
  final Function(Map<String, String?>) onFilterChanged;
  final bool isModal;
  final VoidCallback? onClose;
  final Map<String, String?> initialFilters;

  const FilterWidget({
    super.key,
    required this.title,
    required this.fields,
    required this.onFilterChanged,
    this.isModal = false,
    this.onClose,
    required this.initialFilters,
  });

  @override
  FilterWidgetState createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> with SingleTickerProviderStateMixin {
  Map<String, String?> _selectedValues = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _selectedValues = Map.from(widget.initialFilters.isNotEmpty ? widget.initialFilters : {for (var key in widget.fields.keys) key: null});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isLandscape = orientation == Orientation.landscape;

        final maxHeight = isLandscape ? screenHeight * 0.9 : screenHeight * 0.8;

        Widget filterContent = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ...widget.fields.entries.map((entry) => _buildDropdown(entry.key, entry.value, isLandscape)),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextButton(
                      onPressed: () {
                        if (mounted) {
                          _resetFilters();
                        }
                      },
                      child: Text(
                        "Đặt lại",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ElevatedButton(
                      onPressed: () {
                        if (mounted) {
                          widget.onFilterChanged(_selectedValues);
                          if (widget.isModal) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.015),
                        ),
                      ),
                      child: Text(
                        "Áp dụng",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        Widget contentWithScroll = SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          physics: const ClampingScrollPhysics(),
          child: filterContent,
        );

        return widget.isModal
            ? Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.015),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  child: contentWithScroll,
                ),
              ),
            ),
          ),
        )
            : Card(
          elevation: 4,
          margin: EdgeInsets.all(screenWidth * 0.03),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.015),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: isLandscape ? screenHeight * 0.7 : screenHeight * 0.6,
                  ),
                  child: contentWithScroll,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown(String field, List<String> options, bool isLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tăng khoảng cách dọc giữa các Dropdown khi xoay ngang
    final verticalPadding = isLandscape ? screenHeight * 0.02 : screenHeight * 0.01;
    // Tăng chiều cao Dropdown khi xoay ngang
    final dropdownHeightPadding = isLandscape ? screenHeight * 0.050 : screenHeight * 0.015;
    // Điều chỉnh kích thước text: nhỏ hơn khi xoay ngang
    final sizeText = isLandscape ? screenWidth * 0.03 : screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SizedBox(
            width: screenWidth * 0.9,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: field,
                labelStyle: TextStyle(color: Colors.blueGrey, fontSize: sizeText), // Áp dụng sizeText cho label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: dropdownHeightPadding, // Điều chỉnh chiều cao
                ),
              ),
              value: _selectedValues[field],
              items: [
                DropdownMenuItem(value: null, child: Text("Tất cả", style: TextStyle(fontSize: sizeText))),
                ...options.map((option) => DropdownMenuItem(value: option, child: Text(option, style: TextStyle(fontSize: sizeText)))),
              ],
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _selectedValues[field] = value;
                  });
                }
              },
              validator: (value) => value == null && !widget.fields[field]!.contains("Tất cả") ? "Vui lòng chọn một tùy chọn" : null,
            ),
          ),
        ),
      ),
    );
  }
  void _resetFilters() {
    if (mounted) {
      setState(() {
        _selectedValues = Map.from(widget.initialFilters.isNotEmpty ? widget.initialFilters : {for (var key in widget.fields.keys) key: null});
      });
      widget.onFilterChanged(_selectedValues);
      if (widget.isModal) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}