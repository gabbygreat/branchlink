import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterBranchSdk.validateSDKIntegration();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  TextEditingController firstController = TextEditingController();
  TextEditingController secondController = TextEditingController();
  TextEditingController noneController = TextEditingController();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchEvent? eventStandart;
  BranchEvent? eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  void showSnackBar(
      {required BuildContext context,
      required String message,
      int duration = 1}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      controllerData.sink.add((data.toString()));
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        if (data['screen'] == 'first_screen') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FirstPage(text: data['text'])),
          );
        } else if (data['screen'] == 'second_screen') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FirstPage(text: data['text'])),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DefaultPage()),
          );
        }
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      controllerInitSession.add(
          'InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

  void generateLink(BranchUniversalObject buo, BranchLinkProperties lp) async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      Clipboard.setData(ClipboardData(text: response.result));
      controllerUrl.sink.add('${response.result}');
      // showSnackBar(
      //     context: context, message: 'Generated and copied', duration: 10);
    } else {
      controllerUrl.sink
          .add('Error : ${response.errorCode} - ${response.errorMessage}');
      showSnackBar(context: context, message: 'failed', duration: 10);
    }
  }

  void shareLink(BranchUniversalObject buo, BranchLinkProperties lp) async {
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(
          context: context, message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          context: context,
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void getLastAttributed() async {
    BranchResponse response =
        await FlutterBranchSdk.getLastAttributedTouchData();
    if (response.success) {
      showSnackBar(
          context: context, message: response.result.toString(), duration: 5);
    } else {
      showSnackBar(
          context: context,
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  // void initDeepLinkData() {
  //   metadata = BranchContentMetaData()
  //     ..addCustomMetadata('custom_string', 'abc')
  //     ..addCustomMetadata('custom_number', 12345)
  //     ..addCustomMetadata('custom_bool', true)
  //     ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
  //     ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
  //     //--optional Custom Metadata
  //     ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
  //     ..price = 50.99
  //     ..currencyType = BranchCurrencyType.BRL
  //     ..quantity = 50
  //     ..sku = 'sku'
  //     ..productName = 'productName'
  //     ..productBrand = 'productBrand'
  //     ..productCategory = BranchProductCategory.ELECTRONICS
  //     ..productVariant = 'productVariant'
  //     ..condition = BranchCondition.NEW
  //     ..rating = 100
  //     ..ratingAverage = 50
  //     ..ratingMax = 100
  //     ..ratingCount = 2
  //     ..setAddress(
  //         street: 'street',
  //         city: 'city',
  //         region: 'ES',
  //         country: 'Brazil',
  //         postalCode: '99999-987')
  //     ..setLocation(31.4521685, -114.7352207);

  //   buo = BranchUniversalObject(
  //       canonicalIdentifier: 'flutter/branch',
  //       //parameter canonicalUrl
  //       //If your content lives both on the web and in the app, make sure you set its canonical URL
  //       // (i.e. the URL of this piece of content on the web) when building any BUO.
  //       // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
  //       // even if the user goes to the app instead of your website! This will help your SEO efforts.
  //       canonicalUrl: 'https://flutter.dev',
  //       title: 'Flutter Branch Plugin',
  //       imageUrl:
  //           'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
  //       contentDescription: 'Flutter Branch Description',
  //       /*
  //       contentMetadata: BranchContentMetaData()
  //         ..addCustomMetadata('custom_string', 'abc')
  //         ..addCustomMetadata('custom_number', 12345)
  //         ..addCustomMetadata('custom_bool', true)
  //         ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
  //         ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
  //        */
  //       contentMetadata: metadata,
  //       keywords: ['Plugin', 'Branch', 'Flutter'],
  //       publiclyIndex: true,
  //       locallyIndex: true,
  //       expirationDateInMilliSec:
  //           DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch);

  //   lp = BranchLinkProperties(
  //       channel: 'facebook',
  //       feature: 'sharing',
  //       //parameter alias
  //       //Instead of our standard encoded short url, you can specify the vanity alias.
  //       // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
  //       // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
  //       //alias: 'https://branch.io' //define link url,
  //       stage: 'new share',
  //       campaign: 'xxxxx',
  //       tags: ['one', 'two', 'three'])
  //     ..addControlParam('\$uri_redirect_mode', '1')
  //     ..addControlParam('referring_user_id', 'asdf');

  //   eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
  //     //--optional Event data
  //     ..transactionID = '12344555'
  //     ..currency = BranchCurrencyType.BRL
  //     ..revenue = 1.5
  //     ..shipping = 10.2
  //     ..tax = 12.3
  //     ..coupon = 'test_coupon'
  //     ..affiliation = 'test_affiliation'
  //     ..eventDescription = 'Event_description'
  //     ..searchQuery = 'item 123'
  //     ..adType = BranchEventAdType.BANNER
  //     ..addCustomData(
  //         'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
  //     ..addCustomData(
  //         'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

  //   eventCustom = BranchEvent.customEvent('Custom_event')
  //     ..addCustomData(
  //         'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
  //     ..addCustomData(
  //         'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  // }

  @override
  void dispose() {
    super.dispose();
    controllerData.close();
    controllerUrl.close();
    controllerInitSession.close();
    streamSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();

    listenDynamicLinks();

    // initDeepLinkData();

    FlutterBranchSdk.setIdentity('branch_user_test');

    //requestATTTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deeplink App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FirstPage(text: 'Testing'),
                  )),
              child: const Text('Go to first page'),
            ),
            RaisedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SecondPage(text: 'Testing')),
              ),
              child: const Text('Go to second page'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'First page data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: firstController,
                              decoration: InputDecoration(
                                hintText: 'Enter a word you want',
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          RaisedButton(
                            onPressed: () {
                              final lp = BranchLinkProperties(
                                  channel: 'facebook',
                                  feature: 'sharing',
                                  //parameter alias
                                  //Instead of our standard encoded short url, you can specify the vanity alias.
                                  // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
                                  // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
                                  //alias: 'https://branch.io' //define link url,
                                  stage: 'new share',
                                  campaign: 'xxxxx',
                                  tags: ['one', 'two', 'three'])
                                ..addControlParam('\$uri_redirect_mode', '1')
                                ..addControlParam('referring_user_id', 'asdf');
                              return generateLink(
                                  BranchUniversalObject(
                                      canonicalIdentifier: 'flutter/branch',
                                      canonicalUrl: 'https://flutter.dev',
                                      title: 'Flutter Branch Plugin',
                                      imageUrl:
                                          'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
                                      contentDescription:
                                          'Flutter Branch Description',
                                      contentMetadata: BranchContentMetaData()
                                        ..addCustomMetadata(
                                            'text',
                                            firstController.text.isNotEmpty
                                                ? firstController.text
                                                : 'nothing')
                                        ..addCustomMetadata(
                                            'screen', 'first_screen'),
                                      //add as many custm metadata !!
                                      keywords: ['Plugin', 'Branch', 'Flutter'],
                                      publiclyIndex: true,
                                      locallyIndex: true,
                                      expirationDateInMilliSec: DateTime.now()
                                          .add(Duration(days: 365))
                                          .millisecondsSinceEpoch),
                                  lp);
                            },
                            child: const Text('Generate link'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Second page data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: TextField(
                            controller: secondController,
                            decoration: const InputDecoration(
                              hintText: 'Enter a word you want',
                              focusedBorder: InputBorder.none,
                            ),
                          )),
                          const SizedBox(
                            width: 15,
                          ),
                          RaisedButton(
                            onPressed: () {
                              final lp = BranchLinkProperties(
                                  channel: 'facebook',
                                  feature: 'sharing',
                                  //parameter alias
                                  //Instead of our standard encoded short url, you can specify the vanity alias.
                                  // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
                                  // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
                                  //alias: 'https://branch.io' //define link url,
                                  stage: 'new share',
                                  campaign: 'xxxxx',
                                  tags: ['one', 'two', 'three'])
                                ..addControlParam('\$uri_redirect_mode', '1')
                                ..addControlParam('referring_user_id', 'asdf');
                              return generateLink(
                                  BranchUniversalObject(
                                      canonicalIdentifier: 'flutter/branch',
                                      canonicalUrl: 'https://flutter.dev',
                                      title: 'Flutter Branch Plugin',
                                      imageUrl:
                                          'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
                                      contentDescription:
                                          'Flutter Branch Description',
                                      contentMetadata: BranchContentMetaData()
                                        ..addCustomMetadata(
                                            'text',
                                            secondController.text.isNotEmpty
                                                ? secondController.text
                                                : 'nothing')
                                        ..addCustomMetadata(
                                            'screen', 'second_screen'),
                                      //add as many custm metadata !!
                                      keywords: ['Plugin', 'Branch', 'Flutter'],
                                      publiclyIndex: true,
                                      locallyIndex: true,
                                      expirationDateInMilliSec: DateTime.now()
                                          .add(const Duration(days: 365))
                                          .millisecondsSinceEpoch),
                                  lp);
                            },
                            child: const Text('Generate link'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No page data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: TextField(
                            controller: noneController,
                            decoration: const InputDecoration(
                              hintText: 'Enter a word you want',
                              focusedBorder: InputBorder.none,
                            ),
                          )),
                          const SizedBox(
                            width: 15,
                          ),
                          RaisedButton(
                            onPressed: () {
                              final lp = BranchLinkProperties(
                                  channel: 'facebook',
                                  feature: 'sharing',
                                  //parameter alias
                                  //Instead of our standard encoded short url, you can specify the vanity alias.
                                  // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
                                  // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
                                  //alias: 'https://branch.io' //define link url,
                                  stage: 'new share',
                                  campaign: 'xxxxx',
                                  tags: ['one', 'two', 'three'])
                                ..addControlParam('\$uri_redirect_mode', '1')
                                ..addControlParam('referring_user_id', 'asdf');
                              return generateLink(
                                  BranchUniversalObject(
                                      canonicalIdentifier: 'flutter/branch',
                                      canonicalUrl: 'https://flutter.dev',
                                      title: 'Flutter Branch Plugin',
                                      imageUrl:
                                          'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
                                      contentDescription:
                                          'Flutter Branch Description',
                                      contentMetadata: BranchContentMetaData()
                                        ..addCustomMetadata(
                                            'text',
                                            noneController.text.isNotEmpty
                                                ? noneController.text
                                                : 'nothing')
                                        ..addCustomMetadata('screen', 'none'),
                                      //add as many custm metadata !!
                                      keywords: ['Plugin', 'Branch', 'Flutter'],
                                      publiclyIndex: true,
                                      locallyIndex: true,
                                      expirationDateInMilliSec: DateTime.now()
                                          .add(const Duration(days: 365))
                                          .millisecondsSinceEpoch),
                                  lp);
                            },
                            child: const Text('Generate link'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  final String text;
  const FirstPage({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Page'),
      ),
      body: Center(
        child: Text(text),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final String text;
  const SecondPage({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: Text(text),
      ),
    );
  }
}

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('If page is not found')),
      body: const Center(
        child: Text('Nothing found'),
      ),
    );
  }
}
