import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IncidentsMapPage extends StatefulWidget {
  const IncidentsMapPage({super.key});

  @override
  IncidentsMapPageState createState() => IncidentsMapPageState();
}

class IncidentsMapPageState extends State<IncidentsMapPage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    fetchIncidents();
  }

  final Set<Polygon> _trujilloPolygon = {
    Polygon(
      polygonId: const PolygonId('trujillo'),
      points: const [
        LatLng(-8.150677, -79.025044),
        LatLng(-8.149532, -79.023273),
        LatLng(-8.148547, -79.019770),
        LatLng(-8.145782, -79.016956),
        LatLng(-8.143253, -79.013326),
        LatLng(-8.141167, -79.008011),
        LatLng(-8.136253, -79.002627),
        LatLng(-8.132211, -78.999380),
        LatLng(-8.127284, -78.996467),
        LatLng(-8.127069, -78.989969),
        LatLng(-8.127529, -78.980012),
        LatLng(-8.112497, -78.994303),
        LatLng(-8.107110, -78.994971),
        LatLng(-8.103010, -79.001802),
        LatLng(-8.101168, -78.998055),
        LatLng(-8.096358, -78.995685),
        LatLng(-8.093481, -78.996246),
        LatLng(-8.092729, -78.994132),
        LatLng(-8.088847, -78.991692),
        LatLng(-8.088985, -78.995485),
        LatLng(-8.088341, -78.998193),
        LatLng(-8.087154, -79.002266),
        LatLng(-8.087475, -79.004688),
        LatLng(-8.085716, -79.015170),
        LatLng(-8.087451, -79.018207),
        LatLng(-8.088327, -79.021930),
        LatLng(-8.088537, -79.028435),
        LatLng(-8.086972, -79.034010),
        LatLng(-8.085879, -79.042170),
        LatLng(-8.083351, -79.049183),
        LatLng(-8.082787, -79.054937),
        LatLng(-8.090595, -79.057074),
        LatLng(-8.090631, -79.053857),
        LatLng(-8.104484, -79.060162),
        LatLng(-8.105967, -79.055024),
        LatLng(-8.118505, -79.058009),
        LatLng(-8.121774, -79.048866),
        LatLng(-8.116462, -79.044058),
        LatLng(-8.119290, -79.040736),
        LatLng(-8.119667, -79.040791),
        LatLng(-8.125749, -79.045828),
        LatLng(-8.128692, -79.042372),
        LatLng(-8.127529, -79.041347),
        LatLng(-8.128190, -79.040516),
        LatLng(-8.130016, -79.035548),
        LatLng(-8.132358, -79.032947),
        LatLng(-8.137220, -79.027442),
        LatLng(-8.148910, -79.026305),
        LatLng(-8.150722, -79.025550),
        LatLng(-8.143212, -79.013105),
      ],
      strokeWidth: 2,
      strokeColor: const Color.fromARGB(219, 232, 55, 55),
      fillColor: const Color.fromARGB(146, 33, 219, 243).withOpacity(0.1),
    ),
  };

  Future<BitmapDescriptor> iconIncident(String tipo) async {
    switch (tipo) {
      case 'Secuestro':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case 'Robo':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'Incendio':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'Asesinato':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> fetchIncidents() async {
    final response = await http.get(Uri.parse('http://localhost:3000/incidentes/'));

    if (response.statusCode == 200) {
      final List incidents = json.decode(response.body);
      final List<Marker> markersList = await Future.wait(incidents.map((incident) async {
        // Convertir latitud y longitud a double
        final double latitud = double.parse(incident['latitud'].toString());
        final double longitud = double.parse(incident['longitud'].toString());

        // Obtener el icono para el incidente
        final icon = await iconIncident(incident['tipo_incidente'].toString());

        return Marker(
          markerId: MarkerId(incident['id_incidente'].toString()),
          position: LatLng(latitud, longitud),
          infoWindow: InfoWindow(
            title: incident['descripcion'],
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return IncidentDetailSheet(incident: incident);
                },
              );
            },
          ),
          icon: icon,
        );
      }).toList());

      setState(() {
        markers = markersList.toSet();
      });
    } else {
      throw Exception('Error al cargar los incidentes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        myLocationEnabled: true,
        polygons: _trujilloPolygon,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-8.112, -79.03), // Coordenadas iniciales (Trujillo)
          zoom: 12.0,
        ),
        markers: markers,
      ),
    );
  }
}

class IncidentDetailSheet extends StatelessWidget {
  final Map incident;

  const IncidentDetailSheet({required this.incident, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Para que la hoja no ocupe toda la pantalla
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${incident['tipo_incidente']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 10),
          Text(
            'Descripción: ${incident['descripcion']}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text(
            'Fecha: ${incident['fecha']}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Hora: ${incident['hora']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text('Reportado por: ${incident['nombre_usuario']}'),
        ],
      ),
    );
  }
}
