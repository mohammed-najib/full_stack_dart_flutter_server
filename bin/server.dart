import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/ws', webSocketHandler(_handler));

Response _rootHandler(Request req) {
  return Response.ok('Hello, Boring Show!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void _handler(WebSocketChannel webSocket) {
  webSocket.stream.listen((data) {
    // webSocket.sink.add("echo $message");
    // webSocket.sink.close();
    final message = jsonDecode(data);
    print('message is: $message');
    print(message['previous_val']);

    final previousValue = message['previous_val'];

    if (message['increment'] == true) {
      final int newValue = previousValue + 1;

      webSocket.sink.add(json.encode({
        'value': newValue,
      }));
    }
    // else if (message['increment'] == false) {
    //   final int newValue = previousValue - 1;

    //   webSocket.sink.add({
    //     'value': newValue,
    //   });
    // }
  });
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline() //
      .addMiddleware(logRequests())
      .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
