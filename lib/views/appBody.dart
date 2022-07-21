import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../CONSTANTS.dart';
import '../locationUtil/location_database.dart';
import '../providers/location_provider.dart';
import '../providers/updater_provider.dart';
import '../utils/prayer_data_handler.dart';
import '../networking/update_checker.dart';
import 'ads_widget.dart';
import 'notif_prompt.dart';
import 'prayer_time_view.dart';
import 'whats_new_update.dart';
import 'zone_chooser.dart';

class AppBody extends StatefulWidget {
  const AppBody({Key? key}) : super(key: key);

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  @override
  void initState() {
    super.initState();

    _checkForUpdate();
    _showUpdateNotes();
  }

  void _checkForUpdate() async {
    var res = await AppUpdateChecker.updatesAvailable();
    if (!res) return;

    Provider.of<UpdaterProvider>(context, listen: false).needForUpdate = res;
  }

  /// Show update dialog if app if recently updated
  void _showUpdateNotes() async {
    var version =
        await PackageInfo.fromPlatform().then((value) => value.version);

    bool shouldShowDialog = !GetStorage().read(kIsFirstRun) &&
        GetStorage().read<String>(version) == null;

    GetStorage()
        .write(kIsFirstRun, false); // app no longer consider as first run

    if (shouldShowDialog) {
      await showDialog(
          context: context, builder: (_) => const WhatsNewUpdateDialog());
    }
    GetStorage().write(version,
        DateTime.now().toString()); // write something to the version key
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<LocationProvider>(
        builder: (_, value, __) {
          return FutureBuilder<String>(
            future: PrayDataHandler.init(value.currentLocationCode),
            builder: (_, snapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(40)),
                    ),
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child:
                                  DateWidget(hijriDate: snapshot.data ?? "..."),
                            ),
                            const Expanded(
                              child: ZoneWidget(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const NotifPrompt(), // implementation is in the widget
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Builder(builder: (_) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loading();
                      }
                      if (snapshot.hasError) {
                        return Error(
                            errorMessage: snapshot.error.toString(),
                            onRetryPressed: () => setState(() {}));
                      }

                      // display the list of prayer timee
                      return const PrayTimeList();
                    }),
                  ),
                  // show ads only if no prayer times error happen
                  // annoying bila prayer time tk kluar, tapi ads laju je kluar
                  if (!snapshot.hasError) const AdsWidget()
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ZoneWidget extends StatelessWidget {
  const ZoneWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (_, value, __) {
        String shortCode = value.currentLocationCode;
        return Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(18.0),
          // alignment: Alignment.center,
          child: Semantics(
            button: true,
            label: AppLocalizations.of(context)!.appBodyLocSemanticLabel,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.white),
                ),
              ),
              onPressed: () {
                LocationChooser.showLocationChooser(context);
              },
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .appBodyCurrentLocation(
                            LocationDatabase.daerah(value.currentLocationCode),
                            LocationDatabase.negeri(
                                value.currentLocationCode))),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label:
                          AppLocalizations.of(context)!.appBodyChangeLocation,
                      onPressed: () {
                        LocationChooser.openLocationBottomSheet(context);
                      },
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.locationDot,
                      color: Colors.teal.shade50, size: 15),
                  Text(
                    '  ${shortCode.substring(0, 3).toUpperCase()}  ${shortCode.substring(3, 5)}',
                    style: GoogleFonts.montserrat(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DateWidget extends StatelessWidget {
  const DateWidget({Key? key, required this.hijriDate}) : super(key: key);

  final String hijriDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(70),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEEE', AppLocalizations.of(context)?.localeName)
                    .format(DateTime.now()),
                style: GoogleFonts.leagueSpartan(color: Colors.white),
              ),
              Text(
                hijriDate,
                style: GoogleFonts.acme(color: Colors.white, fontSize: 17),
              ),
              Text(
                DateFormat(
                        'd MMM yyyy', AppLocalizations.of(context)?.localeName)
                    .format(DateTime.now()),
                style: TextStyle(color: Colors.teal.shade100, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Error extends StatelessWidget {
  const Error({Key? key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  final String? errorMessage;
  final Function? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 15),
        Text(
          errorMessage!.isEmpty
              ? AppLocalizations.of(context)!.getPtError
              : errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onRetryPressed as void Function()?,
          child: Text(AppLocalizations.of(context)!.getPtRetry,
              style: const TextStyle(color: Colors.black)),
        ),
        const SizedBox(height: 350),
      ],
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          AppLocalizations.of(context)!.getPtFetch,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 200),
          child: SpinKitChasingDots(
            size: 35,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }
}
