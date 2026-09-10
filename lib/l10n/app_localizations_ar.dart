// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'لتس ترافل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => 'مثال: 01012345678';

  @override
  String get invalidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get verify => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get otpInvalid => 'أدخل الرمز المكوّن من 6 أرقام';

  @override
  String otpSentTo(String phone) {
    return 'أرسلنا رمزًا إلى $phone';
  }

  @override
  String get adminSignIn => 'دخول المسؤول';

  @override
  String get adminEmailLabel => 'البريد الإلكتروني';

  @override
  String get adminPasswordLabel => 'كلمة المرور';

  @override
  String get invalidCredentials => 'تحقق من البريد الإلكتروني وكلمة المرور';

  @override
  String get backToPhoneSignIn => 'سجّل الدخول برقم الهاتف بدلاً من ذلك';

  @override
  String get welcomeTitle => 'أهلاً بك';

  @override
  String get welcomeSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get demoPhoneHint =>
      'للتجربة: أضف 999 داخل الرقم لحساب مشرف، وأي رقم آخر يسجل الدخول كولي أمر.';

  @override
  String get demoAdminHint => 'كلمة مرور التجربة: admin123';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get signOutConfirmMessage => 'ستحتاج إلى تسجيل الدخول مرة أخرى.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get roleSuperAdmin => 'مسؤول النظام';

  @override
  String get roleSupervisor => 'مشرف الحافلة';

  @override
  String get roleParent => 'ولي الأمر';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get today => 'اليوم';

  @override
  String get noTripsToday => 'لا توجد رحلات مجدولة اليوم.';

  @override
  String get morningPickup => 'رحلة الصباح';

  @override
  String get afternoonDropoff => 'رحلة العودة';

  @override
  String get startTrip => 'بدء الرحلة';

  @override
  String get resumeTrip => 'متابعة الرحلة';

  @override
  String get endTrip => 'إنهاء الرحلة';

  @override
  String get tripInProgress => 'الرحلة جارية';

  @override
  String get tripScheduled => 'مجدولة';

  @override
  String get tripEnded => 'انتهت الرحلة';

  @override
  String get viewRoster => 'عرض القائمة';

  @override
  String get roster => 'قائمة الأطفال';

  @override
  String get routeLabel => 'الخط';

  @override
  String get busLabel => 'الحافلة';

  @override
  String stopsCount(int count) {
    return '$count محطات';
  }

  @override
  String get statusPending => 'في الانتظار';

  @override
  String get statusOnBoard => 'داخل الحافلة';

  @override
  String get statusDroppedOff => 'تم التسليم';

  @override
  String get statusAbsent => 'غائب';

  @override
  String get statusNoShow => 'لم يحضر';

  @override
  String get checkIn => 'صعد الحافلة';

  @override
  String get checkOut => 'تم التسليم';

  @override
  String get markNoShow => 'لم يحضر';

  @override
  String get undo => 'تراجع';

  @override
  String get actionUndone => 'تم التراجع';

  @override
  String markedAs(String name, String status) {
    return 'تم تسجيل $name كـ$status';
  }

  @override
  String stopHeader(int order, String name) {
    return 'محطة $order · $name';
  }

  @override
  String get absentTag => 'غائب اليوم';

  @override
  String countWaiting(int count) {
    return 'في الانتظار: $count';
  }

  @override
  String countOnBoard(int count) {
    return 'داخل الحافلة: $count';
  }

  @override
  String countDroppedOff(int count) {
    return 'تم التسليم: $count';
  }

  @override
  String get confirmNoShowTitle => 'تسجيل كـ«لم يحضر»؟';

  @override
  String confirmNoShowMessage(String name) {
    return 'سيتم تسجيل $name كـ«لم يحضر» لهذه الرحلة.';
  }

  @override
  String get confirmEndTripTitle => 'إنهاء هذه الرحلة؟';

  @override
  String get confirmEndTripMessage => 'سيتم إيقاف مشاركة الموقع لهذه الرحلة.';

  @override
  String confirmEndTripBlocked(int count) {
    return 'لا يزال هناك $count من الأطفال داخل الحافلة. قم بتسليمهم قبل إنهاء الرحلة.';
  }

  @override
  String get sos => 'طوارئ';

  @override
  String get reportIncident => 'الإبلاغ عن حادثة';

  @override
  String get incidentType => 'النوع';

  @override
  String get incidentSeverity => 'الخطورة';

  @override
  String get incidentNoteHint => 'ما الذي حدث؟';

  @override
  String get incidentSubmitted => 'تم الإبلاغ عن الحادثة. تم إخطار المدرسة.';

  @override
  String get incidentBreakdown => 'عطل';

  @override
  String get incidentAccident => 'حادث';

  @override
  String get incidentMedical => 'حالة طبية';

  @override
  String get incidentDelay => 'تأخير';

  @override
  String get incidentOther => 'أخرى';

  @override
  String get severityLow => 'منخفضة';

  @override
  String get severityMedium => 'متوسطة';

  @override
  String get severityHigh => 'عالية';

  @override
  String get severityCritical => 'حرجة';

  @override
  String get acknowledgeIncident => 'تم الاطلاع';

  @override
  String get incidentAcknowledged => 'تم الاطلاع';

  @override
  String get resolveIncident => 'تحديد كمحلولة';

  @override
  String get incidentResolved => 'تم الحل';

  @override
  String get openLabel => 'مفتوحة';

  @override
  String get submit => 'إرسال';

  @override
  String get myChildren => 'أبنائي';

  @override
  String get liveMap => 'الخريطة المباشرة';

  @override
  String get rideHistory => 'سجل الرحلات';

  @override
  String get reportAbsence => 'الإبلاغ عن غياب';

  @override
  String get busApproaching => 'الحافلة تقترب من موقفك';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get locationStale => 'الموقع غير محدّث';

  @override
  String get schematicMapLabel => 'عرض تخطيطي';

  @override
  String get childStop => 'المحطة';

  @override
  String get childSupervisor => 'المشرف';

  @override
  String get noActiveTrip => 'لا توجد رحلة جارية الآن';

  @override
  String busEtaLabel(int minutes) {
    return 'الوصول خلال حوالي $minutes دقيقة';
  }

  @override
  String get absenceScopeWholeDay => 'اليوم بالكامل';

  @override
  String get absenceScopeMorningOnly => 'الصباح فقط';

  @override
  String get absenceScopeAfternoonOnly => 'المساء فقط';

  @override
  String get absenceReasonHint => 'السبب (اختياري)';

  @override
  String get absenceSubmitted => 'تم الإبلاغ عن الغياب';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get historyEmpty => 'لا توجد رحلات بعد';

  @override
  String get messagesTitle => 'الرسائل';

  @override
  String get messageHint => 'اكتب رسالة…';

  @override
  String get sendMessage => 'إرسال';

  @override
  String get messagesEmpty => 'لا توجد رسائل بعد';

  @override
  String notifPickedUpTitle(String name) {
    return '$name داخل الحافلة';
  }

  @override
  String notifPickedUpBody(String time, String stop) {
    return 'تم الصعود الساعة $time من $stop';
  }

  @override
  String notifDroppedOffTitle(String name) {
    return 'تم تسليم $name';
  }

  @override
  String notifDroppedOffBody(String time, String stop) {
    return 'تم التسليم الساعة $time عند $stop';
  }

  @override
  String get administration => 'الإدارة';

  @override
  String get adminHeroSubtitle => 'المدارس والحافلات والخطوط وكل من يديرها';

  @override
  String get dashboardBusesOnRoad => 'حافلات في الطريق';

  @override
  String get dashboardChildrenOnBoard => 'أطفال داخل الحافلات';

  @override
  String get dashboardOpenIncidents => 'حوادث مفتوحة';

  @override
  String get dashboardSchools => 'المدارس';

  @override
  String get schools => 'المدارس';

  @override
  String get buses => 'الحافلات';

  @override
  String get routesLabel => 'الخطوط';

  @override
  String get students => 'الطلاب';

  @override
  String get staff => 'المشرفون';

  @override
  String get liveTrips => 'الرحلات المباشرة';

  @override
  String get reports => 'التقارير';

  @override
  String get incidentsLabel => 'الحوادث';

  @override
  String get announcements => 'الإعلانات';

  @override
  String get addSchool => 'إضافة مدرسة';

  @override
  String get editSchool => 'تعديل المدرسة';

  @override
  String get addBus => 'إضافة حافلة';

  @override
  String get editBus => 'تعديل الحافلة';

  @override
  String get addRoute => 'إضافة خط';

  @override
  String get editRoute => 'تعديل الخط';

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get editStudent => 'تعديل الطالب';

  @override
  String get addStop => 'إضافة محطة';

  @override
  String get schoolNameLabel => 'الاسم (بالإنجليزية)';

  @override
  String get schoolNameArLabel => 'الاسم (بالعربية)';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get busPlateLabel => 'رقم اللوحة';

  @override
  String get busCapacityLabel => 'السعة';

  @override
  String get busModelLabel => 'الموديل';

  @override
  String get driverNameLabel => 'اسم السائق';

  @override
  String get routeNameLabel => 'اسم الخط';

  @override
  String get assignBusLabel => 'الحافلة';

  @override
  String get assignSupervisorLabel => 'المشرف';

  @override
  String get studentNameLabel => 'الاسم الكامل';

  @override
  String get gradeLabel => 'الصف';

  @override
  String get guardianPhoneLabel => 'هاتف ولي الأمر';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get stopNameLabel => 'اسم المحطة';

  @override
  String studentsCount(int count) {
    return '$count طلاب';
  }

  @override
  String guardiansCount(int count) {
    return '$count أولياء أمور';
  }

  @override
  String get reportsDateRange => 'الفترة الزمنية';

  @override
  String get reportsGenerate => 'إنشاء التقرير';

  @override
  String get reportsNoData => 'لا يوجد حضور في هذه الفترة';

  @override
  String get reportsExport => 'تصدير CSV';

  @override
  String get announcementComposeHint => 'اكتب إعلانًا…';

  @override
  String get announcementPublish => 'نشر';

  @override
  String get announcementsEmpty => 'لا توجد إعلانات بعد';

  @override
  String get announcementScopeSchool => 'المدرسة بالكامل';

  @override
  String get announcementScopeRoute => 'خط واحد';

  @override
  String pendingSync(int count) {
    return '$count عملية بانتظار المزامنة';
  }

  @override
  String get offlineBanner => 'لا يوجد اتصال. يتم حفظ العمليات على الجهاز.';

  @override
  String get errorNoConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get errorNotAllowed => 'ليس لديك صلاحية للقيام بذلك.';

  @override
  String get errorNotFound => 'غير موجود.';

  @override
  String get errorInvalidAttendanceTransition =>
      'لم يتم تسجيل صعود هذا الطفل بعد.';

  @override
  String get errorUnexpected => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorLocationPermission => 'إذن الموقع مطلوب لتشغيل الرحلة.';

  @override
  String get errorTripNotEnded =>
      'لا يزال بعض الأطفال داخل الحافلة. قم بتسليمهم قبل إنهاء الرحلة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get language => 'اللغة';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String get notSet => 'غير محدد';

  @override
  String get required => 'مطلوب';

  @override
  String get noData => 'لا يوجد شيء هنا بعد';

  @override
  String get somethingWrong => 'حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';
}
