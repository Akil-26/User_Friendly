part of 'utils.dart';

const double _designWidth = 412;
const double _designHeight = 917;

class AppSizes {
  static double w = 412;
  static double h = 917;
  static double statusBarHeight = 0;
  static double bottomBarHeight = 0;
  static Orientation orientation = Orientation.portrait;

  static void init(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    statusBarHeight = MediaQuery.of(context).padding.top;
    bottomBarHeight = MediaQuery.of(context).padding.bottom;
    orientation = MediaQuery.of(context).orientation;
  }

  static double get width => w;
  static double get height => h;

  static double get spaceXs => 4.w;
  static double get spaceSm => 8.w;
  static double get spaceMd => 16.w;
  static double get spaceLg => 24.w;
  static double get spaceXl => 32.w;

  static double get radiusSm => 4.r;
  static double get radiusMd => 8.r;
  static double get radiusLg => 16.r;
  static double get radiusCircular => 100.r;

  static bool get isMobile => math.min(w, h) < 600;
  static bool get isTablet => math.min(w, h) >= 600 && math.min(w, h) < 1024;

  static T responsive<T>({required T mobile, T? tablet}) {
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

extension AppSizeExtensions on num {
  double get _safeWidth => math.min(AppSizes.w, AppSizes.h);
  double get _safeHeight => math.max(AppSizes.w, AppSizes.h);

  double get w => _safeWidth * (this / _designWidth);
  double get h => _safeHeight * (this / _designHeight);

  double get sp {
    double scaled = _safeWidth * (this / _designWidth);
    return scaled.clamp(this * 0.8, this * 1.5);
  }

  double get r => _safeWidth * (this / _designWidth);
}