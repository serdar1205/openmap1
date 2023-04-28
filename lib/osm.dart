import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class OSMap extends StatefulWidget {
  OSMap({Key? key}) : super(key: key);

  @override
  State<OSMap> createState() => _OSMapState();
}

class _OSMapState extends State<OSMap> {
  ///
  final _mapController = MapController(initMapWithUserPosition: true);
  var markerMap = <String, String>{};
  List<String> getPostions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mapController.listenerMapSingleTapping.addListener(() async {
        // when tap on map, we will add new marker
        var positon = _mapController.listenerMapSingleTapping.value;
        if (positon != null) {
          await _mapController.addMarker(positon,
              markerIcon: MarkerIcon(
                icon: Icon(
                  Icons.pin_drop,
                  color: Colors.blue,
                  size: 48,
                ),
              ));

          // add marker to map, for hold information of marker in case we want to use it
          var key = '${positon.latitude}_${positon.longitude}';
          markerMap[key] = markerMap.length.toString();
          getPostions.add(key);
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pin location'),
      ),
      body: OSMFlutter(
        controller: _mapController,
        mapIsLoading: Center(
          child: CircularProgressIndicator(),
        ),
        trackMyPosition: true,
        initZoom: 12,
        minZoomLevel: 4,
        maxZoomLevel: 14,
        stepZoom: 1.0,
        androidHotReloadSupport: true,
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.person_outline_outlined,
              color: Colors.black,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.black,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: RoadOption(roadColor: Colors.red),
        markerOption: MarkerOption(
          defaultMarker: MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle_outlined,
              color: Colors.black,
              size: 48,
            ),
          ),
        ),
        onMapIsReady: (isReady) async {
          if (isReady) {
            await Future.delayed(Duration(seconds: 1), () async {
              await _mapController.currentLocation();
            });
          }
        },
        onGeoPointClicked: (geoPoint) {
          var key = '${geoPoint.latitude}_${geoPoint.longitude}';

          // when user click to marker
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Positon ${markerMap[key]}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Text(key),
                          ],
                        )),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.clear)),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.pin_drop),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                print(getPostions.length.toString());
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: markerMap.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Positon ${index}',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.blue),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${getPostions[index]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Divider(
                                thickness: 1,
                              ),
                            ],
                          );
                        }),
                  ),
                );
              });
        },
      ),
    );
  }
}
