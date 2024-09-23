import 'package:flutter/material.dart';

class FoodCounter extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final ValueChanged<int> onChanged;

  const FoodCounter({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  State<FoodCounter> createState() => _FoodCounterState();
}

class _FoodCounterState extends State<FoodCounter> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(counter > widget.minValue
                  ? Color(0xFF8EC96D)
                  : Color(0xFFDCF0D1)),
            ),
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
            icon: Icon(
              Icons.remove,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: 148,
            height: 54,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFCBCBCB)),
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFFF9F9F9),
            ),
            child: Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF232323),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(counter == widget.maxValue
                  ? Color(0xFFDCF0D1)
                  : Color(0xFF8EC96D)),
            ),
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
              });
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
