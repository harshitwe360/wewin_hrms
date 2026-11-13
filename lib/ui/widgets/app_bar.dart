import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/config/config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.title, this.icon, this.iconPath});

  final String? title;
  final IconData? icon;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            FractionalTranslation(
              translation: const Offset(0.0, 0.0),
              child: InkWell(
                onTap: () {},
                // onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), //or 15.0
                  child: Container(
                    height: 36.0,
                    width: 36.0,
                    color: AppColors.white,
                    child: iconPath!=null ? SvgPicture.asset(
                        iconPath!,
                        width: 28,
                        height: 28,
                        semanticsLabel: title ?? "Home",
                        colorFilter: const ColorFilter.mode(
                            AppColors.colorAccent2, BlendMode.srcIn)
                    ) : Icon(icon ?? Icons.home_outlined,
                        color: AppColors.colorAccent2, size: 24.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                // padding: const EdgeInsets.only(top: 0.0),
                child: Text(title ?? "Home", textAlign: TextAlign.start),
              ),
            ),
            Container(
              width: 68.0,
              // color: AppColors.colorAccent,
              alignment: Alignment.center,
              child: Image.asset(
                R.images.logoSmall,
                fit: BoxFit.contain,
              ),
            )
          ]),
      // titleSpacing: 0.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55.0);
}

class ScrollableAppBar extends StatelessWidget implements PreferredSizeWidget{

  final String? title;
  final String? subTitle;
  final Color? color;
  final Color? textColor;
  final Color? iconColor;
  final IconData? icon;
  final double? elevation;
  final String? iconPath;
  final bool isIOSCenter;

  const ScrollableAppBar(
      {super.key, this.title, this.color, this.textColor, this.iconColor,
        this.icon, this.elevation, this.iconPath, this.subTitle,
        this.isIOSCenter = true});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      /*titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onBackground,
      ),*/
      backgroundColor: color ?? Theme.of(context).colorScheme.surface,
      elevation : elevation ?? 10.0,
      expandedHeight: 60.0,
      collapsedHeight: kToolbarHeight + 0.01,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0))),
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.2,
        background:
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        // titlePadding: const EdgeInsets.only(left: 72, bottom: 18.0),
        title: Container(
          height: 35.0,
          alignment: Alignment.bottomCenter,
          child: Row(
              children: [
                if(io.Platform.isIOS && isIOSCenter) const SizedBox(width: 40),
            FractionalTranslation(
              translation: const Offset(0.0, 0.0),
              child: InkWell(
                onTap: () {},
                // onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), //or 15.0
                  child: Container(
                    height: 28.0,
                    width: 28.0,
                    color: AppColors.white,
                    child: iconPath!=null ? SvgPicture.asset(
                        iconPath!,
                        width: 18,
                        height: 18,
                        semanticsLabel: title ?? "Home",
                        colorFilter: const ColorFilter.mode(
                            AppColors.colorAccent, BlendMode.srcIn)
                    ) : Icon(icon ?? Icons.home_outlined,
                        color: AppColors.colorAccent, size: 22.0),
                  ),
                ),
              ),
            ),
            // Icon(icon ?? Icons.home, size: 18, color: iconColor ?? AppColors.colorAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title ?? AppConstants.appName,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: "Metropolis",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.8,
                        color: textColor ?? Theme.of(context).colorScheme.onSurface,
                      )),
                  if(subTitle!=null)
                    Text("$subTitle",
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: "Metropolis",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        // letterSpacing: 1.2,
                        color: textColor ?? Theme.of(context).colorScheme.onSurface,
                      )),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget getUserView(BuildContext context, String head1, String head2){
    return Container(
      alignment: Alignment.bottomCenter,
      height: 35.0,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if(io.Platform.isIOS) const SizedBox(width: 40),
            FractionalTranslation(
              translation: const Offset(0.0, 0.0),
              child: InkWell(
                onTap: () {},
                // onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), //or 15.0
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    color: AppColors.white,
                    child: iconPath!=null ? SvgPicture.asset(
                        iconPath!,
                        width: 22,
                        height: 22,
                        semanticsLabel: title ?? "Home",
                        colorFilter: const ColorFilter.mode(
                            AppColors.colorAccent, BlendMode.srcIn)
                    ) : Icon(icon ?? Icons.home_outlined,
                        color: AppColors.colorAccent, size: 22.0),
                  ),
                ),
              ),
            ),
            // Icon(icon ?? Icons.home, size: 18, color: iconColor ?? AppColors.colorAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title ?? AppConstants.appName,
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 1.2,
                        color: textColor ?? Theme.of(context).colorScheme.onSurface,
                      )),
                  Text(title ?? AppConstants.appName,
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: textColor ?? Theme.of(context).colorScheme.onSurface,
                      )),
                ],
              ),
            )
          ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55.0);
}
