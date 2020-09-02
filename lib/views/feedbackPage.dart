import 'package:flutter/material.dart';
import 'package:waktusolatmalaysia/utils/AppInformation.dart';
import 'package:waktusolatmalaysia/utils/launchUrl.dart';

enum FeedbackCategory { suggestion, bug, compliment }

class FeedbackToEmail {
  String _emoji;
  String _feedbackType;
  String _message;
  String _debugLog;

  void emojiSetter(String emoji) {
    this._emoji = emoji;
  }

  void feedbackTypeSetter(String feedbackCategory) {
    this._feedbackType = feedbackCategory;
  }

  void messageSetter(String message) {
    this._message = message;
  }

  void debugLogSetter(String debugLog) {
    this._debugLog = debugLog;
  }

  String getAllData() {
    String data = '''$_emoji $_emoji $_emoji $_emoji $_emoji

    category: $_feedbackType, 
    Message: $_message, 
    <---------Debug log:---------------
    $_debugLog
    --------------------------------->''';
    print(data);
    return data;
  }
}

class Feedmoji {
  bool isSelected;
  final String emojiText;

  Feedmoji(this.isSelected, this.emojiText);
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
  String hintTextForFeedback = 'Please leave your feedback below';
  List<Feedmoji> feedmoji = List<Feedmoji>();
  FeedbackToEmail feedbackToEmail = FeedbackToEmail();
  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    feedmoji.add(Feedmoji(true, '😠'));
    feedmoji.add(Feedmoji(true, '🙁'));
    feedmoji.add(Feedmoji(true, '😐'));
    feedmoji.add(Feedmoji(true, '😄'));
    feedmoji.add(Feedmoji(true, '😍'));
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
                    feedbackToEmail
                        .debugLogSetter('''Versiom: ${appInfo.version}
                    Screen h/w ${MediaQuery.of(context).size.height}, ${MediaQuery.of(context).size.width}
                    ''');
                  }
                  feedbackToEmail.messageSetter(messageController.text);
                  feedbackToEmail.getAllData();
                  LaunchUrl.sendViaEmail(feedbackToEmail.getAllData());
                  FocusScope.of(context).unfocus();
                })
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('I would like to hear from you :)))'),
            Divider(
              height: 25.0,
            ),
            Text('What is your opinion for this app?'),
            Flexible(
              child: Container(
                height: 60,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: feedmoji.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              feedmoji.forEach((element) {
                                element.isSelected = false;
                                feedmoji[index].isSelected = true;
                                feedbackToEmail
                                    .emojiSetter(feedmoji[index].emojiText);
                              });
                            },
                          );
                        },
                        child: EmojiReaction(feedmoji[index]),
                      );
                    }),
              ),
            ),
            Divider(),
            Text('Please select feedback category below'),
            SizedBox(
              height: 10.0,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FeedbackCategoryButton(
                    label: 'Suggestion',
                    outlineWidth:
                        feedbackCategory == FeedbackCategory.suggestion
                            ? selectedOutlineWidth
                            : unselectedOutlineWidth,
                    onTap: () {
                      setState(() {
                        feedbackCategory = FeedbackCategory.suggestion;
                        hintTextForFeedback = 'Urmm I\'ve a suggestion...';
                        feedbackToEmail.feedbackTypeSetter('Suggestion');
                      });
                    },
                  ),
                  FeedbackCategoryButton(
                    label: 'Something not quite right',
                    outlineWidth: feedbackCategory == FeedbackCategory.bug
                        ? selectedOutlineWidth
                        : unselectedOutlineWidth,
                    onTap: () {
                      setState(() {
                        feedbackCategory = FeedbackCategory.bug;
                        hintTextForFeedback = 'Eww I found a bug(s)';
                        feedbackToEmail
                            .feedbackTypeSetter('Something not quite right');
                      });
                    },
                  ),
                  FeedbackCategoryButton(
                    label: 'Compliment',
                    outlineWidth:
                        feedbackCategory == FeedbackCategory.compliment
                            ? selectedOutlineWidth
                            : unselectedOutlineWidth,
                    onTap: () {
                      setState(() {
                        feedbackCategory = FeedbackCategory.compliment;
                        hintTextForFeedback = 'haha write anything you want';
                        feedbackToEmail.feedbackTypeSetter('Compliment');
                      });
                    },
                  )
                ]),
            Divider(),
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
                    });
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class EmojiReaction extends StatelessWidget {
  EmojiReaction(this.feedmoji);
  final Feedmoji feedmoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Opacity(
        // opacity: 0.5,
        opacity: feedmoji.isSelected ? 1.0 : 0.37,
        child: Text(
          feedmoji.emojiText,
          style: TextStyle(fontSize: 30.0),
        ),
      ),
    );
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
