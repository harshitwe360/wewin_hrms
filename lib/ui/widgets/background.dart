  import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/config/r.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height/2.6,
            child: SvgPicture.asset(
                R.icon.ssLogoSvg, // height: 166,
                // width: 400,
                fit: BoxFit.fill,
                semanticsLabel: R.strings.btnFilter
            ),
          ),

          // RepaintBoundary(
          //   child: ClipPath(
          //     clipper: BackgroundCanvas(),
          //     child: Container(
          //       color: AppColors.bgVector,
          //     height: MediaQuery.of(context).size.height/2.6,
          //   )),
          // )
        ],
      ),
    );
    /*return Container(
      height: MediaQuery.of(context).size.height,
      // color: Theme.of(context).backgroundColor,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          // Expanded(child: Container()),
          ClipPath(
            clipper: BackgroundCanvas(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: aquaGradients,
                    begin: Alignment.center,
                    end: Alignment.bottomRight),
              ),
              height: MediaQuery.of(context).size.height / 2,
            ),
          ),
        ],
      ),
    );*/
  }

}
class BackgroundCanvas extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling = size.width / 350;
    final double yScaling = size.height / 280;
    path.lineTo(525.054 * xScaling,197.85 * yScaling);
    path.cubicTo(519.374 * xScaling,169.485 * yScaling,505.412 * xScaling,143.441 * yScaling,484.934 * xScaling,123.01 * yScaling,);
    path.cubicTo(458.345 * xScaling,96.3161 * yScaling,422.48 * xScaling,80.9128 * yScaling,384.814 * xScaling,80.01 * yScaling,);
    path.cubicTo(364.287 * xScaling,79.6476 * yScaling,343.893 * xScaling,83.3615 * yScaling,324.812 * xScaling,90.9366 * yScaling,);
    path.cubicTo(305.731 * xScaling,98.5116 * yScaling,288.342 * xScaling,109.797 * yScaling,273.654 * xScaling,124.14 * yScaling,);
    path.cubicTo(269.401 * xScaling,128.282 * yScaling,265.394 * xScaling,132.67 * yScaling,261.654 * xScaling,137.28 * yScaling,);
    path.cubicTo(259.975 * xScaling,139.292 * yScaling,259.055 * xScaling,141.829 * yScaling,259.055 * xScaling,144.45 * yScaling,);
    path.cubicTo(259.055 * xScaling,147.071 * yScaling,259.975 * xScaling,149.608 * yScaling,261.654 * xScaling,151.62 * yScaling,);
    path.cubicTo(272.414 * xScaling,164.43 * yScaling,282.804 * xScaling,177.76 * yScaling,293.054 * xScaling,190.85 * yScaling,);
    path.cubicTo(298.364 * xScaling,197.58 * yScaling,303.584 * xScaling,204.27 * yScaling,308.704 * xScaling,210.68 * yScaling,);
    path.cubicTo(312.045 * xScaling,198.693 * yScaling,318.557 * xScaling,187.828 * yScaling,327.554 * xScaling,179.23 * yScaling,);
    path.cubicTo(334.868 * xScaling,172.072 * yScaling,343.528 * xScaling,166.434 * yScaling,353.033 * xScaling,162.641 * yScaling,);
    path.cubicTo(362.538 * xScaling,158.848 * yScaling,372.701 * xScaling,156.975 * yScaling,382.934 * xScaling,157.13 * yScaling,);
    path.cubicTo(400.711 * xScaling,157.71 * yScaling,417.603 * xScaling,165.024 * yScaling,430.191 * xScaling,177.589 * yScaling,);
    path.cubicTo(442.779 * xScaling,190.155 * yScaling,450.122 * xScaling,207.034 * yScaling,450.734 * xScaling,224.81 * yScaling,);
    path.cubicTo(450.988 * xScaling,234.081 * yScaling,449.378 * xScaling,243.308 * yScaling,445.998 * xScaling,251.945 * yScaling,);
    path.cubicTo(442.618 * xScaling,260.581 * yScaling,437.537 * xScaling,268.45 * yScaling,431.058 * xScaling,275.086 * yScaling,);
    path.cubicTo(424.578 * xScaling,281.721 * yScaling,416.832 * xScaling,286.987 * yScaling,408.278 * xScaling,290.571 * yScaling,);
    path.cubicTo(399.724 * xScaling,294.155 * yScaling,390.538 * xScaling,295.984 * yScaling,381.264 * xScaling,295.95 * yScaling,);
    path.cubicTo(375.684 * xScaling,295.796 * yScaling,370.204 * xScaling,294.431 * yScaling,365.204 * xScaling,291.95 * yScaling,);
    path.cubicTo(368.704 * xScaling,284.28 * yScaling,371.604 * xScaling,276.34 * yScaling,374.424 * xScaling,268.36 * yScaling,);
    path.cubicTo(376.46 * xScaling,268.657 * yScaling,378.516 * xScaling,268.807 * yScaling,380.574 * xScaling,268.81 * yScaling,);
    path.cubicTo(391.112 * xScaling,268.807 * yScaling,401.271 * xScaling,264.879 * yScaling,409.07 * xScaling,257.791 * yScaling,);
    path.cubicTo(416.869 * xScaling,250.704 * yScaling,421.749 * xScaling,240.966 * yScaling,422.757 * xScaling,230.476 * yScaling,);
    path.cubicTo(423.765 * xScaling,219.986 * yScaling,420.83 * xScaling,209.497 * yScaling,414.524 * xScaling,201.054 * yScaling,);
    path.cubicTo(408.218 * xScaling,192.61 * yScaling,398.993 * xScaling,186.819 * yScaling,388.648 * xScaling,184.809 * yScaling,);
    path.cubicTo(378.304 * xScaling,182.798 * yScaling,367.581 * xScaling,184.713 * yScaling,358.572 * xScaling,190.18 * yScaling,);
    path.cubicTo(349.562 * xScaling,195.647 * yScaling,342.912 * xScaling,204.273 * yScaling,339.918 * xScaling,214.377 * yScaling,);
    path.cubicTo(336.924 * xScaling,224.481 * yScaling,337.801 * xScaling,235.338 * yScaling,342.378 * xScaling,244.831 * yScaling,);
    path.cubicTo(346.955 * xScaling,254.323 * yScaling,354.904 * xScaling,261.77 * yScaling,364.674 * xScaling,265.72 * yScaling,);
    path.cubicTo(362.064 * xScaling,272.91 * yScaling,359.364 * xScaling,280.08 * yScaling,356.234 * xScaling,286.93 * yScaling,);
    path.cubicTo(348.084 * xScaling,281.65 * yScaling,339.614 * xScaling,274.33 * yScaling,330.924 * xScaling,265.72 * yScaling,);
    path.cubicTo(312.076 * xScaling,245.75 * yScaling,294.362 * xScaling,224.741 * yScaling,277.864 * xScaling,202.79 * yScaling,);
    path.cubicTo(240.414 * xScaling,155.05 * yScaling,201.994 * xScaling,105.95 * yScaling,153.784 * xScaling,87.55 * yScaling,);
    path.cubicTo(151.467 * xScaling,86.6494 * yScaling,148.918 * xScaling,86.5365 * yScaling,146.53 * xScaling,87.2287 * yScaling,);
    path.cubicTo(144.143 * xScaling,87.9209 * yScaling,142.05 * xScaling,89.3797 * yScaling,140.574 * xScaling,91.38 * yScaling,);
    path.cubicTo(129.304 * xScaling,106.78 * yScaling,118.774 * xScaling,121.53 * yScaling,109.264 * xScaling,135.38 * yScaling,);
    path.cubicTo(102.984 * xScaling,144.6 * yScaling,97.5737 * xScaling,152.81 * yScaling,92.9137 * xScaling,160.14 * yScaling,);
    path.cubicTo(99.6192 * xScaling,158.09 * yScaling,106.592 * xScaling,157.049 * yScaling,113.604 * xScaling,157.05 * yScaling,);
    path.cubicTo(128.844 * xScaling,157.05 * yScaling,146.164 * xScaling,169.41 * yScaling,163.944 * xScaling,187.2 * yScaling,);
    path.cubicTo(182.812 * xScaling,207.166 * yScaling,200.54 * xScaling,228.179 * yScaling,217.044 * xScaling,250.14 * yScaling,);
    path.cubicTo(241.204 * xScaling,280.99 * yScaling,265.774 * xScaling,312.37 * yScaling,293.134 * xScaling,335.68 * yScaling,);
    path.cubicTo(283.35 * xScaling,337.894 * yScaling,273.461 * xScaling,339.613 * yScaling,263.504 * xScaling,340.83 * yScaling,);
    path.cubicTo(244.864 * xScaling,343.091 * yScaling,226.099 * xScaling,344.16 * yScaling,207.324 * xScaling,344.03 * yScaling,);
    path.cubicTo(207.324 * xScaling,344.03 * yScaling,203.534 * xScaling,344.03 * yScaling,203.534 * xScaling,344.03 * yScaling,);
    path.cubicTo(209.835 * xScaling,339.501 * yScaling,215.788 * xScaling,334.507 * yScaling,221.344 * xScaling,329.09 * yScaling,);
    path.cubicTo(225.596 * xScaling,324.948 * yScaling,229.603 * xScaling,320.56 * yScaling,233.344 * xScaling,315.95 * yScaling,);
    path.cubicTo(235.017 * xScaling,313.936 * yScaling,235.934 * xScaling,311.399 * yScaling,235.934 * xScaling,308.78 * yScaling,);
    path.cubicTo(235.934 * xScaling,306.161 * yScaling,235.017 * xScaling,303.625 * yScaling,233.344 * xScaling,301.61 * yScaling,);
    path.cubicTo(222.544 * xScaling,288.47 * yScaling,212.104 * xScaling,275.2 * yScaling,201.854 * xScaling,262.1 * yScaling,);
    path.cubicTo(196.574 * xScaling,255.333 * yScaling,191.357 * xScaling,248.713 * yScaling,186.204 * xScaling,242.24 * yScaling,);
    path.cubicTo(182.885 * xScaling,254.234 * yScaling,176.369 * xScaling,265.101 * yScaling,167.354 * xScaling,273.68 * yScaling,);
    path.cubicTo(160.052 * xScaling,280.878 * yScaling,151.392 * xScaling,286.553 * yScaling,141.878 * xScaling,290.376 * yScaling,);
    path.cubicTo(132.365 * xScaling,294.199 * yScaling,122.186 * xScaling,296.094 * yScaling,111.934 * xScaling,295.95 * yScaling,);
    path.cubicTo(101.394 * xScaling,295.726 * yScaling,91.0432 * xScaling,293.104 * yScaling,81.6682 * xScaling,288.281 * yScaling,);
    path.cubicTo(72.2933 * xScaling,283.459 * yScaling,64.1403 * xScaling,276.564 * yScaling,57.8285 * xScaling,268.12 * yScaling,);
    path.cubicTo(51.5166 * xScaling,259.676 * yScaling,47.2118 * xScaling,249.905 * yScaling,45.2408 * xScaling,239.548 * yScaling,);
    path.cubicTo(43.2699 * xScaling,229.192 * yScaling,43.6847 * xScaling,218.522 * yScaling,46.4537 * xScaling,208.35 * yScaling,);
    path.cubicTo(49.1337 * xScaling,198.07 * yScaling,59.1137 * xScaling,174.69 * yScaling,93.4537 * xScaling,124.48 * yScaling,);
    path.cubicTo(118.724 * xScaling,87.6 * yScaling,150.874 * xScaling,44.95 * yScaling,185.274 * xScaling,0 * yScaling,);
    path.cubicTo(185.274 * xScaling,0 * yScaling,99.7037 * xScaling,0 * yScaling,99.7037 * xScaling,0 * yScaling,);
    path.cubicTo(96.1919 * xScaling,0.0247113 * yScaling,92.7346 * xScaling,0.871517 * yScaling,89.6089 * xScaling,2.47259 * yScaling,);
    path.cubicTo(86.4831 * xScaling,4.07366 * yScaling,83.7758 * xScaling,6.3845 * yScaling,81.7037 * xScaling,9.22 * yScaling,);
    path.cubicTo(18.2937 * xScaling,94.15 * yScaling,-20.9063 * xScaling,153.22 * yScaling,-29.6363 * xScaling,195.22 * yScaling,);
    path.cubicTo(-34.2387 * xScaling,216.348 * yScaling,-34.1167 * xScaling,238.232 * yScaling,-29.2792 * xScaling,259.307 * yScaling,);
    path.cubicTo(-24.4417 * xScaling,280.382 * yScaling,-15.0081 * xScaling,300.129 * yScaling,-1.65269 * xScaling,317.135 * yScaling,);
    path.cubicTo(11.7027 * xScaling,334.141 * yScaling,28.6501 * xScaling,347.986 * yScaling,47.978 * xScaling,357.682 * yScaling,);
    path.cubicTo(67.3059 * xScaling,367.377 * yScaling,88.537 * xScaling,372.683 * yScaling,110.154 * xScaling,373.22 * yScaling,);
    path.cubicTo(137.381 * xScaling,373.721 * yScaling,164.26 * xScaling,367.04 * yScaling,188.084 * xScaling,353.85 * yScaling,);
    path.cubicTo(213.274 * xScaling,354.49 * yScaling,238.484 * xScaling,354.09 * yScaling,263.514 * xScaling,350.9 * yScaling,);
    path.cubicTo(276.774 * xScaling,349.368 * yScaling,289.912 * xScaling,346.918 * yScaling,302.834 * xScaling,343.57 * yScaling,);
    path.cubicTo(326.354 * xScaling,361.41 * yScaling,352.034 * xScaling,372.95 * yScaling,381.264 * xScaling,372.95 * yScaling,);
    path.cubicTo(381.264 * xScaling,372.95 * yScaling,381.684 * xScaling,372.95 * yScaling,381.684 * xScaling,372.95 * yScaling,);
    path.cubicTo(403.319 * xScaling,372.926 * yScaling,424.68 * xScaling,368.106 * yScaling,444.229 * xScaling,358.837 * yScaling,);
    path.cubicTo(463.778 * xScaling,349.568 * yScaling,481.029 * xScaling,336.08 * yScaling,494.74 * xScaling,319.344 * yScaling,);
    path.cubicTo(508.451 * xScaling,302.608 * yScaling,518.281 * xScaling,283.04 * yScaling,523.523 * xScaling,262.049 * yScaling,);
    path.cubicTo(528.765 * xScaling,241.059 * yScaling,529.287 * xScaling,219.167 * yScaling,525.054 * xScaling,197.95 * yScaling,);
    path.cubicTo(525.054 * xScaling,197.95 * yScaling,525.054 * xScaling,197.85 * yScaling,525.054 * xScaling,197.85 * yScaling,);
    path.cubicTo(525.054 * xScaling,197.85 * yScaling,525.054 * xScaling,197.85 * yScaling,525.054 * xScaling,197.85 * yScaling,);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper)  => false;

}