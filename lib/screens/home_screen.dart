import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/screens/bloc/dispatcher_bloc.dart';
import 'package:lunad_dispatcher/screens/bloc/request_bloc.dart';
import 'package:lunad_dispatcher/screens/bloc/rider_bloc.dart';
import 'package:lunad_dispatcher/screens/booking_information_screen.dart';
import 'package:lunad_dispatcher/screens/requests_screen.dart';
import 'package:lunad_dispatcher/screens/riders_screen.dart';
import 'package:lunad_dispatcher/screens/users_screen.dart';
import 'package:lunad_dispatcher/services/file_service.dart';
import 'package:lunad_dispatcher/services/location_service.dart';
import 'package:lunad_dispatcher/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController _googleMapController;
  int _acceptedRequestsCount = 0;
  int _availableRidersCount = 0;
  int _totalRidersCount = 0;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final _initialCameraPosition = CameraPosition(
    target: LatLng(13.621775, 123.194824),
    zoom: 15,
  );
  List<ConsumerRequest> placedRequests = [];

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Lunad Dispatcher',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.bars),
          onPressed: () => _openDrawer(context),
        ),
        actions: [
          BlocProvider<RequestBloc>(
            create: (context) => RequestBloc()..add(StreamPlacedRequests()),
            child: BlocListener<RequestBloc, RequestState>(
              listener: (context, state) async {
                if (state is LoadedPlacedRequests) {
                  var requests = state.placedRequests;
                  if (requests.isNotEmpty) {
                    if (_notification == AppLifecycleState.paused ||
                        _notification == AppLifecycleState.inactive) {
                      await NotificationService()
                          .showRequestPlacedNotification();
                    }
                  }
                  setState(() {
                    _acceptedRequestsCount = requests.length;
                    placedRequests = requests;
                  });
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                    top: _acceptedRequestsCount > 0 ? 10.0 : 0, right: 20.0),
                child: GestureDetector(
                  onTap: () => _onNotificationsTapped(context),
                  child: Badge(
                    padding: EdgeInsets.all(6.0),
                    badgeContent: Text(
                      _acceptedRequestsCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    showBadge: _acceptedRequestsCount > 0,
                    child: FaIcon(FontAwesomeIcons.solidBell),
                    badgeColor: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.red.shade400,
            width: double.infinity,
            height: screenHeight - paddingTop,
            child: GoogleMap(
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(_markers.values),
            ),
          ),
          BlocProvider<DispatcherBloc>(
            create: (context) => DispatcherBloc()
              ..add(
                GetInitialInfo(
                  DateFormat.yMd().format(
                    DateTime.now(),
                  ),
                ),
              ),
            child: BlocBuilder<DispatcherBloc, DispatcherState>(
              builder: (context, state) {
                if (state is InitialInfoLoaded) {
                  return Positioned(
                    bottom: 10.0,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      height: screenHeight * .33,
                      width: screenWidth * .95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.red.shade900.withOpacity(0.8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.yMMMMEEEEd().format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 20.0,
                            ),
                          ),
                          Divider(color: Colors.white),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        color: Colors.red.shade400,
                                        child: Column(
                                          children: [
                                            Text(
                                              'Available Riders',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _availableRidersCount.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    BlocProvider<RiderBloc>(
                                      create: (context) =>
                                          RiderBloc()..add(StreamRiders()),
                                      child:
                                          BlocListener<RiderBloc, RiderState>(
                                        listener: (context, state) {
                                          if (state is LoadedRiders) {
                                            print('loaded riders');
                                            final riders = state.riders;
                                            _addRiderMarkers(riders);

                                            setState(() {
                                              _totalRidersCount = riders.length;
                                              _availableRidersCount = riders
                                                  .where((rider) =>
                                                      rider.isAvailable)
                                                  .length;
                                            });
                                          }
                                        },
                                        child: Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            color: Colors.red.shade400,
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Total Riders',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  _totalRidersCount.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    BlocProvider<DispatcherBloc>(
                                      create: (context) => DispatcherBloc()
                                        ..add(GetInitialInfo(
                                          DateFormat.yMd().format(
                                            DateTime.now(),
                                          ),
                                        )),
                                      child: BlocListener<DispatcherBloc,
                                          DispatcherState>(
                                        listener: (context, state) {
                                          if (state is InitialInfoLoaded) {
                                            print(
                                                state.completedDeliveriesCount);
                                          }
                                        },
                                        child: Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            color: Colors.red.shade400,
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Completed Requests',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  state.completedRequestsCount
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        color: Colors.red.shade400,
                                        child: Column(
                                          children: [
                                            Text(
                                              'Completed Deliveries',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              state.completedDeliveriesCount
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        color: Colors.red.shade400,
                                        child: Column(
                                          children: [
                                            Text(
                                              'Completed Errands',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              state.completedErrandsCount
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Text('');
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
              ),
              child: SizedBox(
                child: Image.asset(
                  'assets/images/logo_white.png',
                  width: 35.0,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text('Consumers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.motorcycle_rounded),
              title: Text('Riders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RidersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _onNotificationsTapped(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Placed Requests',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                    fontFamily: 'Poppins',
                    fontSize: 20.0,
                  ),
                ),
              ),
              Text(
                'Tap on a request to view details or assign a rider',
                style: TextStyle(
                  color: Colors.red.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              Divider(color: Colors.red.shade900),
              Expanded(
                child: ListView(
                  children: placedRequests.isNotEmpty
                      ? placedRequests.map((request) {
                          return GestureDetector(
                            onTap: () => onRequestTap(context, request),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              width: double.infinity,
                              padding: EdgeInsets.all(12.0),
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${request.consumerName} placed a ${request.type} request.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      DateFormat.yMMMd().format(
                                          request.dateRequested.toDate()),
                                      style: TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          SizedBox(height: 35.0),
                          Center(
                            child: Text(
                              'No placed requests yet',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          )
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  onRequestTap(BuildContext context, ConsumerRequest request) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingInformationScreen(
          requestId: request.id,
          type: request.type,
        ),
      ),
    );
  }

  _addRiderMarkers(List<Rider> riders) async {
    var _markerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        'assets/images/markers/marker-rider.png',
        60,
      ),
    );

    List<LatLng> latLngList = [];

    for (var rider in riders) {
      if (rider.currentLocation != null) {
        final _markerId = MarkerId(rider.id);

        latLngList
            .add(LatLng(rider.currentLocation[0], rider.currentLocation[1]));

        final marker = Marker(
          markerId: _markerId,
          position: LatLng(rider.currentLocation[0], rider.currentLocation[1]),
          icon: _markerIcon,
        );

        setState(() {
          _markers[_markerId] = marker;
        });
      }
    }

    if (latLngList.length > 4) {
      _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
          boundsFromLatLngList(latLngList), 100.0));
    }
  }

  _openDrawer(context) {
    scaffoldKey.currentState.openDrawer();
  }

  _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }
}
