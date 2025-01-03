import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for state management

class DropdownController extends GetxController {
  var selectedOptionList = <String>[].obs;
  var selectedOption = ''.obs;

  // Method to clear selected options
  void clearSelection() {
    selectedOptionList = <String>[].obs;
    selectedOption.value = '';
  }
}

class Checklist extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final void Function(List<String>)? onSelectionChanged;
  final DropdownController controller;

  const Checklist({
    super.key,
    required this.options,
    required this.hintText,
    required this.controller,
    this.onSelectionChanged,
  });

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showMultiSelectDialog(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white, // White background
                ),
                child: Obx(() => widget.controller.selectedOptionList.isEmpty
                    ? Text(
                        widget.hintText,
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            widget.controller.selectedOptionList.map((option) {
                          return Chip(
                            label: Text(
                              option,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.orange[900], // Orange color
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              widget.controller.selectedOptionList
                                  .remove(option);
                              widget.controller.selectedOption.value = widget
                                  .controller.selectedOptionList
                                  .join(', ');
                              if (widget.onSelectionChanged != null) {
                                widget.onSelectionChanged!(
                                    widget.controller.selectedOptionList);
                              }
                            },
                          );
                        }).toList(),
                      )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Services',
            style: TextStyle(color: Colors.orange[900]),
          ),
          backgroundColor: Colors.grey[200],
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.options.map((option) {
                return Obx(() => CheckboxListTile(
                      title: Text(
                        option,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      value:
                          widget.controller.selectedOptionList.contains(option),
                      onChanged: (bool? value) {
                        if (value == true) {
                          widget.controller.selectedOptionList.add(option);
                        } else {
                          widget.controller.selectedOptionList.remove(option);
                        }
                        widget.controller.selectedOption.value =
                            widget.controller.selectedOptionList.join(', ');
                        if (widget.onSelectionChanged != null) {
                          widget.onSelectionChanged!(
                              widget.controller.selectedOptionList);
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors
                          .grey[600], // Color for the checkbox when selected
                      checkColor: Colors.white, // Color for the check mark
                    ));
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
