import '../localization/app_localization.dart';

class Strings {

  String appName = AppLocalization.instance.text('appName');

  /* -- Login/ Workspace -- */
  // Getters (not cached fields) so text always reflects the loaded locale
  // file, including after a hot reload.
  String get loginTopText => AppLocalization.instance.text('loginTopTxt');
  String get loginSubtitle => AppLocalization.instance.text('loginSubtitle');
  String get loginSubtitleOtp => AppLocalization.instance.text('loginSubtitleOtp');
  String passwordLabel = AppLocalization.instance.text('passwordLabel');
  String passwordHnt = AppLocalization.instance.text('passwordHnt');
  String errorMsgPwd = AppLocalization.instance.text('errorMsgPwd');
  String labelEmail = AppLocalization.instance.text('emailLabel');
  String hintEmail = AppLocalization.instance.text('emailHint');
  String errorMsgEmail = AppLocalization.instance.text('errorMsgEmail');
  String btnForgotPassword = AppLocalization.instance.text('forgotPassword');
  String btnLogin = AppLocalization.instance.text('btnLogin');

  String workSpaceTxt = AppLocalization.instance.text('workSpaceTxt');
  String btnLetsBegin = AppLocalization.instance.text('btnLetsBegin');
  String txtLoginB1 = AppLocalization.instance.text('txtLoginB1');
  String txtTndC = AppLocalization.instance.text('txtTndC');
  String labelDomain = AppLocalization.instance.text('domainLabel');
  String hintDomain = AppLocalization.instance.text('domainHint');
  String errorMsgDomain = AppLocalization.instance.text('errorMsgDomain');

  /* -- API Error -- */
  String errMsgDefaultAPI = AppLocalization.instance.text('errMsgDefaultAPI');
  String errMsgNoRecord = AppLocalization.instance.text('errMsgNoRecord');
  String errMsgUnableToShow = AppLocalization.instance.text('errMsgUnableToShow');
  String errAPINoNet = AppLocalization.instance.text('errAPINoNet');
  String errMsgLoginInvalid = AppLocalization.instance.text('errMsgLoginInvalid');
  String errMsgDateLimit = AppLocalization.instance.text('errMsgDateLimit');

  /* -- Main-Screen -- */
  String txtProfile = AppLocalization.instance.text('txtProfile');
  String txtHome = AppLocalization.instance.text('txtHome');
  String txtFieldTask = AppLocalization.instance.text('txtFieldTask');
  String txtNavigator = AppLocalization.instance.text('txtNavigator');

  String txtAbsent = AppLocalization.instance.text('txtAbsent');
  String txtPresent = AppLocalization.instance.text('txtPresent');
  String txtAttendancePercent = AppLocalization.instance.text('txtAttendancePercent');
  String txtAvgWorkTime = AppLocalization.instance.text('txtAvgWorkTime');
  String txtTotal = AppLocalization.instance.text('txtTotal');
  String txtPunchLogsTitle = AppLocalization.instance.text('txtPunchLogsTitle');
  String txtPunchIn = AppLocalization.instance.text('txtPunchIn');
  String txtPunchOut = AppLocalization.instance.text('txtPunchOut');
  String txtDuration = AppLocalization.instance.text('txtDuration');
  String txtShiftNA = AppLocalization.instance.text('txtShiftNA');
  String btnViewLogs = AppLocalization.instance.text('btnViewLogs');
  String btnStopWorking = AppLocalization.instance.text('btnStopWorking');
  String btnStartWorking = AppLocalization.instance.text('btnStartWorking');
  String btnStartBreak = AppLocalization.instance.text('btnStartBreak');
  String btnEndBreak = AppLocalization.instance.text('btnEndBreak');
  String txtOnBreak = AppLocalization.instance.text('txtOnBreak');
  String msgNotAllowedPP = AppLocalization.instance.text('msgNotAllowedPP');
  String msgLocationDisable = AppLocalization.instance.text('msgLocationDisable');
  String msgLocationDenied = AppLocalization.instance.text('msgLocationDenied');
  String msgLocationPDenied = AppLocalization.instance.text('msgLocationPDenied');
  String msgNoRecordFound = AppLocalization.instance.text('msgNoRecordFound');

  String txtProfilePhoto = AppLocalization.instance.text('txtProfilePhoto');
  String txtUser = AppLocalization.instance.text('txtUser');
  String txtDomain = AppLocalization.instance.text('txtDomain');
  String txtCompany = AppLocalization.instance.text('txtCompany');
  String txtDesignation = AppLocalization.instance.text('txtDesignation');
  String txtTeam = AppLocalization.instance.text('txtTeam');
  String txtShift = AppLocalization.instance.text('txtShift');
  String txtDOB = AppLocalization.instance.text('txtDOB');
  String txtDOJ = AppLocalization.instance.text('txtDOJ');
  String txtGender = AppLocalization.instance.text('txtGender');
  String txtMobile = AppLocalization.instance.text('txtMobile');
  String txtEmailID = AppLocalization.instance.text('txtEmailID');
  String txtSignOut = AppLocalization.instance.text('txtSignOut');
  String txtLSync = AppLocalization.instance.text('txtLSync');

  String txtAttendance = AppLocalization.instance.text('txtAttendance');

  /* -- Filter/Screen -- */
  String btnFilter = AppLocalization.instance.text('btnFilter');
  String txtFilter = AppLocalization.instance.text('txtFilter');
  String txtSelectUser = AppLocalization.instance.text('txtSelectUser');
  String txtSelectTeam = AppLocalization.instance.text('txtSelectTeam');
  String btnClear = AppLocalization.instance.text('btnClear');
  String btnApply = AppLocalization.instance.text('btnApply');

  /* -- Attendance/Screen -- */
  String txtAttnDetail = AppLocalization.instance.text('txtAttnDetail');
  String txtAttnTrend = AppLocalization.instance.text('txtAttnTrend');
  String txtSameAs = AppLocalization.instance.text('txtSameAs');
  String txtMoreThan = AppLocalization.instance.text('txtMoreThan');
  String txtLessThan = AppLocalization.instance.text('txtLessThan');
  String txtPreviousDay = AppLocalization.instance.text('txtPreviousDay');
  String txtAvgWorkingHrs = AppLocalization.instance.text('txtAvgWorkingHrs');
  String txtPunchIcons = AppLocalization.instance.text('txtPunchIcons');
  String txtToday = AppLocalization.instance.text('txtToday');
  String txtLateArrivals = AppLocalization.instance.text('txtLateArrivals');
  String txtTotalPunchHrs = AppLocalization.instance.text('txtTotalPunchHrs');
  String txtGoal = AppLocalization.instance.text('txtGoal');
  String txtBefore = AppLocalization.instance.text('txtBefore');
  String txtLate = AppLocalization.instance.text('txtLate');
  String txtDays = AppLocalization.instance.text('txtDays');
  String txtNoAttendance = AppLocalization.instance.text('txtNoAttendance');
  String txtSearch = AppLocalization.instance.text('txtSearch');

}