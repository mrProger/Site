library test_api;

import 'dart:io';
import 'package:rpc/rpc.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

File file = File(r'..\lib\db.sqlite');
final db = sqlite3.open(file.path);

@ApiClass(name: 'ritmapi', version: 'v1', description: 'My RitmApi')
class RitmApi {
  RitmApi();

  @ApiMethod(path: 'database/create')
  DatabaseInit initDatabase() {
    try {
      if (!file.existsSync())
        file.createSync();
      db.execute('CREATE TABLE IF NOT EXISTS orders (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL, telephone TEXT NOT NULL, email TEXT NOT NULL, service TEXT NOT NULL, price INTEGER NOT NULL);');
    }
    catch (exception, message) {
      print('Ошибка: ${exception}\nИнформация: ${message}');
      return new DatabaseInit()..status = false;
    }

    return new DatabaseInit()..status = true;
  }
  @ApiMethod(path: 'order/getordercount', method: 'GET')
  CountOrder getOrderCount() {
    final ResultSet req = db.select('SELECT COUNT(*) FROM orders');
    int count = 0;

    for (final Row row in req)
      count = row['COUNT(*)'];

    return new CountOrder()..count = count;
  }

  @ApiMethod(path: 'order/getorder/id/{id}', method: 'GET')
  Order getOrder(int id) {
    final ResultSet req = db.select('SELECT * FROM orders WHERE id=?', [id]);
    Order order = Order();

    for (final Row row in req)
      order
        ..id = row['id']
        ..name = row['name']
        ..telephone = row['telephone']
        ..email = row['email']
        ..service = row['service']
        ..price = row['price'];

    return order;
  }

  @ApiMethod(path: 'order/createorder', method: 'POST')
  CreatedOrder createOrder(OrderCreateRequest orderCreateRequest) {
    final req = db.prepare("INSERT INTO orders (name, telephone, email, service, price) VALUES (?, ?, ?, ?, ?)")..execute([orderCreateRequest.name, orderCreateRequest.telephoneNumber, orderCreateRequest.emailAddress, orderCreateRequest.service, orderCreateRequest.price]);
    req.dispose();

    return new CreatedOrder()
        ..name = orderCreateRequest.name
        ..telephone = orderCreateRequest.telephoneNumber
        ..email = orderCreateRequest.emailAddress
        ..service = orderCreateRequest.service
        ..price = orderCreateRequest.price;
  }

  @ApiMethod(path: 'email/sendmessage', method: 'POST')
  EmailMessage sendEmailMessage(EmailMessageRequest emailMessageRequest) {
    bool sended = true;
    String username = "derghava7@gmail.com";
    String password = "Ilya2012";

    try {
      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Сервисный центр Ритм')
        ..recipients.add(emailMessageRequest.to)
        ..subject = emailMessageRequest.subject
        ..text = emailMessageRequest.text;

      var connection = PersistentConnection(smtpServer);
      connection.send(message);
      connection.close();
    }
    catch(exception, message) {
      print('Ошибка: ${exception}\nИнформация: ${message}');
      sended = false;
    }

    return new EmailMessage()
        ..sended = sended
        ..from = Address(username, r'Сервисный центр Ритм').toString()
        ..to = emailMessageRequest.to
        ..subject = emailMessageRequest.subject
        ..text = emailMessageRequest.text;
  }
}

class DatabaseInit {
  bool status;
}

class CountOrder {
  int count;
}

class EmailMessageRequest {
  @ApiProperty(required: true)
  String to;

  @ApiProperty(required: true)
  String subject;

  @ApiProperty(required: true)
  String text;
}

class OrderCreateRequest {
  @ApiProperty(required: true)
  String name;

  @ApiProperty(required: true)
  String telephoneNumber;

  @ApiProperty(required: true)
  String emailAddress;

  @ApiProperty(required: true)
  String service;

  @ApiProperty(required: true)
  String price;
}

class EmailMessage {
  bool sended;
  String from;
  String to;
  String subject;
  String text;
}

class CreatedOrder {
  String name;
  String telephone;
  String email;
  String service;
  String price;
}

class Order {
  int id;
  String name;
  String telephone;
  String email;
  String service;
  String price;
}