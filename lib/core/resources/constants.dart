class AppConstants {

  static const int perPage = 10;
  static const String appName = "WeWin";

  // Local Storage Keys
  static const String token = "token";
  static const String schema = "schema";
  static const String freshInstall  = "fresh_installer";
  static const String loginDetails  = "login_details";
  static const String whoMIDetails  = "who_am_i";
  static const String domainDetails = "domain_details";
  static const String tenantId      = "tenantId";
  static const String tenantName      = "tenantName";
  static const String serverDeviceId = "server_side_device_id";


  static const String unAuthorization = "Unauthorised:";
  static const String dateFixStart = "00:00:00";
  static const String dateFixEnd = "23:59:59";
  static const String dateFTime = "hh:mm a";

  /// Legacy backend. Still used by dashboard, team attendance, calendar,
  /// corrections, resign and signup until those are migrated.
  static const String coreServerUrl = "https://api.wewinlimited.com";

  /// WinHRMS backend (auth + attendance). See `ApiEndpoints`.
  static const String winHrmsServerUrl = "https://winhrms.wewinlimited.com";

  /// The app is pinned to a single tenant.
  static const String defaultTenantSlug = "default";

  static const Duration requestTimeout = Duration(seconds: 30);
  static const String forgotPasswordUrl = "https://www.wewinlimited.com";
  static const String termsUrl = "https://www.wewinlimited.com";
  // static const String signUpUrl = "https://portal.we360.ai/signup";
  static const String operationalUrl = "/api/";
  static const String reportsUrl = "/api/";

  static const List<String> filterUserOptList = ['All Users', 'Present Users', 'Absent Users'];
}