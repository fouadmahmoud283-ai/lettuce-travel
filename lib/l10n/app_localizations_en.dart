// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lettuce Travel';

  @override
  String get signIn => 'Sign in';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => 'e.g. 01012345678';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get sendCode => 'Send code';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get otpInvalid => 'Enter the 6-digit code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get adminSignIn => 'Administrator sign in';

  @override
  String get adminEmailLabel => 'Email';

  @override
  String get adminPasswordLabel => 'Password';

  @override
  String get invalidCredentials => 'Check your email and password';

  @override
  String get backToPhoneSignIn => 'Sign in with phone instead';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Sign in to continue';

  @override
  String get demoPhoneHint =>
      'Demo: include 999 in the number for a supervisor account. Any other number signs in as a parent.';

  @override
  String get demoAdminHint => 'Demo password: admin123';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage => 'You will need to sign in again.';

  @override
  String get settings => 'Settings';

  @override
  String get roleSuperAdmin => 'Administrator';

  @override
  String get roleSupervisor => 'Bus supervisor';

  @override
  String get roleParent => 'Parent';

  @override
  String get myTrips => 'My trips';

  @override
  String get today => 'Today';

  @override
  String get noTripsToday => 'No trips scheduled for today.';

  @override
  String get morningPickup => 'Morning pickup';

  @override
  String get afternoonDropoff => 'Afternoon drop-off';

  @override
  String get startTrip => 'Start trip';

  @override
  String get resumeTrip => 'Resume trip';

  @override
  String get endTrip => 'End trip';

  @override
  String get tripInProgress => 'Trip in progress';

  @override
  String get tripScheduled => 'Scheduled';

  @override
  String get tripEnded => 'Trip ended';

  @override
  String get viewRoster => 'View roster';

  @override
  String get roster => 'Roster';

  @override
  String get routeLabel => 'Route';

  @override
  String get busLabel => 'Bus';

  @override
  String stopsCount(int count) {
    return '$count stops';
  }

  @override
  String get statusPending => 'Waiting';

  @override
  String get statusOnBoard => 'On the bus';

  @override
  String get statusDroppedOff => 'Dropped off';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusNoShow => 'Did not board';

  @override
  String get checkIn => 'On board';

  @override
  String get checkOut => 'Dropped off';

  @override
  String get markNoShow => 'Did not board';

  @override
  String get undo => 'Undo';

  @override
  String get actionUndone => 'Undone';

  @override
  String markedAs(String name, String status) {
    return '$name marked as $status';
  }

  @override
  String stopHeader(int order, String name) {
    return 'Stop $order · $name';
  }

  @override
  String get absentTag => 'Absent today';

  @override
  String countWaiting(int count) {
    return 'Waiting: $count';
  }

  @override
  String countOnBoard(int count) {
    return 'On board: $count';
  }

  @override
  String countDroppedOff(int count) {
    return 'Dropped off: $count';
  }

  @override
  String get confirmNoShowTitle => 'Mark as did not board?';

  @override
  String confirmNoShowMessage(String name) {
    return '$name will be marked as did not board for this trip.';
  }

  @override
  String get confirmEndTripTitle => 'End this trip?';

  @override
  String get confirmEndTripMessage =>
      'Location sharing will stop for this trip.';

  @override
  String confirmEndTripBlocked(int count) {
    return '$count children are still on board. Drop them off before ending the trip.';
  }

  @override
  String get sos => 'Emergency';

  @override
  String get reportIncident => 'Report an incident';

  @override
  String get incidentType => 'Type';

  @override
  String get incidentSeverity => 'Severity';

  @override
  String get incidentNoteHint => 'What happened?';

  @override
  String get incidentSubmitted =>
      'Incident reported. The school has been notified.';

  @override
  String get incidentBreakdown => 'Breakdown';

  @override
  String get incidentAccident => 'Accident';

  @override
  String get incidentMedical => 'Medical';

  @override
  String get incidentDelay => 'Delay';

  @override
  String get incidentOther => 'Other';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get severityCritical => 'Critical';

  @override
  String get acknowledgeIncident => 'Acknowledge';

  @override
  String get incidentAcknowledged => 'Acknowledged';

  @override
  String get resolveIncident => 'Mark resolved';

  @override
  String get incidentResolved => 'Resolved';

  @override
  String get openLabel => 'Open';

  @override
  String get submit => 'Submit';

  @override
  String get myChildren => 'My children';

  @override
  String get liveMap => 'Live map';

  @override
  String get rideHistory => 'Ride history';

  @override
  String get reportAbsence => 'Report an absence';

  @override
  String get busApproaching => 'The bus is approaching your stop';

  @override
  String lastUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get locationStale => 'Location is not up to date';

  @override
  String get schematicMapLabel => 'Schematic view';

  @override
  String get childStop => 'Stop';

  @override
  String get childSupervisor => 'Supervisor';

  @override
  String get noActiveTrip => 'No trip running right now';

  @override
  String busEtaLabel(int minutes) {
    return 'Arriving in about $minutes min';
  }

  @override
  String get absenceScopeWholeDay => 'Whole day';

  @override
  String get absenceScopeMorningOnly => 'Morning only';

  @override
  String get absenceScopeAfternoonOnly => 'Afternoon only';

  @override
  String get absenceReasonHint => 'Reason (optional)';

  @override
  String get absenceSubmitted => 'Absence reported';

  @override
  String get selectDate => 'Select date';

  @override
  String get historyEmpty => 'No rides yet';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messageHint => 'Write a message…';

  @override
  String get sendMessage => 'Send';

  @override
  String get messagesEmpty => 'No messages yet';

  @override
  String notifPickedUpTitle(String name) {
    return '$name is on the bus';
  }

  @override
  String notifPickedUpBody(String time, String stop) {
    return 'Picked up at $time from $stop';
  }

  @override
  String notifDroppedOffTitle(String name) {
    return '$name has been dropped off';
  }

  @override
  String notifDroppedOffBody(String time, String stop) {
    return 'Dropped off at $time at $stop';
  }

  @override
  String get administration => 'Administration';

  @override
  String get dashboardBusesOnRoad => 'Buses on the road';

  @override
  String get dashboardChildrenOnBoard => 'Children on board';

  @override
  String get dashboardOpenIncidents => 'Open incidents';

  @override
  String get dashboardSchools => 'Schools';

  @override
  String get schools => 'Schools';

  @override
  String get buses => 'Buses';

  @override
  String get routesLabel => 'Routes';

  @override
  String get students => 'Students';

  @override
  String get staff => 'Supervisors';

  @override
  String get liveTrips => 'Live trips';

  @override
  String get reports => 'Reports';

  @override
  String get incidentsLabel => 'Incidents';

  @override
  String get announcements => 'Announcements';

  @override
  String get addSchool => 'Add school';

  @override
  String get editSchool => 'Edit school';

  @override
  String get addBus => 'Add bus';

  @override
  String get editBus => 'Edit bus';

  @override
  String get addRoute => 'Add route';

  @override
  String get editRoute => 'Edit route';

  @override
  String get addStudent => 'Add student';

  @override
  String get editStudent => 'Edit student';

  @override
  String get addStop => 'Add stop';

  @override
  String get schoolNameLabel => 'Name (English)';

  @override
  String get schoolNameArLabel => 'Name (Arabic)';

  @override
  String get addressLabel => 'Address';

  @override
  String get busPlateLabel => 'Plate number';

  @override
  String get busCapacityLabel => 'Capacity';

  @override
  String get busModelLabel => 'Model';

  @override
  String get driverNameLabel => 'Driver name';

  @override
  String get routeNameLabel => 'Route name';

  @override
  String get assignBusLabel => 'Bus';

  @override
  String get assignSupervisorLabel => 'Supervisor';

  @override
  String get studentNameLabel => 'Full name';

  @override
  String get gradeLabel => 'Grade / class';

  @override
  String get guardianPhoneLabel => 'Guardian phone';

  @override
  String get notesLabel => 'Notes';

  @override
  String get stopNameLabel => 'Stop name';

  @override
  String studentsCount(int count) {
    return '$count students';
  }

  @override
  String guardiansCount(int count) {
    return '$count guardians';
  }

  @override
  String get reportsDateRange => 'Date range';

  @override
  String get reportsGenerate => 'Generate';

  @override
  String get reportsNoData => 'No attendance in this range';

  @override
  String get reportsExport => 'Export CSV';

  @override
  String get announcementComposeHint => 'Write an announcement…';

  @override
  String get announcementPublish => 'Publish';

  @override
  String get announcementsEmpty => 'No announcements yet';

  @override
  String get announcementScopeSchool => 'Whole school';

  @override
  String get announcementScopeRoute => 'One route';

  @override
  String pendingSync(int count) {
    return '$count check-ins waiting to sync';
  }

  @override
  String get offlineBanner =>
      'No connection. Check-ins are saved on this device.';

  @override
  String get errorNoConnection => 'No internet connection.';

  @override
  String get errorNotAllowed => 'You do not have permission to do this.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorInvalidAttendanceTransition =>
      'This child has not been marked on board yet.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorLocationPermission =>
      'Location permission is required to run a trip.';

  @override
  String get errorTripNotEnded =>
      'Some children are still on board. Drop them off before ending the trip.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get language => 'Language';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get notSet => 'Not set';

  @override
  String get required => 'Required';

  @override
  String get noData => 'Nothing here yet';

  @override
  String get somethingWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';
}
