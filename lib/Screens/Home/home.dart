import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:hudur/Components/api.dart';
import 'package:hudur/Components/models.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  const Home({Key? key, required this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _selectedIndex = 0;
  var _isCheckedIn = false;
  var _isCheckedOut = false;
  var _inTime = '';
  var _outTime = '';
  var _inDate = '';
  var _outDate = '';
  var _remainingTimeHours = 0;
  var _remainingTimeMinutes = 0;
  var _remainingTimeSeconds = 0;
  late CountdownTimerController _controller;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _countDowmTimer() {
    int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 25200;
    _controller = CountdownTimerController(endTime: endTime);
    return Center(
        child: Container(
      padding: const EdgeInsets.all(8.0),
      child: CountdownTimer(
        endTime: endTime,
        textStyle: const TextStyle(
          color: Colors.black,
        ),
        controller: _controller,
      ),
    ));
  }

  Widget _home() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Colors.green,
                ],
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    widget.userModel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.green,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'In Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _isCheckedIn || _isCheckedOut
                                      ? _inTime
                                      : '-----',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Out Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _isCheckedOut ? _outTime : '-----',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Perfect',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Card(
                    color: Colors.amber,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    child: SizedBox(
                      width: 150,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.login,
                            size: 70,
                            color: Colors.white,
                          ),
                          Text(
                            'CHECK IN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    _inTime = DateFormat('hh:mm a').format(DateTime.now());
                    _inDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            backgroundColor: Colors.green,
                            title: const Text(
                              'Confirm Check In',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text(
                                  'Check-In',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  await AllApi().postCheckIn(
                                    checkInTime: _inTime,
                                    checkOutTime: '-----',
                                    date: _inDate,
                                    phoneNumber: widget.userModel.phoneNumber,
                                  );
                                  setState(() {
                                    _isCheckedIn = true;
                                    _isCheckedOut = false;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                InkWell(
                  child: Card(
                    color: Colors.amber,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    child: SizedBox(
                      width: 150,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout,
                            size: 70,
                            color: Colors.white,
                          ),
                          Text(
                            'CHECK OUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    _outTime = DateFormat('hh:mm a').format(DateTime.now());
                    _outDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            backgroundColor: Colors.green,
                            title: const Text(
                              'Confirm Check Out',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text(
                                  'Check-Out',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  await AllApi().postCheckIn(
                                    checkInTime: _inTime,
                                    checkOutTime: _outTime,
                                    date: _inDate,
                                    phoneNumber: widget.userModel.phoneNumber,
                                  );
                                  setState(() {
                                    _isCheckedOut = true;
                                    _isCheckedIn = false;
                                    _remainingTimeHours = _controller
                                        .currentRemainingTime!.hours!;
                                    _remainingTimeMinutes =
                                        _controller.currentRemainingTime!.min!;
                                    _remainingTimeSeconds =
                                        _controller.currentRemainingTime!.sec!;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      onTap: (value) {
        _onItemTapped(value);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: Colors.amber,
          ),
          label: 'Home',
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.book_rounded,
            color: Colors.amber,
          ),
          label: 'Attendance',
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.location_city_rounded,
            color: Colors.amber,
          ),
          label: 'Location',
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.amber,
          ),
          label: 'Chat',
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: Colors.amber,
          ),
          label: 'Settings',
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      _home(),
      const Text(
        'Index 1: Business',
      ),
      const Text(
        'Index 2: School',
      ),
      const Text(
        'Index 3: School',
      ),
      const Text(
        'Index 4: School',
      ),
    ];
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Images/background_image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            if (_isCheckedIn) _countDowmTimer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }
}
