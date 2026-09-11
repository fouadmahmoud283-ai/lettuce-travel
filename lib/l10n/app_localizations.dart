import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lettuce Travel'**
  String get appName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 01012345678'**
  String get phoneHint;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpInvalid;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @adminSignIn.
  ///
  /// In en, this message translates to:
  /// **'Administrator sign in'**
  String get adminSignIn;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmailLabel;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPasswordLabel;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Check your email and password'**
  String get invalidCredentials;

  /// No description provided for @backToPhoneSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone instead'**
  String get backToPhoneSignIn;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Live bus tracking, instant pickup and drop-off alerts, all in one place.'**
  String get welcomeTagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @demoPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Demo: include 999 in the number for a supervisor account. Any other number signs in as a parent.'**
  String get demoPhoneHint;

  /// No description provided for @demoAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Demo password: admin123'**
  String get demoAdminHint;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again.'**
  String get signOutConfirmMessage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleSuperAdmin;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Bus supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get myTrips;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noTripsToday.
  ///
  /// In en, this message translates to:
  /// **'No trips scheduled for today.'**
  String get noTripsToday;

  /// No description provided for @morningPickup.
  ///
  /// In en, this message translates to:
  /// **'Morning pickup'**
  String get morningPickup;

  /// No description provided for @afternoonDropoff.
  ///
  /// In en, this message translates to:
  /// **'Afternoon drop-off'**
  String get afternoonDropoff;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get startTrip;

  /// No description provided for @resumeTrip.
  ///
  /// In en, this message translates to:
  /// **'Resume trip'**
  String get resumeTrip;

  /// No description provided for @endTrip.
  ///
  /// In en, this message translates to:
  /// **'End trip'**
  String get endTrip;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get tripInProgress;

  /// No description provided for @tripScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get tripScheduled;

  /// No description provided for @tripEnded.
  ///
  /// In en, this message translates to:
  /// **'Trip ended'**
  String get tripEnded;

  /// No description provided for @viewRoster.
  ///
  /// In en, this message translates to:
  /// **'View roster'**
  String get viewRoster;

  /// No description provided for @roster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get roster;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @busLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get busLabel;

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String stopsCount(int count);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusPending;

  /// No description provided for @statusOnBoard.
  ///
  /// In en, this message translates to:
  /// **'On the bus'**
  String get statusOnBoard;

  /// No description provided for @statusDroppedOff.
  ///
  /// In en, this message translates to:
  /// **'Dropped off'**
  String get statusDroppedOff;

  /// No description provided for @statusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get statusAbsent;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'Did not board'**
  String get statusNoShow;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'On board'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Dropped off'**
  String get checkOut;

  /// No description provided for @markNoShow.
  ///
  /// In en, this message translates to:
  /// **'Did not board'**
  String get markNoShow;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @actionUndone.
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get actionUndone;

  /// No description provided for @markedAs.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as {status}'**
  String markedAs(String name, String status);

  /// No description provided for @stopHeader.
  ///
  /// In en, this message translates to:
  /// **'Stop {order} · {name}'**
  String stopHeader(int order, String name);

  /// No description provided for @absentTag.
  ///
  /// In en, this message translates to:
  /// **'Absent today'**
  String get absentTag;

  /// No description provided for @countWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting: {count}'**
  String countWaiting(int count);

  /// No description provided for @countOnBoard.
  ///
  /// In en, this message translates to:
  /// **'On board: {count}'**
  String countOnBoard(int count);

  /// No description provided for @countDroppedOff.
  ///
  /// In en, this message translates to:
  /// **'Dropped off: {count}'**
  String countDroppedOff(int count);

  /// No description provided for @confirmNoShowTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as did not board?'**
  String get confirmNoShowTitle;

  /// No description provided for @confirmNoShowMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be marked as did not board for this trip.'**
  String confirmNoShowMessage(String name);

  /// No description provided for @confirmEndTripTitle.
  ///
  /// In en, this message translates to:
  /// **'End this trip?'**
  String get confirmEndTripTitle;

  /// No description provided for @confirmEndTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Location sharing will stop for this trip.'**
  String get confirmEndTripMessage;

  /// No description provided for @confirmEndTripBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} children are still on board. Drop them off before ending the trip.'**
  String confirmEndTripBlocked(int count);

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get sos;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get reportIncident;

  /// No description provided for @incidentType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get incidentType;

  /// No description provided for @incidentSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get incidentSeverity;

  /// No description provided for @incidentNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get incidentNoteHint;

  /// No description provided for @incidentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Incident reported. The school has been notified.'**
  String get incidentSubmitted;

  /// No description provided for @incidentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get incidentBreakdown;

  /// No description provided for @incidentAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get incidentAccident;

  /// No description provided for @incidentMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get incidentMedical;

  /// No description provided for @incidentDelay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get incidentDelay;

  /// No description provided for @incidentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incidentOther;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @acknowledgeIncident.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledgeIncident;

  /// No description provided for @incidentAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get incidentAcknowledged;

  /// No description provided for @resolveIncident.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get resolveIncident;

  /// No description provided for @incidentResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get incidentResolved;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My children'**
  String get myChildren;

  /// No description provided for @liveMap.
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get liveMap;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride history'**
  String get rideHistory;

  /// No description provided for @reportAbsence.
  ///
  /// In en, this message translates to:
  /// **'Report an absence'**
  String get reportAbsence;

  /// No description provided for @busApproaching.
  ///
  /// In en, this message translates to:
  /// **'The bus is approaching your stop'**
  String get busApproaching;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @locationStale.
  ///
  /// In en, this message translates to:
  /// **'Location is not up to date'**
  String get locationStale;

  /// No description provided for @schematicMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Schematic view'**
  String get schematicMapLabel;

  /// No description provided for @childStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get childStop;

  /// No description provided for @childSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get childSupervisor;

  /// No description provided for @noActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'No trip running right now'**
  String get noActiveTrip;

  /// No description provided for @busEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'Arriving in about {minutes} min'**
  String busEtaLabel(int minutes);

  /// No description provided for @absenceScopeWholeDay.
  ///
  /// In en, this message translates to:
  /// **'Whole day'**
  String get absenceScopeWholeDay;

  /// No description provided for @absenceScopeMorningOnly.
  ///
  /// In en, this message translates to:
  /// **'Morning only'**
  String get absenceScopeMorningOnly;

  /// No description provided for @absenceScopeAfternoonOnly.
  ///
  /// In en, this message translates to:
  /// **'Afternoon only'**
  String get absenceScopeAfternoonOnly;

  /// No description provided for @absenceReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get absenceReasonHint;

  /// No description provided for @absenceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Absence reported'**
  String get absenceSubmitted;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rides yet'**
  String get historyEmpty;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get messageHint;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// No description provided for @notifPickedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the bus'**
  String notifPickedUpTitle(String name);

  /// No description provided for @notifPickedUpBody.
  ///
  /// In en, this message translates to:
  /// **'Picked up at {time} from {stop}'**
  String notifPickedUpBody(String time, String stop);

  /// No description provided for @notifDroppedOffTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} has been dropped off'**
  String notifDroppedOffTitle(String name);

  /// No description provided for @notifDroppedOffBody.
  ///
  /// In en, this message translates to:
  /// **'Dropped off at {time} at {stop}'**
  String notifDroppedOffBody(String time, String stop);

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @adminHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schools, buses, routes and everyone who keeps them running'**
  String get adminHeroSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @moreTabLabel.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTabLabel;

  /// No description provided for @moreSectionOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get moreSectionOperations;

  /// No description provided for @moreSectionSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get moreSectionSetup;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get navLive;

  /// No description provided for @navTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// No description provided for @dashboardBusesOnRoad.
  ///
  /// In en, this message translates to:
  /// **'Buses on the road'**
  String get dashboardBusesOnRoad;

  /// No description provided for @dashboardChildrenOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Children on board'**
  String get dashboardChildrenOnBoard;

  /// No description provided for @dashboardOpenIncidents.
  ///
  /// In en, this message translates to:
  /// **'Open incidents'**
  String get dashboardOpenIncidents;

  /// No description provided for @dashboardSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get dashboardSchools;

  /// No description provided for @schools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get schools;

  /// No description provided for @buses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get buses;

  /// No description provided for @routesLabel.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routesLabel;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Supervisors'**
  String get staff;

  /// No description provided for @liveTrips.
  ///
  /// In en, this message translates to:
  /// **'Live trips'**
  String get liveTrips;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @incidentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get incidentsLabel;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @addSchool.
  ///
  /// In en, this message translates to:
  /// **'Add school'**
  String get addSchool;

  /// No description provided for @editSchool.
  ///
  /// In en, this message translates to:
  /// **'Edit school'**
  String get editSchool;

  /// No description provided for @addBus.
  ///
  /// In en, this message translates to:
  /// **'Add bus'**
  String get addBus;

  /// No description provided for @editBus.
  ///
  /// In en, this message translates to:
  /// **'Edit bus'**
  String get editBus;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add route'**
  String get addRoute;

  /// No description provided for @editRoute.
  ///
  /// In en, this message translates to:
  /// **'Edit route'**
  String get editRoute;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In en, this message translates to:
  /// **'Edit student'**
  String get editStudent;

  /// No description provided for @addStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// No description provided for @schoolNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get schoolNameLabel;

  /// No description provided for @schoolNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get schoolNameArLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @busPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get busPlateLabel;

  /// No description provided for @busCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get busCapacityLabel;

  /// No description provided for @busModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get busModelLabel;

  /// No description provided for @driverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver name'**
  String get driverNameLabel;

  /// No description provided for @routeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get routeNameLabel;

  /// No description provided for @assignBusLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get assignBusLabel;

  /// No description provided for @assignSupervisorLabel.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get assignSupervisorLabel;

  /// No description provided for @studentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get studentNameLabel;

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade / class'**
  String get gradeLabel;

  /// No description provided for @guardianPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian phone'**
  String get guardianPhoneLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @stopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop name'**
  String get stopNameLabel;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String studentsCount(int count);

  /// No description provided for @guardiansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} guardians'**
  String guardiansCount(int count);

  /// No description provided for @reportsDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get reportsDateRange;

  /// No description provided for @reportsGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get reportsGenerate;

  /// No description provided for @reportsNoData.
  ///
  /// In en, this message translates to:
  /// **'No attendance in this range'**
  String get reportsNoData;

  /// No description provided for @reportsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Status breakdown'**
  String get reportsBreakdownTitle;

  /// No description provided for @reportsTotalRecords.
  ///
  /// In en, this message translates to:
  /// **'total records'**
  String get reportsTotalRecords;

  /// No description provided for @reportsTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily trend'**
  String get reportsTrendTitle;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get reportsExport;

  /// No description provided for @announcementComposeHint.
  ///
  /// In en, this message translates to:
  /// **'Write an announcement…'**
  String get announcementComposeHint;

  /// No description provided for @announcementPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get announcementPublish;

  /// No description provided for @announcementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get announcementsEmpty;

  /// No description provided for @announcementScopeSchool.
  ///
  /// In en, this message translates to:
  /// **'Whole school'**
  String get announcementScopeSchool;

  /// No description provided for @announcementScopeRoute.
  ///
  /// In en, this message translates to:
  /// **'One route'**
  String get announcementScopeRoute;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'{count} check-ins waiting to sync'**
  String pendingSync(int count);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check-ins are saved on this device.'**
  String get offlineBanner;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNoConnection;

  /// No description provided for @errorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this.'**
  String get errorNotAllowed;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorInvalidAttendanceTransition.
  ///
  /// In en, this message translates to:
  /// **'This child has not been marked on board yet.'**
  String get errorInvalidAttendanceTransition;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to run a trip.'**
  String get errorLocationPermission;

  /// No description provided for @errorTripNotEnded.
  ///
  /// In en, this message translates to:
  /// **'Some children are still on board. Drop them off before ending the trip.'**
  String get errorTripNotEnded;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get noData;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
