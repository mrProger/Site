library my_server;

import 'dart:io';
import 'dart:ffi';
import 'package:rpc/rpc.dart';
import '../lib/api.dart';

final ApiServer apiServer = new ApiServer(prettyPrint: true);

main() async {
  DynamicLibrary.open(r'../lib/sqlite3.dll');
  apiServer.addApi(new RitmApi());
  HttpServer server = await HttpServer.bind('127.0.0.1', 8080);
  server.listen(apiServer.httpRequestHandler);
  print('Server listening on http://${server.address.host}:${server.port}');
}