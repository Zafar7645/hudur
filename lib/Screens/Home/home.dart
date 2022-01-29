import 'dart:io';

import 'package:badges/badges.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hudur/Components/api.dart';
import 'package:hudur/Components/colors.dart';
import 'package:hudur/Components/models.dart';
import 'package:hudur/Screens/AdministrativeLeaves/administrative_leaves.dart';
import 'package:hudur/Screens/Announcements/announcements.dart';
import 'package:hudur/Screens/BenchList/benchlist_page.dart';
import 'package:hudur/Screens/CheckInHistory/check_in_history.dart';
import 'package:hudur/Screens/Courses/courses.dart';
import 'package:hudur/Screens/Enquiry/enquiry_chat.dart';
import 'package:hudur/Screens/HomeDrawer/home_drawer.dart';
import 'package:hudur/Screens/LateCheckInReason/late_reason.dart';
import 'package:hudur/Screens/Leaves/leaves.dart';
import 'package:hudur/Screens/RelatedSites/related_sites.dart';
import 'package:hudur/Screens/Services/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
   Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _inTime = '';
  var _outTime = '';
  var _inDate = '';
  var _outDate = '';
  var _status = '';

  bool expand = true;
  var _vicinityLoading = false;
  String latereason;
  String gotreason;
  TextEditingController reasonController;

  File image;
  int _announcementCount;

  CountDownController _controller;
  bool loading = false;

  // ignore: unnecessary_new
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<LocationData> getUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text(
                'Location service is disabled. Please enable it to check-in.')));
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(
                'Location permission denied. Please allow it to check-in.'),
          ),
        );
        return null;
      }
    }

    _locationData = await location.getLocation();

    return _locationData;
  }

  @override
  void initState() {
    getUserLocation().then((value) {
      setState(() {
        _locationData = value;
      });
    });
    super.initState();
  }

  // Future _imagePicker() async {
  //   try {
  //     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (image == null) {
  //       return;
  //     }
  //     final imageTemporary = File(image.path);
  //     setState(() {
  //       this.image = imageTemporary;
  //     });
  //   } on PlatformException catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(e.message)));
  //   }
  // }

  Widget _countDownTimer() {
    return FutureBuilder(
      future: AllApi().getCheckIn(
        refId: widget.userModel.refId,
        date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
      ),
      // AllApi().getUser(widget.userModel.email),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Image.asset("assets/Images/loading.gif"),
          );
        } else {
          var report = snapshot.requireData;
          // var timing = snapshot.requireData[1];
          String checkInTime = "-----";
          String checkOutTime = "-----";
          String date = "-----";
          int endTime = 0;
          bool checkLoginTimeEarly =true;
          bool checkLoginTimeLate = true;
          bool checkLoginTimeBefore = true;
          int endTime1 = 0;

          int initialTime = 0;
          if (report != "No Data") {
            checkInTime = report["checkin"];
            checkOutTime = report["checkout"];
            date = report["date"];
            var dateAndTime =
                DateFormat('hh:mm a').parse(checkInTime).toString();
            var splitDateAndTime = dateAndTime.split(' ');
            checkInTime = splitDateAndTime[1];
            String day = date.substring(0, 2);
            String month = date.substring(3, 5);
            String year = date.substring(6, 10);
            date = year + '-' + month + '-' + day;
            // if (timing.studyPermit == '0' && timing.maternityPermit == '0') {


            var dateAndTimetest =
            DateFormat('hh:mm').parse(widget.userModel.reportingTime);

            print('reportTime $dateAndTimetest');



            var closinttime = dateAndTimetest.add(Duration(hours:  int.parse(widget.userModel.hoursOfShift)));
            checkLoginTimeBefore = closinttime.isBefore(dateAndTimetest);
             checkLoginTimeEarly = closinttime.isAfter(DateFormat('hh:mm').parse(DateFormat('hh:mm').format(DateTime(1970,01,01,DateTime.now().hour,DateTime.now().minute,DateTime.now().second))));
             checkLoginTimeLate = closinttime.isBefore(DateFormat('hh:mm').parse(DateFormat('hh:mm').format(DateTime.now())));

            print('close $closinttime $checkLoginTimeEarly $checkLoginTimeBefore');

            initialTime = checkLoginTimeLate ? closinttime.difference(dateAndTimetest).inHours : DateFormat('hh:mm a').parse(DateFormat('hh:mm a').format(DateTime.now())).difference(dateAndTimetest).inSeconds;

            print('initime ${DateFormat('hh:mm a').parse(DateFormat('hh:mm a').format(DateTime.now()))}');


            print(DateTime.now());
            // endTime = checkOutTime != "-----"?
            // dateAndTimetest.add(Duration(hours:  int.parse(widget.userModel.hoursOfShift))).hour : 0;

          // endTime =  closinttime.difference(DateFormat('hh:mm').parse(DateFormat('hh:mm').format(DateTime.now()))).inHours;

            endTime =  closinttime.difference(dateAndTimetest).inSeconds;

            endTime1 =
        //         closinttime.millisecondsSinceEpoch +
        // (1000 * (int.parse(widget.userModel.hoursOfShift) * 3600));

            checkOutTime == "-----"
                ? DateTime.parse(date + ' ' + DateFormat('hh:mm:ss.SSS').format(dateAndTimetest))
                        .millisecondsSinceEpoch +
                    (1000 * (int.parse(widget.userModel.hoursOfShift) * 3600))
                : 0;

            print('checvkintime ${DateFormat('hh:mm:ss.SSS').format(dateAndTimetest)}');
              // if(checkOutTime != "-----"){
              //   _controller.pause();
              // }
            // } else {
            //   endT.ime = checkOutTime == "-----"
            //       ? DateTime.parse(date + ' ' + checkInTime)
            //               .millisecondsSinceEpoch +
            //           (1000 * (5 * 3600))
            //       : 0;
            // }
            print('endtime $endTime $endTime1');
          }
          // _controller.start();
          print('endtime $endTime');
          print('initime $initialTime');
          print('checkoutime $checkOutTime ${checkOutTime != "-----"}');

          print('${initialTime > int.parse(widget.userModel.hoursOfShift) * 3600} $checkLoginTimeBefore ${checkInTime == "-----" } ${ checkOutTime != "-----" }' );

          CountdownTimerController _controller2 = CountdownTimerController(endTime: endTime1);
          return Center(
            child: Container(
              child: initialTime > int.parse(widget.userModel.hoursOfShift) *3600 || checkLoginTimeBefore || checkInTime == "-----"  ? SizedBox() : checkOutTime != "-----" ? SizedBox()
                  : Stack(
                children: [
                  CircularCountDownTimer(
                    // Countdown duration in Seconds.
                    duration: endTime ,

                    // Countdown initial elapsed Duration in Seconds.
                    initialDuration: initialTime,

                    // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                    controller: _controller,

                    // Width of the Countdown Widget.
                    width: Get.width*0.3,

                    // Height of the Countdown Widget.
                    height: Get.height*0.2,

                    // Ring Color for Countdown Widget.
                    ringColor: Colors.grey[300],

                    // Ring Gradient for Countdown Widget.
                    ringGradient: null,

                    // Filling Color for Countdown Widget.
                    fillColor: primary,

                    // Filling Gradient for Countdown Widget.
                    fillGradient: null,

                    // Background Color for Countdown Widget.
                    backgroundColor: Colors.white.withOpacity(0.8),

                    // Background Gradient for Countdown Widget.
                    backgroundGradient: null,

                    // Border Thickness of the Countdown Ring.
                    strokeWidth: 5.0,

                    // Begin and end contours with a flat edge and no extension.
                    strokeCap: StrokeCap.round,

                    // Text Style for Countdown Text.
                    textStyle: TextStyle(
                        fontSize: 33.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),

                    // Format for the Countdown Text.
                    textFormat: CountdownTextFormat.S,

                    // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                    isReverse: false,

                    // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                    isReverseAnimation: false,

                    // Handles visibility of the Countdown Text.
                    isTimerTextShown: false,

                    // Handles the timer start.
                    autoStart: true,

                    // This Callback will execute when the Countdown Starts.
                    onStart: () {
                      // Here, do whatever you want
                      print('Countdown Started');
                    },

                    // This Callback will execute when the Countdown Ends.
                    onComplete: () {
                      // Here, do whatever you want
                      print('Countdown Ended');
                    },
                  ),
                  Positioned(
                    top: Get.width*0.1,
                    left: Get.width*0.05,
                    child: CountdownTimer(
                      endWidget:  Text(''),
                      endTime: endTime1,
                      textStyle:  TextStyle(
                        color: Colors.black,
                      ),
                      controller: _controller2,
                      onEnd: () {
                        if (checkOutTime == '-----') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Shift over. You can check out now.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                ],
              )

            ),
          );
        }
      },
    );
  }

  bool expandName = false;
  Widget _home() {
    return loading
        ? Center(
            child: Image.asset("assets/Images/loading.gif"),
          )
        : FutureBuilder(
            future: AllApi().getCheckIn(
                refId: widget.userModel.refId,
                date: DateFormat('dd-MM-yyyy').format(DateTime.now())),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Image.asset("assets/Images/loading.gif"),
                );
              }

              var report = snapshot.requireData;
              var checkin = report == "No Data" ? "-----" : report["checkin"];
              var checkout = report == "No Data" ? "-----" : report["checkout"];

              var start = report == "No Data"
                  ? DateFormat('hh:mm a').parse("00:00 AM")
                  : DateFormat('hh:mm a').parse(checkin);

              var end = report == "No Data"
                  ? DateFormat('hh:mm a').parse("00:00 AM")
                  : checkout == "-----"
                      ? DateFormat('hh:mm a').parse("00:00 AM")
                      : DateFormat('hh:mm a').parse(checkout);

              Duration difference = end.difference(start);

              var differenceFinal =
                  ((difference.inSeconds / 3600)).toDouble().toPrecision(2);

              gotreason = report == "No Data" ? "-----" : report["reason"];

              _status = report == "No Data"
                  ? "-----"
                  : (start.isAfter(DateFormat('hh:mm a')
                          .parse(widget.userModel.reportingTime)
                          .add(Duration(minutes: 15))))
                      ? 'late'
                      : (start.isBefore(DateFormat('hh:mm a')
                              .parse(widget.userModel.reportingTime)
                              .add(Duration(
                                  hours: int.parse(
                                      widget.userModel.hoursOfShift)))))
                          ? 'early'
                          : 'perfect';

              return Container(
                // padding:  EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius:
                             BorderRadius.only(bottomLeft:  Radius.circular(80)),
                        color: Colors.white
                        // gradient: LinearGradient(
                        //   begin: Alignment.topRight,
                        //   end: Alignment.bottomLeft,
                        //   colors: [
                        //     // portica,
                        //     //   primary,
                        //     //  primary,
                        //     primary,
                        //     Colors.black
                        //   ],
                        // ),
                      ),
                      width: double.infinity,
                      padding:  EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionPanelList(
                            animationDuration: Duration(milliseconds: 500),
                            dividerColor: primary,
                            expansionCallback: (index,bool){
                              expandName = !bool;
                              setState(() {

                              });

                            },
                            children: [ExpansionPanel(
                              canTapOnHeader: true,
                              isExpanded:expandName,
                              body: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.userModel.phoneNumber,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          widget.userModel.designation,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          widget.userModel.email,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height * 0.1,
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      child: widget.userModel.image != null
                                          ? Image.network(
                                              '${mainurl}assets/images/employee/profile/${widget.userModel.image}',
                                              fit: BoxFit.fill,
                                            )
                                          : Image.asset(
                                              'assets/Images/homelogo.png',
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              headerBuilder: (context,ind){
                                return Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Text(
                                      widget.userModel.name,
                                      style:  TextStyle(
                                          color: primary,
                                          fontSize: 18,
                                          // fontWeight: FontWeight.bold,
                                          // shadows: [Shadow(color: Colors.blueAccent,offset: Offset(-1,0),blurRadius: 1)]
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    subtext('(', '${widget.userModel.empId})'),
                                  ],
                                );
                              }
                            )],
                          ),
                           SizedBox(
                            height: 10,
                          ),
                          checkout == "-----"
                              ? Container()
                              : Center(
                                  child: Text(
                                    'Today You Have Checked Out in ($differenceFinal) Hours',
                                    style:  TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                           SizedBox(
                            height: 20,
                          ),
                          Divider(color: primary,thickness: 3,),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // gradient: LinearGradient(
                              //   colors: [
                              //       primary,
                              //     Colors.black,
                              //
                              //   ],
                              //   begin: Alignment.topRight,
                              //   end: Alignment.bottomLeft,
                              // ),
                              shape: BoxShape.rectangle,
                              borderRadius:  BorderRadius.only(
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                            ),
                            padding:  EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Image.asset('assets/Images/attendence.png',width: 40,height: 40,),
                                    Column(
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'In Time',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                checkin,
                                                style:  TextStyle(
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Out Time',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                checkout,
                                                style:  TextStyle(
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    _countDownTimer(),
                                    SizedBox(width: 10,),
                                    Column(
                                    children: [
                                      Text(
                                        DateFormat('dd-MM-yyyy')
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Attendance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )],
                                ),
                                 
                                 SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          'In Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          checkin,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          'Out Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          checkout,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                     SizedBox(
                                      width: 30,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          'Status',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(

                                          _status,
                                          style:  TextStyle(
                                            color: Colors.black,
                                          ),

                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(color: primary,thickness: 3,),
                          SizedBox(
                            height: 20,
                          ),
                          ExpansionPanelList(
                            dividerColor: primary,
                            expansionCallback: (index,bool){
                              expand = !bool;
                              setState(() {

                              });

                            },
                            children: [ExpansionPanel(
                              headerBuilder: (context,bool){
                                return  Center(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Image.asset('assets/Images/records.png',width: 30,height: 30,),
                                      SizedBox(width: 10,),
                                      Text(
                                        'This Month Records',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },

                            canTapOnHeader: true,
                              isExpanded: expand,
                              body: FutureBuilder(
                                  future: Future.wait(
                                      [
                                    AllApi().getAttendenceCounts(
                                        empname: widget.userModel.name,
                                        companyid: widget.userModel.companyId),
                                    AllApi().getHomeLeavesCount(
                                        verify: '1',
                                        companyid: widget.userModel.companyId,
                                        refid: widget.userModel.refId)
                                  ]
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return CircularProgressIndicator(
                                        color: Colors.white,
                                      );
                                    }

                                    List<AttendanceReportModel> attendencecount =
                                        snapshot.requireData[0];
                                    List<EmployeeLeaveRequestsModel> leavescount =
                                        snapshot.requireData[1];

                                    var leavesCount = leavescount.length;

                                    var present = attendencecount.where(
                                        (element) => element.status != 'absence');

                                    var Absent = attendencecount.where(
                                        (element) => element.status == 'absence');

                                    var lateentry = attendencecount.where(
                                        (element) => element.status == 'late');

                                    var earlyexit = attendencecount.where(
                                        (element) =>
                                            element.workingstatus == 'early');

                                    var workinghours = 0.0;

                                    attendencecount.forEach((element) {
                                      workinghours +=
                                          double.parse(element.checkOutDifference);
                                    });

                                    return attendencecount != null
                                        ? Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // gradient: LinearGradient(
                                              //   colors: [
                                              //       primary,
                                              //     Colors.black,
                                              //     // Colors.brown,
                                              //
                                              //   ],
                                              //   begin: Alignment.topRight,
                                              //   end: Alignment.bottomLeft,
                                              // ),
                                              shape: BoxShape.rectangle,
                                              borderRadius:  BorderRadius.only(
                                                bottomLeft: Radius.circular(8.0),
                                                bottomRight: Radius.circular(8.0),
                                              ),
                                            ),
                                            padding:  EdgeInsets.all(5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                 SizedBox(
                                                  height: 10,
                                                ),
                                                Wrap(
                                                  alignment:
                                                      WrapAlignment.spaceEvenly,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: Get.width*0.25,
                                                      // height: Get.height*0.08,
                                                      child: buildattendencecard('Present',present),
                                                    ),
                                                    //  SizedBox(
                                                    // width: 30,
                                                    // ),
                                                    // Column(
                                                    // crossAxisAlignment:
                                                    // CrossAxisAlignment.start,
                                                    // children: [
                                                    //  Text(
                                                    // 'Holiday',
                                                    // style: TextStyle(
                                                    // fontWeight: FontWeight.bold,
                                                    // color: Colors.white,
                                                    // ),
                                                    // ),
                                                    // Text(
                                                    // checkout,
                                                    // style:  TextStyle(
                                                    // color: Colors.white,
                                                    // ),
                                                    // )
                                                    // ],
                                                    // ),
                                                     SizedBox(
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                        width: Get.width*0.25,
                                                        // height: Get.height*0.08,
                                                      child: buildattendencecard('Absent',Absent),
                                                    ),
                                                     SizedBox(
                                                      width: 15,
                                                    ),
                                                    // SizedBox(
                                                    //   width: 80,
                                                    //   height: 60,
                                                    //   child: buildattendencecard('Leave',leavescount),
                                                    // ),
                                                    SizedBox(
                                                      width: Get.width*0.25,
                                                      // height: Get.height*0.08,
                                                      child: Card(
                                                        elevation: 0,
                                                        // color: Colors
                                                        //     .green.shade900,
                                                        borderOnForeground: true,
                                                        shape: BeveledRectangleBorder(
                                                            side: BorderSide(color: primary),
                                                            borderRadius: BorderRadius.circular(10)

                                                        ),
                                                        color: Colors.blueAccent.withOpacity(0.2),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              'Leave',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                  color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 5.0),
                                                              child: Text(
                                                                leavesCount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: primary,
                                                                    shadows: [Shadow(color: Colors.black,offset: Offset(-1, 0),blurRadius: 1)]

                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: Get.width*0.25,
                                                      // height: Get.height*0.08,
                                                      child: buildattendencecard('Late Entry',lateentry),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: Get.width*0.25,
                                                      // height: Get.height*0.08,
                                                      child: buildattendencecard('Early Exit',earlyexit),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: Get.width*0.25,
                                                      // height: Get.height*0.08,
                                                      child: Card(
                                                        elevation: 0,
                                                        // color: Colors
                                                        //     .green.shade900,
                                                        borderOnForeground: false,
                                                        shape: BeveledRectangleBorder(
                                                            side: BorderSide(color: primary),
                                                            borderRadius: BorderRadius.circular(10)

                                                        ),
                                                        color: Colors.blueAccent.withOpacity(0.2),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              'Working(hrs)',
                                                              textAlign:
                                                              TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 5.0),
                                                              child: Text(
                                                                workinghours
                                                                    .toPrecision(2)
                                                                    .toString(),
                                                                style:
                                                                TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: primary,
                                                                    shadows: [Shadow(color: Colors.black,offset: Offset(-1, 0),blurRadius: 1)]
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Colors.white,
                                                ),
                                                // Wrap(
                                                //   alignment:
                                                //       WrapAlignment.spaceBetween,
                                                //
                                                //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                //   children: [
                                                //     SizedBox(
                                                // width: Get.width*0.25,
                                                //     height: Get.height*0.08,
                                                //       child: buildattendencecard('Late Entry',lateentry),
                                                //     ),
                                                //      SizedBox(
                                                //       width: 10,
                                                //     ),
                                                //     SizedBox(
                                                //         width: Get.width*0.25,
                                                //         height: Get.height*0.08,
                                                //       child: buildattendencecard('Early Exit',earlyexit),
                                                //     ),
                                                //      SizedBox(
                                                //       width: 10,
                                                //     ),
                                                //     SizedBox(
                                                //       width: Get.width*0.25,
                                                //       height: Get.height*0.08,
                                                //       child: Card(
                                                //         elevation: 1,
                                                //         // color: Colors
                                                //         //     .green.shade900,
                                                //         borderOnForeground: false,
                                                //         shape: BeveledRectangleBorder(
                                                //             side: BorderSide(color: primary),
                                                //             borderRadius: BorderRadius.circular(10)
                                                //
                                                //         ),
                                                //                 color: Colors.blueAccent.withOpacity(0.2),
                                                //         child: Column(
                                                //           crossAxisAlignment:
                                                //               CrossAxisAlignment
                                                //                   .center,
                                                //           children: [
                                                //              SizedBox(
                                                //               height: 5,
                                                //             ),
                                                //              Text(
                                                //               'Working(hrs)',
                                                //               textAlign:
                                                //                   TextAlign.center,
                                                //               style: TextStyle(
                                                //                 fontSize: Get.width*0.035,
                                                //                 fontWeight:
                                                //                 FontWeight.bold,
                                                //                 color: Colors.black,
                                                //               ),
                                                //             ),
                                                //              SizedBox(
                                                //               height: 5,
                                                //             ),
                                                //             Text(
                                                //               workinghours
                                                //                   .toPrecision(2)
                                                //                   .toString(),
                                                //               style:
                                                //                    TextStyle(
                                                //                        fontWeight: FontWeight.bold,
                                                //                        fontSize: Get.width*0.05,
                                                //                        color: primary,
                                                //                        shadows: [Shadow(color: Colors.black,offset: Offset(-1, 0),blurRadius: 1)]
                                                //                    ),
                                                //             ),
                                                //           ],
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  portica,
                                                    primary,
                                                ],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                              ),
                                              shape: BoxShape.rectangle,
                                              borderRadius:  BorderRadius.only(
                                                bottomLeft: Radius.circular(8.0),
                                                bottomRight: Radius.circular(8.0),
                                              ),
                                            ),
                                            padding:  EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'This Month',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                 Text(
                                                  'Records',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                 SizedBox(
                                                  height: 10,
                                                ),
                                                Wrap(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Present',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          checkin,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                     SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Holiday',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          checkout,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                     SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Absent',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          _status,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                     SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Leave',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          _status,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Colors.white,
                                                ),
                                                Wrap(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Late Entry',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          checkin,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                     SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Early Exit',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          checkout,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                     SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                         Text(
                                                          'Working Hours',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          _status,
                                                          style:  TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                  }),
                            )],
                          ),
                        ],
                      ),
                    ),

                    GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2

                    ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        dashcards(context, checkin, checkout,'CHECK IN',() {
                          if (checkin != "-----" && checkout == "-----") {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title:  Text(
                                    'You have already checked-in.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child:  Text(
                                        'Dismiss',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _confirmCheckInDialogBox();
                          }
                        },'assets/Images/checkin.png'),
                        dashcards(context, checkin, checkout, 'CHECK OUT',() {
                          if (checkin == "-----") {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title:  Text(
                                    'You need to check-in first.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child:  Text(
                                        'Dismiss',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (checkout != "-----") {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title:  Text(
                                      'You have Checked out Already',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child:  Text(
                                          'Dismiss',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              _confirmCheckOutDialogBox(
                                checkin: checkin,
                                differenceFinal: differenceFinal,
                              );
                            }
                          }
                        },'assets/Images/checkout.png'),
                        dashcards(context, checkin, checkout,'LEAVE REQUESTS',() {
                          Get.to(
                                () => Leaves(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/leave.png'),
                        dashcards(context, checkin, checkout,  'COURSES',() {
                          Get.to(
                                () => Courses(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/courses.png'),
                        dashcards(context, checkin, checkout,  'SERVICES',() {
                          Get.to(
                                () => Services(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/services.png'),
                        dashcards(context, checkin, checkout,  'ENQUIRY',() {
                          Get.to(
                                () => EnquiryChat(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/enquiry.png'),
                        dashcards(context, checkin, checkout,  'BENCH LIST',() {
                          Get.to(
                                () => BenchList(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/benchlist.png'),
                        dashcards(context, checkin, checkout,  'ATTENDENCE',() {
                          Get.to(
                                () => CheckInHistory(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/history.png'),

                        dashcards(context, checkin, checkout,  'FAULTY ATTENDANCE',() {
                          Get.to(
                                () => LateReason(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/faultycheckin.png'),

                        dashcards(context, checkin, checkout,  'ADMINISTRATIVE LEAVE',() {
                          Get.to(
                                () => AdministrativeLeaves(
                              userModel: widget.userModel,
                            ),
                          );
                        },'assets/Images/adminleave.png'),
                        dashcards(context, checkin, checkout,  'RELATED SITES',() {
                          Get.to(RelatedSites(
                            userModel: widget.userModel,
                          ));
                        },'assets/Images/relatedsite.png'),


                      ],
                    )

                  ],
                ),
              );
            },
          );
  }

  Card buildattendencecard(String title,Iterable<AttendanceReportModel> present) {
    return Card(
                                                      elevation: 0,
                                                     color: Colors
                                                          .blueAccent.withOpacity(0.2),
                                                           borderOnForeground: false,

                                                      shape: BeveledRectangleBorder(

                                                        side: BorderSide(color: primary),
                                                        borderRadius: BorderRadius.circular(10)

                                                      ),

                                                      child: Column(

                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,

                                                        children: [

                                                          SizedBox(
                                                            height: 3,
                                                          ),

                                                          Text(
                                                            title,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),

                                                          SizedBox(
                                                            height: 5,
                                                          ),

                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 5.0),
                                                            child: Text(
                                                              present.length
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 14,
                                                                color: primary,
                                                                  shadows: [Shadow(color: Colors.black,offset: Offset(-1, 0),blurRadius: 1)]

                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
  }

  Text subtext(String text,String value) {
    return Text(
                                  text + value,
                                  style:  TextStyle(
                                    color: Colors.black,
                                      shadows: [Shadow(color: Colors.black,offset: Offset(-1,-1),blurRadius: 3)]
                                  ),
                                );
  }

  InkWell dashcards(BuildContext context, checkin, checkout,title,onTap,image) {
    return InkWell(
                          child: Card(
                            elevation: 10,
                            color: Colors.white,
                            shadowColor: primary,

                            shape:  RoundedRectangleBorder(
                              side: BorderSide(color: primary),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height:
                                  MediaQuery.of(context).size.height * 0.2,
                              padding:  EdgeInsets.all(22.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:  [
                                  Image.asset(
                                  image,
                                     width: 20,
                                    height: 20,
                                    // color: Colors.green.shade900,
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: onTap,
                        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Images/background_image.jpg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:   primary,
          title: FutureBuilder(
              future: AllApi().getCompanyDetails(companyid: widget.userModel.companyId),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: hippieBlue,),
                  );
                }

                var companydetails = snapshot.requireData;


                return Container(
                  color: primary,
                  height: Get.height,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${adminurl}/assets/images/company/logo/${companydetails['image']}',
                          fit:BoxFit.fill,
                          width: 50,
                          height: 50,
                          loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null ?
                                loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 5,),
                      Center(
                        child: Container(
                          width: Get.width*0.4,
                          child: Text(
                            companydetails['cname'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )
                  ,
                );
              }
          ),
          actions: [
            // _countDownTimer(),
            FutureBuilder<List<AnnounceModel>>(
              future: AllApi().getAnnounce(
                companyId: widget.userModel.companyId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return IconButton(
                    onPressed: () {
                      Get.to(
                        () => Announcements(
                          userModel: widget.userModel,
                        ),
                      );
                    },
                    icon: Badge(
                      badgeColor: portica,
                      badgeContent:  FittedBox(
                        child: Text(
                          '!',
                        ),
                      ),
                      child:  Icon(
                        Icons.notifications,
                      ),
                    ),
                  );
                }
                var announcements = snapshot.data;
                _announcementCount = announcements.length;
                return IconButton(
                  onPressed: () {
                    _controller.start();
                    Get.to(
                      () => Announcements(
                        userModel: widget.userModel,
                      ),
                    );
                  },
                  icon: Badge(
                    badgeColor: portica,
                    badgeContent: FittedBox(
                      child: Text(
                        '$_announcementCount',
                      ),
                    ),
                    child:  Icon(
                      Icons.notifications,
                    ),
                  ),
                );
              },
            ),

            SizedBox(width: 10,),
            Center(child: InkWell(
                onTap: () async {
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      title: Text('Are you sure you want to logout ?'),
                      actions: [
                        ElevatedButton(onPressed: () async {

                          var  pref = await SharedPreferences.getInstance();

                          pref.clear();

                          Get.offAll(
                                () => MyApp(

                            ),
                          );
                        }, child: Text('Yes')),
                        ElevatedButton(onPressed: (){
                          Get.back();
                        }, child: Text('No'))
                      ],
                    );
                  });

                },
                child: Text('LOGOUT')
            )),
            SizedBox(width: 10,),
          ],
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            var announcements = await AllApi().getAnnounce(
              companyId: widget.userModel.companyId,
            );
            setState(() {
              _announcementCount = announcements.length;
            });
            return announcements.length;
          },
          child: SingleChildScrollView(
            child: Container(
              child: _home(),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCheckInDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: _vicinityLoading
                ? null
                :  Text(
                    'Confirm Check In',
                  ),
            content: _vicinityLoading
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    alignment: Alignment.center,
                    child: Row(
                      children:  [
                        CircularProgressIndicator(),
                        SizedBox(
                          width: 30,
                        ),
                        Text('Please wait'),
                      ],
                    ),
                  )
                : null,
            actions: _vicinityLoading
                ? null
                : [
                    TextButton(
                      child:  Text(
                        'Check-In',
                      ),
                      onPressed: () async {
                        setStateDialog(() {
                          _vicinityLoading = true;
                        });

                        var result = await AllApi().getVicinity(
                          refId: widget.userModel.refId,
                          latitude: _locationData.latitude,
                          longitude: _locationData.longitude,
                        );

                        setStateDialog(() {
                          _vicinityLoading = false;
                        });

                        UserModel allowCheckIn = await AllApi().getUser(
                          widget.userModel.email,
                        );

                        print('$result + ${allowCheckIn}');

                        if (result == true || allowCheckIn.allow_checkin) {
                          _inTime =
                              DateFormat('hh:mm a').format(DateTime.now());
                          _inDate =
                              DateFormat('dd-MM-yyyy').format(DateTime.now());
                          Get.back();

                          setState(
                            () {
                              loading = true;

                              print(
                                  'reporting time = ${DateFormat('hh:mm a').parse(widget.userModel.reportingTime).add(Duration(minutes: 15))}');
                              print(
                                  'today time = ${DateFormat('hh:mm a').parse(_inTime)}');
                              ('today time = ${DateFormat('hh:mm a').parse(_inTime)}');

                              print(DateFormat('hh:mm a')
                                  .parse(_inTime)
                                  .isAfter(DateFormat('hh:mm a')
                                      .parse(widget.userModel.reportingTime)
                                      .add(Duration(minutes: 15))));

                              _status = (DateFormat('hh:mm a')
                                      .parse(_inTime)
                                      .isAfter(DateFormat('hh:mm a')
                                          .parse(widget.userModel.reportingTime)
                                          .add(Duration(minutes: 15))))
                                  ? 'late'
                                  : (DateFormat('hh:mm a')
                                          .parse(_inTime)
                                          .isBefore(DateFormat('hh:mm a')
                                              .parse(widget
                                                  .userModel.reportingTime)
                                              .add(Duration(
                                                  hours: int.parse(widget
                                                      .userModel
                                                      .hoursOfShift)))))
                                      ? 'early'
                                      : 'perfect';
                            },
                          );

                          if (_status == 'late') {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                var isLoading = false;
                                return StatefulBuilder(
                                  builder: (context, setStateDialog2) =>
                                      AlertDialog(
                                    title: isLoading
                                        ? null
                                        :  Text(
                                            'Give Reason for Late Check-In',
                                          ),
                                    content: isLoading
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            alignment: Alignment.center,
                                            child: Row(
                                              children:  [
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Text('Please wait'),
                                              ],
                                            ),
                                          )
                                        : TextFormField(
                                            enabled: true,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Reason for Late Check-In',
                                              hintStyle:  TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            controller: reasonController,
                                            onChanged: (value) {
                                              setState(() {
                                                latereason = value;
                                              });
                                            },
                                          ),
                                    actions: isLoading
                                        ? null
                                        : [
                                            TextButton(
                                              child:  Text(
                                                'Submit',
                                              ),
                                              onPressed: () async {
                                                setStateDialog2(() {
                                                  isLoading = true;
                                                });

                                                await AllApi().postCheckIn(
                                                    designation: widget
                                                        .userModel.designation,
                                                    checkInTime: _inTime,
                                                    checkOutTime: '-----',
                                                    date: _inDate,
                                                    refId:
                                                        widget.userModel.refId,
                                                    companyId: widget
                                                        .userModel.companyId,
                                                    reason: latereason,
                                                    status: _status);

                                                setStateDialog2(() {
                                                  isLoading = false;
                                                });
                                                Get.back();
                                                setState(
                                                  () {
                                                    loading = false;
                                                  },
                                                );
                                              },
                                            ),
                                            TextButton(
                                              child:  Text(
                                                'Cancel',
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  loading = false;
                                                });
                                              },
                                            ),
                                          ],
                                  ),
                                );
                              },
                            );
                          } else {
                            await AllApi().postCheckIn(
                              designation: widget.userModel.designation,
                              checkInTime: _inTime,
                              checkOutTime: '-----',
                              date: _inDate,
                              refId: widget.userModel.refId,
                              companyId: widget.userModel.companyId,
                              status: _status,
                            );

                            setState(
                              () {
                                loading = false;
                              },
                            );
                          }
                        } else {
                          Get.back();
                          _sendRequestDialogBox();
                        }
                      },
                    ),
                    TextButton(
                      child:  Text(
                        'Cancel',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
          ),
        );
      },
    );
  }

  void _confirmCheckOutDialogBox({
    @required dynamic checkin,
    @required double differenceFinal,
  }) {
    var isLoading = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: isLoading
                  ? null
                  :  Text(
                      'Confirm Check Out',
                    ),
              content: isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      alignment: Alignment.center,
                      child: Row(
                        children:  [
                          CircularProgressIndicator(),
                          SizedBox(
                            width: 30,
                          ),
                          Text('Please wait'),
                        ],
                      ),
                    )
                  : null,
              actions: isLoading
                  ? null
                  : [
                      TextButton(
                        child:  Text(
                          'Check-Out',
                        ),
                        onPressed: () async {
                          _outTime =
                              DateFormat('hh:mm a').format(DateTime.now());
                          _outDate =
                              DateFormat('dd-MM-yyyy').format(DateTime.now());

                          setStateDialog(() {
                            isLoading = true;
                          });

                          setState(() {
                            loading = true;
                          });

                          await AllApi().postCheckIn(
                            designation: widget.userModel.designation,
                            companyId: widget.userModel.companyId,
                            checkInTime: checkin,
                            checkOutTime: _outTime,
                            date: _outDate,
                            refId: widget.userModel.refId,
                            status: _status,
                          );

                          var time1 = DateFormat('hh:mm a').parse(checkin);
                          var time2 = DateFormat('hh:mm a')
                              .parse(widget.userModel.reportingTime);

                          var delayInHours = time2.difference(time1).inHours;

                          var delayInMinutes =
                              time2.difference(time1).inMinutes;

                          // if (delayInHours < 0 || delayInMinutes < 0) {
                          //   setStateDialog(() {
                          //     _status = 'late';
                          //   });
                          // } else if (delayInHours > 0 || delayInMinutes > 0) {
                          //   setStateDialog(() {
                          //     _status = 'early';
                          //   });
                          // } else {
                          //   setStateDialog(() {
                          //     _status = 'perfect';
                          //   });
                          // }

                          await AllApi().postAttendanceReport(
                            employeeName: widget.userModel.name,
                            checkInTime: checkin,
                            checkOutTime: _outTime,
                            checkInDelayInHours: delayInHours.toString(),
                            checkInDelayInMinutes: delayInMinutes.toString(),
                            checkOutDifference: differenceFinal.toString(),
                            companyId: widget.userModel.companyId,
                            empId: widget.userModel.empId,
                            status: _status,
                            reason: gotreason,
                            designation: widget.userModel.designation,
                            hours: int.parse(
                              widget.userModel.hoursOfShift,
                            ),
                          );

                          setStateDialog(() {
                            isLoading = false;
                          });

                          setState(() {
                            loading = false;
                          });

                          Get.back();
                        },
                      ),
                      TextButton(
                        child:  Text(
                          'Cancel',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
            );
          },
        );
      },
    );
  }

  void _sendRequestDialogBox() {
    var isLoading = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: isLoading
                  ? null
                  :  Text(
                      'Check-in not allowed.',
                    ),
              content: isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      alignment: Alignment.center,
                      child: Row(
                        children:  [
                          CircularProgressIndicator(),
                          SizedBox(
                            width: 30,
                          ),
                          Text('Please wait'),
                        ],
                      ),
                    )
                  :  Text(
                      'You aren\'t in the vicinity of 250 metres from your office.',
                    ),
              actions: isLoading
                  ? null
                  : [
                      TextButton(
                        onPressed: () async {
                          setStateDialog(() {
                            isLoading = true;
                          });

                          var allowCheckIn = await AllApi().getUser(
                            widget.userModel.email,
                          );

                          if (allowCheckIn.allow_checkin) {
                            _inTime = DateFormat(
                              'hh:mm a',
                            ).format(
                              DateTime.now(),
                            );
                            _inDate = DateFormat(
                              'dd-MM-yyyy',
                            ).format(
                              DateTime.now(),
                            );

                            setStateDialog(() {
                              isLoading = false;
                            });

                            Get.back();

                            setState(
                              () {
                                loading = true;
                                _status = (DateFormat('hh:mm a')
                                        .parse(_inTime)
                                        .isAfter(DateFormat('hh:mm a')
                                            .parse(
                                                widget.userModel.reportingTime)
                                            .add(Duration(minutes: 15))))
                                    ? 'late'
                                    : (DateFormat('hh:mm a')
                                            .parse(_inTime)
                                            .isBefore(DateFormat('hh:mm a')
                                                .parse(widget
                                                    .userModel.reportingTime)
                                                .add(Duration(
                                                    hours:
                                                        int.parse(widget.userModel.hoursOfShift)))))
                                        ? 'early'
                                        : 'perfect';
                              },
                            );

                            if (_status == 'late') {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  var isLoading = false;
                                  return StatefulBuilder(
                                    builder: (context, setStateDialog2) =>
                                        AlertDialog(
                                      title: isLoading
                                          ? null
                                          :  Text(
                                              'Give Reason for Late Check-In',
                                            ),
                                      content: isLoading
                                          ? Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              alignment: Alignment.center,
                                              child: Row(
                                                children:  [
                                                  CircularProgressIndicator(),
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  Text('Please wait'),
                                                ],
                                              ),
                                            )
                                          : TextFormField(
                                              enabled: true,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Reason for Late Check-In',
                                                hintStyle:  TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              controller: reasonController,
                                              onChanged: (value) {
                                                setState(() {
                                                  latereason = value;
                                                });
                                              },
                                            ),
                                      actions: isLoading
                                          ? null
                                          : [
                                              TextButton(
                                                child:  Text(
                                                  'Submit',
                                                ),
                                                onPressed: () async {
                                                  setStateDialog2(() {
                                                    isLoading = true;
                                                  });

                                                  await AllApi().postCheckIn(
                                                      designation: widget
                                                          .userModel
                                                          .designation,
                                                      checkInTime: _inTime,
                                                      checkOutTime: '-----',
                                                      date: _inDate,
                                                      refId: widget
                                                          .userModel.refId,
                                                      companyId: widget
                                                          .userModel.companyId,
                                                      reason: latereason,
                                                      status: _status);

                                                  await AllApi()
                                                      .postOuterGeoList(
                                                    designation: widget
                                                        .userModel.designation,
                                                    empName:
                                                        widget.userModel.name,
                                                    companyId: widget
                                                        .userModel.companyId,
                                                    refId:
                                                        widget.userModel.refId,
                                                    date: _inDate,
                                                    lat: _locationData.latitude
                                                        .toString(),
                                                    lon: _locationData.longitude
                                                        .toString(),
                                                  );

                                                  Fluttertoast.showToast(
                                                    msg: "Logged in",
                                                  );

                                                  setStateDialog2(() {
                                                    isLoading = false;
                                                  });
                                                  Get.back();
                                                  setState(
                                                    () {
                                                      loading = false;
                                                    },
                                                  );
                                                },
                                              ),
                                              TextButton(
                                                child:  Text(
                                                  'Cancel',
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              await AllApi().postCheckIn(
                                  designation: widget.userModel.designation,
                                  checkInTime: _inTime,
                                  checkOutTime: '-----',
                                  date: _inDate,
                                  refId: widget.userModel.refId,
                                  companyId: widget.userModel.companyId,
                                  status: _status);

                              await AllApi().postOuterGeoList(
                                designation: widget.userModel.designation,
                                empName: widget.userModel.name,
                                companyId: widget.userModel.companyId,
                                refId: widget.userModel.refId,
                                date: _inDate,
                                lat: _locationData.latitude.toString(),
                                lon: _locationData.longitude.toString(),
                              );

                              Fluttertoast.showToast(
                                msg: "Logged in",
                              );

                              setState(
                                () {
                                  loading = false;
                                },
                              );
                            }
                          } else {
                            await AllApi().postCheckInRequest(
                                designation: widget.userModel.designation,
                                companyId: widget.userModel.companyId,
                                date: DateFormat('dd-MM-yyyy').format(
                                  DateTime.now(),
                                ),
                                refId: widget.userModel.refId,
                                lat: _locationData.latitude.toString(),
                                lon: _locationData.longitude.toString(),
                                name: widget.userModel.name);

                            setStateDialog(() {
                              isLoading = false;
                            });

                            setState(
                              () {
                                loading = false;
                              },
                            );

                            Get.back();

                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(
                                  'You are not allowed to check-in.',
                                ),
                              ),
                            );
                          }
                        },
                        child:  Text(
                          'Send Request',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child:  Text(
                          'Cancel',
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
