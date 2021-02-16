import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:waktusolatmalaysia/utils/navigator_pop.dart';
import '../../CONSTANTS.dart';
import '../../utils/cupertinoSwitchListTile.dart';

class NotificationPageSetting extends StatefulWidget {
  @override
  _NotificationPageSettingState createState() =>
      _NotificationPageSettingState();
}

class _NotificationPageSettingState extends State<NotificationPageSetting> {
  var prayerNotification = [true, true, true, true, true, true, true];
  bool isAnythingChanged = false; //effect the button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        centerTitle: true,
        // actions: [
        //   FlatButton(
        //     shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        //     textColor: Colors.white,
        //     onPressed: !isAnythingChanged
        //         ? null
        //         : () {
        //             print('Save button clicked');
        //             print(prayerNotification);
        //             Navigator.pop(context);
        //           },
        //     child: Text(
        //       'SAVE',
        //     ),
        //   )
        // ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          //Turned of for a while
          // Text('Basic'),
          // Card(
          //   child: Column(children: [
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[0]),
          //         value: prayerNotification[0],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[0] = value;
          //           });
          //         }),
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[1]),
          //         value: prayerNotification[1],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[1] = value;
          //           });
          //         }),
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[2]),
          //         value: prayerNotification[2],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[2] = value;
          //           });
          //         }),
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[3]),
          //         value: prayerNotification[3],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[3] = value;
          //           });
          //         }),
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[4]),
          //         value: prayerNotification[4],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[4] = value;
          //           });
          //         }),
          //     CupertinoSwitchListTile(
          //         title: Text(PrayerName.prayerName[5]),
          //         value: prayerNotification[5],
          //         onChanged: (bool value) {
          //           setState(() {
          //             isAnythingChanged = true;
          //             prayerNotification[5] = value;
          //           });
          //         }),
          //   ]),
          // ),
          Padding(padding: const EdgeInsets.all(8.0), child: Text('Basic')),
          Card(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('App notification System Setting'),
              subtitle: Text(
                  'Customize sound, toggle channel of prayer notification etc.'),
              trailing: Icon(Icons.launch_rounded),
              onTap: () async {
                await AppSettings.openNotificationSettings();
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Troubleshooting')),

          Card(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CupertinoSwitchListTile(
                  title: Text('Limit notification scheduling'),
                  subtitle: Text(
                      'Enable if you experiencing an extreme slowdown in app. Notification will schedule weekly basis. Default is OFF (monthly).'),
                  value: GetStorage().read(kStoredNotificationLimit),
                  onChanged: (value) {
                    // print(value);
                    setState(() {
                      GetStorage().write(kStoredNotificationLimit, value);
                    });
                  }),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Force rescheduling notification...'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                            'By default, notifications will get rescheduled on app reopening after three days since last scheduling.\n\nTap proceed to start an immediate notification scheduling. The app will be restart.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              GetStorage().write(kForceUpdateNotif, true);
                              print(GetStorage().read(kForceUpdateNotif));
                              Get.forceAppUpdate();
                              CustomNavigatorPop.popTo(context, 3);
                            },
                            child: Text('Proceed'),
                          )
                        ],
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
