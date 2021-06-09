import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/screens/bloc/rider_bloc.dart';
import 'package:lunad_dispatcher/screens/rider_add_screen.dart';
import 'package:lunad_dispatcher/screens/rider_info_screen.dart';
import 'package:lunad_dispatcher/widgets/filled_text_field.dart';

class RidersScreen extends StatefulWidget {
  const RidersScreen({Key key}) : super(key: key);

  @override
  _RidersScreenState createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Riders'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _onAddTapped(context),
          ),
        ],
      ),
      body: BlocProvider<RiderBloc>(
        create: (context) =>
            RiderBloc()..add(SearchRiders(searchTextController.text)),
        child: Container(
          height: screenHeight,
          padding: EdgeInsets.all(8.0),
          width: double.infinity,
          child: Column(
            children: [
              BlocBuilder<RiderBloc, RiderState>(
                builder: (context, state) {
                  return FilledTextField(
                    controller: searchTextController,
                    labelText: 'Search Riders',
                    hintText: 'Enter rider name...',
                    textInputType: TextInputType.text,
                    maxLines: 1,
                    onEditingComplete: () => _onSearchTapped(context),
                  );
                },
              ),
              SizedBox(height: 12.0),
              Expanded(
                child: BlocListener<RiderBloc, RiderState>(
                  listener: (context, state) {},
                  child: BlocBuilder<RiderBloc, RiderState>(
                    builder: (context, state) {
                      if (state is SearchedRiders) {
                        return buildSearchedRiders(context, state.riders);
                      }

                      return buildLoading(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onAddTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderAddScreen(),
      ),
    );
  }

  _onSearchTapped(BuildContext context) {
    final query = searchTextController.text.trim();
    BlocProvider.of<RiderBloc>(context).add(SearchRiders(query));
  }

  buildSearchedRiders(BuildContext context, List<Rider> riders) {
    return ListView(
      children: riders.map<Widget>((rider) {
        return buildRiderItem(context, rider);
      }).toList(),
    );
  }

  buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.red.shade600,
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
              onPressed: () => _onRiderTapped(context, rider.id),
            ),
          ],
        ),
      ),
    );
  }

  _onRiderTapped(BuildContext context, String riderId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderInfoScreen(
          riderId: riderId,
        ),
      ),
    );
    BlocProvider.of<RiderBloc>(context).add(
      SearchRiders(searchTextController.text.trim()),
    );
  }
}
