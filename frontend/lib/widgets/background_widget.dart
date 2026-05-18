import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool showSOS; // 是否显示S.O.S.字样

  const BackgroundWidget({
    super.key,
    required this.child,
    this.showSOS = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 半透明黑色覆盖，使文字更清晰
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // S.O.S. 字样
          if (showSOS)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: Text(
                    'S.O.S.',
                    style: TextStyle(
                      fontSize: 500,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300]!.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
            ),
          // 子组件
          child,
        ],
      ),
    );
  }
}
