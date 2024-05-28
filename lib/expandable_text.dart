import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late String firstPart;
  late String remainingPart;
  bool isExpanded = false;
  int trimLength = 250;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > trimLength) {
      firstPart = widget.text.substring(0, trimLength);
      remainingPart = widget.text.substring(trimLength);
    } else {
      firstPart = widget.text;
      remainingPart = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? widget.text : (firstPart + '...'),
          style: TextStyle(fontSize: 16),
        ),
        InkWell(
          onTap: toggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isExpanded ? 'Read less' : 'Read more',
                style: TextStyle(color: Colors.blue, fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void toggle() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}