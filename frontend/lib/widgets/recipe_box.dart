import 'package:flutter/material.dart';

class Recipebox extends StatelessWidget {
  final Map<String, dynamic> recipeItem;

  const Recipebox({
    super.key,
    required this.recipeItem,
  });

  // A RECOMMEND BOX MODAL
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/${recipeItem['foodImg']}${recipeItem['foodImgNumber']}.png',
                      width: 150,
                      height: 150,
                    ),
                    Text(
                      recipeItem['foodName'],
                      style: const TextStyle(
                        color: Color(0xFF8EC96D),
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GmarketSans',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '재료 : ',
                        style: TextStyle(
                          color: Color(0xFFBCBCBC),
                          fontFamily: 'GmarketSans',
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            for (int i = 0;
                                i < recipeItem['ingredient'].length;
                                i++) ...[
                              Text(
                                recipeItem['ingredient'][i].toString(),
                                style: const TextStyle(
                                  color: Color(0xFFBCBCBC),
                                  fontFamily: 'GmarketSans',
                                ),
                              ),
                              if (i < recipeItem['ingredient'].length - 1)
                                const Text(
                                  ',',
                                  style: TextStyle(
                                    color: Color(0xFFBCBCBC),
                                    fontFamily: 'GmarketSans',
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var step in recipeItem['recipe'])
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                step.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'GmarketSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8EC96D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Text(
                      '닫기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'GmarketSans',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // A RECOMMEND BOX
  @override
  Widget build(BuildContext context) {
    final foodName = recipeItem['foodName'];
    final foodImg = recipeItem['foodImg'];
    final foodImgNumber = recipeItem['foodImgNumber'];

    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
          child: Column(
            children: [
              Image.asset(
                width: 80,
                height: 80,
                'assets/images/$foodImg$foodImgNumber.png',
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                foodName,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'GmarketSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
