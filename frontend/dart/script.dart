import 'dart:html' as html;
import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'dart:convert';

List<String> picturesList = ['view/image/img-slider1.jpg', 'view/image/img-slider2.jpg', 'view/image/img-slider3.jpg', 'view/image/img-slider4.jpg'];
var imgList = html.querySelectorAll('.slider__img');
List<int> picturesIndex = [0, 1];
html.Storage localStorage = html.window.localStorage;
List<String> sassFilesList = ['style.sass', 'services-card.sass', 'paid-repair.sass', 'menu.sass',
    'img-slider.sass', 'header.sass', 'footer.sass', 'content.sass', 'contacts.sass', 'admin-panel.sass',
    'admin-form.sass'];

class Console {
    static void Log(dynamic data) {
        html.window.console.info(data);
    }

    static void Error(dynamic data) {
        html.window.console.error(data);
    }
}

void main() {
    js.context['slideToLeft'] = slideToLeft;
    js.context['slideToRight'] = slideToRight;
    js.context['adminAuth'] = adminAuth;
    js.context['setImageInSlider'] = setImageInSlider;
    js.context['goToAdminPanel'] = goToAdminPanel;
    js.context['checkAdminAuth'] = checkAdminAuth;
    js.context['leaveAdminPanel'] = leaveAdminPanel;
    js.context['createOrder'] = createOrder;
    js.context['isTelephoneNumber'] = isTelephoneNumber;
    js.context['isEmail'] = isEmail;
    js.context['createDatabase'] = createDatabase;
    js.context['viewOrders'] = viewOrders;
}

void slideToLeft() {
    for (int i = 0; i < picturesIndex.length; i++)
        picturesIndex[i] = picturesIndex[i] <= 0 ? 3 : picturesIndex[i] - 1;

    setImageInSlider();
}

void slideToRight() {
    for (int i = 0; i < picturesIndex.length; i++)
        picturesIndex[i] = picturesIndex[i] >= 3 ? 0 : picturesIndex[i] + 1;

    setImageInSlider();
}

void setImageInSlider() {
    for (int i = 0; i < imgList.length; i++)
        imgList[i].attributes['src'] = picturesList[picturesIndex[i]];
}

void adminAuth() {
    Map<String, html.InputElement> inputField = {'login-field': html.querySelector('#admin-login-input'), 'password-field': html.querySelector('#admin-password-input')};
    Map<String, String> inputData = {'login': inputField['login-field'].value, 'password': inputField['password-field'].value};

    if (!isNull(inputData['login']) && !isNull(inputData['password']))
        if (inputData['login'] == 'admin' && inputData['password'] == '123admin123')
            goToAdminPanel();
}

bool isNull(String text) {
    return text.toString().replaceAll(' ', '') == '' || text == null;
}

void goToAdminPanel() {
    localStorage['auth'] = 'true';
    html.window.location.href = 'admin.html';
}

void checkAdminAuth() async {
    if (localStorage['auth'] == null || localStorage['auth'] != 'true')
        html.window.location.href = 'admin-auth.html';
}

void createDatabase() async {
    var reqCreateDb = await http.get(Uri.parse('http://127.0.0.1:8080/ritmapi/v1/database/create'));
}

void leaveAdminPanel() {
    localStorage['auth'] = null;
    html.window.location.href = 'admin-auth.html';
}

Future<bool> isTelephoneNumber(String number) async {
    RegExp regExp = RegExp(r'(\+7[0-9]{10})');

    var groupCount = await number.replaceAllMapped(
        regExp, (match) => '${match.groupCount}');

    if (groupCount.toString() == '1')
        return true;

    return false;
}

Future<bool> isEmail(String address) async {
    RegExp regExp = RegExp(r'((?:[a-z0-9!#$%&*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&*+\/=?^_`{|}~-]+)*|(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*)@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\]))');

    var groupCount = await address.replaceAllMapped(regExp, (match) => '${match.groupCount}');

    if (groupCount.toString() == '5')
        return true;

    return false;
}

void createOrder() async {
    Map<String, dynamic> inputFields = {
        'service-input': html.querySelector('.service-type'),
        'name-input': html.querySelector('.name-input'),
        'telephone-input': html.querySelector('.telephone-number-input'),
        'email-input': html.querySelector('.email-input')
    };

    Map<String, String> inputData = {
        'service': inputFields['service-input'].value,
        'name': inputFields['name-input'].value,
        'telephone': inputFields['telephone-input'].value,
        'email': inputFields['email-input'].value
    };

    if (!isNull(inputData['service']) && !isNull(inputData['name'])
        && !isNull(inputData['telephone']) && !isNull(inputData['email'])) {
        if (!await isTelephoneNumber(inputData['telephone'])) {
            html.window.alert('Неправильно введен номер телефона');
            return;
        }

        if (!await isEmail(inputData['email'])) {
            html.window.alert('Неправильно введен адрес электронной почты');
            return;
        }

        var service = inputData['service'].split(' - ');

        var reqInsert = await http.post(Uri.parse('http://127.0.0.1:8080/ritmapi/v1/order/createorder'),
            body: {'name': inputData['name'], 'telephoneNumber': inputData['telephone'], 'emailAddress': inputData['email'],
            'service': service[0], 'price': service[1]});

        var reqSendEmail = await http.post(Uri.parse('http://127.0.0.1:8080/ritmapi/v1/email/sendmessage'),
        body: {'to': inputData['email'], 'subject': 'Статус заказа', 'text': 'Здравствуйте! Ваш заказ принят в работу!\nНаш мастер с вами свяжется\nСервисный центр Ритм\n\nНе отвечайте на это сообщение, оно отправлено системой'});

        html.window.alert('Вы успешно оформили заказ!');
    }
    else
        html.window.alert('Все поля должны быть заполнены');
}

viewOrders() async {
    try {
        http.Response reqGetCountOrder = await http.get(Uri.parse('http://127.0.0.1:8080/ritmapi/v1/order/getordercount'), headers: {'content-type': 'application/json'});
        http.Response reqGetOrders;
        dynamic orderDataList;
        int orderCount = jsonDecode(reqGetCountOrder.body)['count'];

        Map<String, html.DivElement> orderDivTags = {
            'row': html.DivElement(),
            'col': html.DivElement(),
            'order': html.DivElement()
        };

        Map<String, html.ParagraphElement> orderFields = {
            'name': html.ParagraphElement(),
            'telephone': html.ParagraphElement(),
            'email': html.ParagraphElement(),
            'service': html.ParagraphElement(),
            'price': html.ParagraphElement()
        };

        for (int i = 1; i < orderCount + 1; i++) {
            reqGetOrders = await http.get(Uri.parse('http://127.0.0.1:8080/ritmapi/v1/order/getorder/id/${i}'), headers: {'content-type': 'application/json'});
            orderDataList = jsonDecode(reqGetOrders.body);

            orderDivTags['row'] = html.DivElement()
                ..className = 'row py-3';
            orderDivTags['col'] = html.DivElement()
                ..className = 'col d-flex flex-column';
            orderDivTags['order'] = html.DivElement()
                ..className = 'align-self-center order';

            orderFields['name'] = html.ParagraphElement()
                ..text = 'Как можно обращаться: ${orderDataList['name']}'
                ..className = 'order__name';
            orderFields['telephone'] = html.ParagraphElement()
                ..text = 'Номер телефона: ${orderDataList['telephone']}'
                ..className = 'order__telephone';
            orderFields['email'] = html.ParagraphElement()
                ..text = 'Адрес эл.почты: ${orderDataList['email']}'
                ..className = 'order__email';
            orderFields['service'] = html.ParagraphElement()
                ..text = 'Услуга: ${orderDataList['service']}'
                ..className = 'order__service';
            orderFields['price'] = html.ParagraphElement()
                ..text = 'Стоимость: ${orderDataList['price']}'
                ..className = 'order__price';

            orderDivTags['order'].children.addAll([
                orderFields['name'],
                orderFields['telephone'],
                orderFields['email'],
                orderFields['service'],
                orderFields['price']
            ]);
            orderDivTags['col'].children.add(orderDivTags['order']);
            orderDivTags['row'].children.add(orderDivTags['col']);
            html.querySelector('.content__background').children.add(orderDivTags['row']);
        }

        orderDivTags['row'] = html.DivElement()..className = 'row py-3';
        html.querySelector('.content__background').children.add(orderDivTags['row']);
    }
    catch(exception, message) {
        Console.Error('Ошибка: ${exception}\nИнформация: ${message}');
        return false;
    }

    return true;
}