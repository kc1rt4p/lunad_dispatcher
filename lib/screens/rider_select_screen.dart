import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/screens/bloc/rider_bloc.dart';
import 'package:lunad_dispatcher/widgets/filled_text_field.dart';

class RiderSelectScreen extends StatefulWidget {
  final String requestId;

  const RiderSelectScreen({Key key, this.requestId}) : super(key: key);

  @override
  _RiderSelectScreenState createState() => _RiderSelectScreenState();
}

class _RiderSelectScreenState extends State<RiderSelectScreen> {
  TextEditingController searchTextController = TextEditingController();
  String _requestId;

  @override
  void initState() {
    _requestId = widget.requestId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'Rider Assignment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 6.0,
        ),
        height: screenHeight,
        width: double.infinity,
        child: BlocProvider<RiderBloc>(
          create: (context) => RiderBloc()
            ..add(SearchAvailableRiders(searchTextController.text.trim())),
          child: Column(
            children: [
              BlocBuilder<RiderBloc, RiderState>(
                builder: (context, state) {
                  return FilledTextField(
                    controller: searchTextController,
                    labelText: 'Search',
                    hintText: 'Enter rider name...',
                    maxLines: 1,
                    onEditingComplete: () => _onSearch(context),
                    textInputType: TextInputType.text,
                  );
                },
              ),
              SizedBox(height: 10.0),
              BlocListener<RiderBloc, RiderState>(
                listener: (context, state) {
                  if (state is RiderAssigned) {
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder<RiderBloc, RiderState>(
                  builder: (context, state) {
                    if (state is SearchedAvailableRiders) {
                      return buildSearchResult(context, state.riders);
                    }

                    if (state is EmptyAvailableRiders) {
                      return buildEmptyAvailableRiders();
                    }

                    return buildLoading();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onSearch(BuildContext context) {
    final String query = searchTextController.text.trim();
    BlocProvider.of<RiderBloc>(context).add(SearchAvailableRiders(query));
  }

  buildEmptyAvailableRiders() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'There are no available riders at the moment.',
            style: TextStyle(
              color: Colors.red.shade600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResult(BuildContext context, List<Rider> riders) {
    return Expanded(
      child: ListView(
        children: riders.isNotEmpty
            ? riders.map((rider) => buildRiderItem(context, rider)).toList()
            : [
                Center(
                  child: Text(
                    'No rider matched your search keyword',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              ],
      ),
    );
  }

  Card buildRiderItem(BuildContext context, Rider rider) {
    return Card(
      color: Colors.red.shade400,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rider.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    '${rider.firstName} ${rider.lastName}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    rider.phoneNum,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () => _onRiderTapped(context, rider),
            ),
          ],
        ),
      ),
    );
  }

  _onRiderTapped(BuildContext context, Rider rider) {
    BlocProvider.of<RiderBloc>(context).add(AssignRider(_requestId, rider));
  }
}
