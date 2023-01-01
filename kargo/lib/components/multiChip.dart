import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> labels;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip({required this.labels,required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> _selected = [];
    void initState() {

_selected=_selected.where((element) => widget.labels.contains(element)).toList();
    super.initState();
  }

_buildChip(String label) {
  return FilterChip(
    label: Text(label),
    selected: _selected.contains(label),
    onSelected: (selected) {
      setState(() {
       
        if (selected) {
          _selected.add(label);
        } else {
          _selected.remove(label);
        }
        widget.onSelectionChanged(_selected);
      });
    },
  );
}

  @override
Widget build(BuildContext context) {
  _selected=_selected.where((element) => widget.labels.contains(element)).toList();
  return Wrap(
    spacing: 8,
    children: widget.labels.map((label) => _buildChip(label)).cast<Widget>().toList()
  );
}
}