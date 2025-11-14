import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/contacto_emergencia_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ContactoEmergenciaService', () {
    test(
      'getByUsuarioDni devuelve listado cuando la API responde 200',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/contacto_emergencia/usuario/12345678A');
          final payload = [
            {
              'id_cont': 1,
              'nombre': 'Laura',
              'apellidos': 'Rodríguez Pérez',
              'telefono': '600123456',
              'relacion': 'Hija',
              'dni_usuario_ref': '12345678A',
            },
          ];
          return http.Response(
            jsonEncode(payload),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final service = ContactoEmergenciaService(
          baseUrl: 'http://test',
          client: mockClient,
        );

        final contactos = await service.getByUsuarioDni('12345678A');

        expect(contactos, hasLength(1));
        expect(contactos.first.nombre, 'Laura');
        expect(contactos.first.dniUsuarioRef, '12345678A');
      },
    );

    test('getByUsuarioDni lanza excepción si la API falla', () async {
      final mockClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      final service = ContactoEmergenciaService(
        baseUrl: 'http://test',
        client: mockClient,
      );

      expect(() => service.getByUsuarioDni('ANY'), throwsA(isA<Exception>()));
    });
  });
}
