import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../CONSTANTS.dart' as Constants;
import '../CONSTANTS.dart';
import '../utils/AppInformation.dart';
import '../utils/launchUrl.dart';

enum FeedbackCategory { suggestion, bug, compliment }

class FeedbackToEmail {
  String _message;
  String _debugLog;

  void messageSetter(String message) {
    this._message = message;
  }

  void debugLogSetter(String debugLog) {
    this._debugLog = debugLog;
  }

  void clearDebugLog() {
    this._debugLog = '';
  }

  String getAllData() {
    String data = '''

    Message: $_message, 

    <---------Debug log:---------------

    $_debugLog
    
    ------------------EO🐛---------------->
    
    Thank you for submitting feedback. 
    ''';
    //add github issue link

    //EOF is end of feedback
    print(data);
    return data;
  }
}

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  AppInfo appInfo = AppInfo();
  FeedbackCategory feedbackCategory;
  double selectedOutlineWidth = 4.0;
  double unselectedOutlineWidth = 1.0;
  String hintTextForFeedback = 'Please leave your feedback here';
  FeedbackToEmail feedbackToEmail = FeedbackToEmail();
  TextEditingController messageController = TextEditingController();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String board,
      brand,
      device,
      hardware,
      host,
      id,
      manufacture,
      model,
      product,
      type,
      androidid,
      sdkInt,
      release;
  bool isPhysicalDevice;

  var prayApiCalled = GetStorage().read(kStoredApiPrayerCall) ?? 'no calls';
  var locApiCalled = GetStorage().read(kStoredLocationLocality) ?? 'no calls';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  bool _logIsChecked = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Feedback'),
          centerTitle: true,
          actions: [
            IconButton(
                tooltip: 'Send via email',
                icon: Icon(Icons.send),
                onPressed: () {
                  print('Pressed send');
                  if (_logIsChecked) {
                    feedbackToEmail.debugLogSetter('''
                        ----------------------APP--------------------------
                        Version: ${appInfo.version}, VersionCode: ${appInfo.buildNumber}
                        ---------------------DEVICE---------------------
                        Android $release (SDK $sdkInt), $manufacture $model
                        Hardware: $hardware
                        Screen size ${MediaQuery.of(context).size.toString().substring(4)} DiP
                        PixRatio ${MediaQuery.of(context).devicePixelRatio}

                        Last prayer api called: $prayApiCalled ,
                        Location get: $locApiCalled ,
                    
                      ''');
                  }
                  feedbackToEmail.messageSetter(messageController.text);
                  feedbackToEmail.getAllData();
                  Navigator.pop(context);
                  LaunchUrl.sendViaEmail(feedbackToEmail.getAllData());
                  FocusScope.of(context).unfocus();
                })
          ],
        ),
        body: Column(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              'Any suggestion or bug report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: hintTextForFeedback,
                  border: OutlineInputBorder(),
                ),
                // textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLines: 4,
              ),
            ),
            Container(
              child: CheckboxListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Include debug info (Recommended)',
                  ),
                  value: _logIsChecked,
                  onChanged: (value) {
                    setState(() {
                      _logIsChecked = value;
                      feedbackToEmail.clearDebugLog();
                    });
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    LaunchUrl.normalLaunchUrl(
                        url: Constants.kGithubRepoLink + '/issues');
                  },
                  child: Text('Report / Follow issues on GitHub',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      board = androidInfo.board;
      brand = androidInfo.brand;
      device = androidInfo.device;
      hardware = androidInfo.hardware;
      host = androidInfo.host;
      id = androidInfo.id;
      manufacture = androidInfo.manufacturer;
      model = androidInfo.model;
      product = androidInfo.product;
      type = androidInfo.type;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
      androidid = androidInfo.androidId;
      sdkInt = androidInfo.version.sdkInt.toString();
      release = androidInfo.version.release;
    });

    // print(
    //     '$board, $brand, $device, $hardware,\n $host, $id, $manufacture, $model,\n $product, $type, $isPhysicalDevice, $androidid \n $sdkInt, $release');
    // print(
    //     'Screen size ${MediaQuery.of(context).size} \n Screen h/w ${MediaQuery.of(context).size.height}, ${MediaQuery.of(context).size.width}');
    // print('Device pix ratio: ${MediaQuery.of(context).devicePixelRatio}');
    // print(
    //     '${MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio}');
  }
}

class FeedbackCategoryButton extends StatelessWidget {
  const FeedbackCategoryButton(
      {Key key, this.label, this.outlineWidth, this.onTap})
      : super(key: key);

  final label;
  final outlineWidth;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 65.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlineButton(
          onPressed: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          borderSide: BorderSide(color: Colors.green, width: outlineWidth),
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
