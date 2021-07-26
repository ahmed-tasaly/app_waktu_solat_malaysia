import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:waktusolatmalaysia/locationUtil/locationDatabase.dart';
import 'package:waktusolatmalaysia/models/mpti906PrayerData.dart';
import 'package:waktusolatmalaysia/utils/DateAndTime.dart';
import 'package:waktusolatmalaysia/utils/mpt_fetch_api.dart';

import '../CONSTANTS.dart';

class PrayerFullTable extends StatelessWidget {
  PrayerFullTable({Key key}) : super(key: key);
  final int todayIndex = DateTime.now().day - 1;
  final int month = DateTime.now().month;
  final int locationIndex = GetStorage().read(kStoredGlobalIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // https://stackoverflow.com/questions/51948252/hide-appbar-on-scroll-flutter
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerboxIsScrolled) {
          print(innerboxIsScrolled);
          return <Widget>[
            SliverAppBar(
              floating: false,
              expandedHeight: 130,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  // ay ay yu em for life
                  'https://i2.wp.com/news.iium.edu.my/wp-content/uploads/2017/06/10982272836_29abebc100_b.jpg?ssl=1',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.overlay,
                ),
                centerTitle: true,
                title: Text(
                  '${DateAndTime.monthName(month)} timetable (${LocationDatabase.getJakimCode(locationIndex)})',
                ),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FutureBuilder(
              future: MptApiFetch.fetchMpt(
                LocationDatabase.getMptLocationCode(
                  locationIndex,
                ),
              ),
              builder: (context, AsyncSnapshot<Mpti906PrayerModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SpinKitFadingCube(size: 35, color: Colors.teal));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error);
                } else if (snapshot.hasData) {
                  return DataTable(
                    columns: [
                      'Date',
                      // 'Day',
                      'Subuh',
                      'Imsak',
                      'Zohor',
                      'Asar',
                      'Maghrib',
                      'Isyak'
                    ]
                        .map(
                          (text) => DataColumn(
                              label: Text(
                            text,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          )),
                        )
                        .toList(),
                    rows:
                        List.generate(snapshot.data.data.times.length, (index) {
                      return DataRow(selected: index == todayIndex, cells: [
                        DataCell(Text(
                          '${index + 1} / ${snapshot.data.data.month} (${DateFormat('E').format(DateTime(2021, month, index + 1))})',
                          style: TextStyle(
                              fontWeight:
                                  index == todayIndex ? FontWeight.bold : null),
                        )),
                        // DataCell(Text(DateFormat('EEEE')
                        //     .format(DateTime(2021, month, index + 1)))),
                        ...snapshot.data.data.times[index].map((day) {
                          return DataCell(Center(
                            child: Opacity(
                              opacity: (index < todayIndex) ? 0.55 : 1.0,
                              child: Text(DateAndTime.toTimeReadable(day, true),
                                  style: TextStyle(
                                      fontWeight: index == todayIndex
                                          ? FontWeight.bold
                                          : null)),
                            ),
                          ));
                        }).toList(),
                      ]);
                    }),
                  );
                } else {
                  return const Text('ERROR!');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
