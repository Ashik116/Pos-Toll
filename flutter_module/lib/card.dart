import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as https;
import 'package:image/image.dart' as images;
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'device_show.dart';
import 'login_page.dart';
import 'messages.g.dart';

class CardDesign extends StatefulWidget {
  const CardDesign({Key? key}) : super(key: key);

  @override
  State<CardDesign> createState() => _CardDesignState();
}

class _CardDesignState extends State<CardDesign> {
  final audioCache = AudioCache();
  bool audioPlayed = false;

  //RFID WORK
  final ExampleHostApi _hostApi = ExampleHostApi();
  String _hostCallResult = '';

  // String _hostCallResult1 = '42525441FF02143A25190001';

  // #docregion main-dart
  final ExampleHostApi _api = ExampleHostApi();

  /// Calls host method `add` with provided arguments.
  Future<int> add(int a, int b) async {
    try {
      return await _api.add(a, b);
    } catch (e) {
      // handle error.
      return 0;
    }
  }

  /// Sends message through host api using `MessageData` class
  /// and api `sendMessage` method.
  Future<bool> sendMessage(String messageText) {
    final MessageData message = MessageData(
      code: Code.one,
      data: <String?, String?>{'header': 'this is a header'},
      description: 'uri text',
    );
    try {
      return _api.sendMessage(message);
    } catch (e) {
      // handle error.
      return Future<bool>(() => true);
    }
  }
  // #enddocregion main-dart

  var bank_Name='';
  var mobile='';
  var licence_no='';
  var vehicle_no='';


  // void resetCodeAndMsg() {
  //   setState(() {
  //     mobile = '-';
  //     bank_Name = '-';
  //     avc = '-';
  //     ammount=0;
  //     vehicle_no='-';
  //   });
  //   Navigator.of(context).pop();
  // }

  Future<void> payment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    headers_cookie = sharedPreferences.getString("headers");
    response = await https
        .post(Uri.parse("http://103.101.197.249:8080/api/payment"), headers: {
      "cookie": headers_cookie.toString(),
    }, body: {
      "vehicle_number": vehicle_no.toString(),
      "vehicle_class": "Motor Cycle",
      "amount": "10",
      "toward": towards.toString(),
      "bridge_name": "Mayor Mohammad Hanif Flyover",
      "account_number": mobile.toString(),
      "bank_name": bank_Name.toString(),
      "lane_no": "1"
    });

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      setState(() {
        responseCode = jsonData['code'];
        responseMsg = jsonData['message'];

      });

      if (responseCode == 'PIS_200') {

        setState(() {
          paymentmethod="Online";
        });
        addVehicle();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('$responseMsg '), //Orion Tag
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
              content: Text('FOR-$licence_no\nDO you want to Print Ticket'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (responseCode == "PIF_400") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$responseMsg"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (responseCode == "VNF404") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$responseMsg"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (responseCode == "DVE4001") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$responseMsg"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (responseCode == "DRRF_400") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$responseMsg"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else if (responseCode == "DT_400") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$responseMsg"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      } else {}
    } else {
      //diloge show
    }
  }

  Future<void> searchVehicleTag() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var headers_cookie = sharedPreferences.getString("headers");

    try {
      https.Response responsee = await https.post(
        Uri.parse("http://103.101.197.249:8080/api/search-tag"),
        headers: {"cookie": headers_cookie.toString()},
        body: {"tag": _hostCallResult.toString()},
      );

      if (responsee.statusCode == 200) {
        var jsonData = json.decode(responsee.body);

        setState(() {
          bank_Name = jsonData['data']['bank_name'];
          mobile = jsonData['data']['ac'];
          licence_no = jsonData['data']['licence_no'];
          vehicle_no = licence_no;
        });
        payment();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Sorry !'), //Orion Tag
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
              content: Text('Unregister Vehicle Not Found'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
        // Handle non-200 status code
        setState(() {
          bank_Name = '-';
          mobile = '-';
        });

        print("Error: ${responsee.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("Error: $error");
    }
  }

  Future<void> searchVehicleNumber() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var headers_cookie = sharedPreferences.getString("headers");

    try {
      https.Response responsee = await https.post(
        Uri.parse("http://103.101.197.249:8080/api/search-vehicle"),
        headers: {"cookie": headers_cookie.toString()},
        body: {"vehicle_no": newdata.toString()},
      );

      if (responsee.statusCode == 200) {
        var jsonData = json.decode(responsee.body);
        print(jsonData);

        setState(() {
          bank_Name = jsonData['data']['bank_name'];
          mobile = jsonData['data']['ac'];
          licence_no = jsonData['data']['licence_no'];
          vehicle_no=licence_no;
        });
        payment();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Sorry !'), //Orion Tag
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
              content: Text('Unregister Vehicle Not Found'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    printTicket();
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
        // Handle non-200 status code
        setState(() {
          bank_Name = '-';
          mobile = '-';
        });

        print("Error: ${responsee.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("Error: $error");
    }
  }

  List<String> hexPairs = [];
  void convertHexToPairs() {
    hexPairs.clear(); // Clear the existing pairs

    for (int i = 0; i < _hostCallResult.length; i += 2) {
      hexPairs.add(_hostCallResult.substring(i, i + 2));
    }

    // Check the first two characters of _hostCallResult to determine the tag type

    if (_hostCallResult.startsWith('16')) {
      //searchAPI WORK
      searchVehicleTag();
    } else if (_hostCallResult.startsWith('42')) {
      searchVehicleNumber();
    } else {}
  }

  void _updateHostLanguage() {
    _hostApi.getHostLanguage().then(
      (String response) {
        setState(() {
          if (_hostCallResult != response) {
            audioCache.play('msg.mp3');
            setState(() {
              avc = "MOTORCYCLE";
              ammount = 10;
              randomNumber = Random().nextInt(max - min) + min;
              bankname = bank_Name;
            });

            _hostCallResult = '$response';

            convertHexToPairs();
            decrypt();
          }
        });
      },
    ).onError<PlatformException>(
      (PlatformException error, StackTrace _) {
        setState(() {
          _hostCallResult = 'Failed to get host language: ${error.message}';
        });
      },
    );
    // Future.delayed(Duration(seconds: 5), () => setState(() {
    //     _hostCallResult = null; // or set it to another default value as needed
    //   }));
  }

  //RFID WORK

  //convert hex to decimal

  String newdata = "";

  String district = '';
  String classCC = '';
  String de = '';

  String checkDistrict(String hexPairs) {
    // String index6 = hexPairs[5];

    switch (hexPairs) {
      case "02":
        return "Dhaka-Metro";
      case "11":
        return "Bagura";
      case "08":
        return "Chattra-Mwtro";
      case "19":
        return "Gazipur";
      case "14":
        return "Jassore";
      case "18":
        return "Narsingdi";
      case "34":
        return "Barguna";
      case "24":
        return "Gopalganj";
      case "43":
        return "Khulna-Metro";
      case "50":
        return "Barisal-Metro";
      case "16":
        return "Kushtia";
      case "2B":
        return "Feni";
      case "36":
        return "Jhenaidah";
      case "44":
        return "Raj-Metro";
      case "04":
        return "Jamalpur";
      case "25":
        return "Rajbari";
      case "1A":
        return "Manikganj";
      case "23":
        return "Shariatpur";
      case "01":
        return "Dhaka";
      case "30":
        return "Satkhira";
      case "06":
        return "Faridpur";
      case "26":
        return "Chuadanga";
      case "1B":
        return "Munshiganj";
      case "15":
        return "Barisal";
      case "37":
        return "Narail";
      case "64":
        return "Rangpur-Metro";
      case "12":
        return "Rangpur";
      case "2F":
        return "Bagerhat";
      case "17":
        return "Patuakhali";
      case "1C":
        return "Narayanganj";
      case "0C":
        return "Comilla";
      case "03":
        return "Tangail";
      case "0B":
        return "Noakhali";
      case "3E":
        return "Thakurgaon";
      case "05":
        return "Mymensing";
      case "22":
        return "Madaripur";
      case "13":
        return "Khulna";
      case "0E":
        return "Rajshahi";
      case "0F":
        return "Pabna";
      case "35":
        return "Magura";
      case "39":
        return "Natore";
      case "27":
        return "Meherpur";
      case "10":
        return "Dinajpur";
      case "3C":
        return "Sirajganj";
      case "2C":
        return "Habiganj";
      case "20":
        return "Kishoreganj";
      case "28":
        return "Brahmanbaria";
      case "40":
        return "Gaibandha";
      default:
        return "";
    }
  }

  String checvehicle_CC(String hexPairs) {
    switch (hexPairs) {
      case "11":
        return "KA";
      case "10":
        return "KHA";
      case "0F":
        return "GA";
      case "1A":
        return "GHA";
      case "19":
        return "CH";
      case "0E":
        return "TH";
      case "14":
        return "HA";
      case "0C":
        return "DA";
      case "05":
        return "MO";
      case "0A":
        return "NA";
      case "13":
        return "LA";
      case "08":
        return "U";
      case "0B":
        return "AU";
      case "1E":
        return "BA";
      case "09":
        return "TA";
      case "07":
        return "CHA";
      case "06":
        return "THA";
      case "1B":
        return "JHA";
      case "18":
        return "DHA";
      case "1D":
        return "ZO";
      case "1F":
        return "SHA";
      case "12":
        return "BHA";
      default:
        return "";
    }
  }

  String getDecimal(String hexPairs) {
    int dec = int.parse(hexPairs, radix: 16);

    de = dec.toString();

    print("Decimal:-$de");

    return de;
  }
  String getDecimalF(String i) {
    int dec = int.parse(i, radix: 16);
    String de = dec.toString();
    int lent = de.length;

    if (lent == 3) {
      return "0$de";
    } else if (lent == 2) {
      return "00$de";
    } else if (lent == 1) {
      return "000$de";
    }

    // Return original value if none of the conditions are met
    return de;
  }

  Future<void> decrypt() async {
    String l9l11 = hexPairs[8] + hexPairs[9];
    String t1 = checvehicle_CC(hexPairs[6]);
    String t2 = checkDistrict(hexPairs[5]);
    String t4 = getDecimal(hexPairs[7]);
    String t3 = getDecimalF(l9l11);
    String all = t2 + "-" + t1 + "-" + t4 + "" + t3;
    newdata = all;
    setState(() {
      vehicle_no = newdata;
    });
  }

  //hex to decimal

  @override
  void initState() {
    super.initState();
    audioCache.play('msg.mp3');
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateHostLanguage();
    });
  }

  bool connected = false;
  List cardList = [];
  List itemGridList = [];
  int min = 1;
  int max = 100000;
  int randomNumber = 0;

  String formateddate = DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now());
  String? vehiclenumber;
  var vehicleclass;
  var avc = "-";
  var ammount = 0;
  var lane = 0;
  var user;

  TextStyle textS() {
    return TextStyle(
      color: Color(0xFF000000),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      color: Color(0xFF000000),
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
  }

  var response;
  var jsonData;
  var pass;
  var headers_cookie;
  String paymentmethod = "";
  String bankname = "";
  String refareanceNumber = '';
  String towards = 'Dhaka';
  var responseCode;
  var responseMsg;

  Future addVehicle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user = sharedPreferences.getString('username');
    pass = sharedPreferences.getString('password');
    headers_cookie = sharedPreferences.getString("headers");


    response = await https
        .post(Uri.parse("http://103.101.197.249:8080/api/toll"), headers: {
      "cookie": headers_cookie.toString(),
    }, body: {
      "vehicle_no": vehicle_no.toString(),
      "amount": "10",
      "lane": "1",
      "user_name": user.toString(),
      "vehicle_class": "Motor Cycle",
      "payment_method": paymentmethod.toString(),
      "bank_name": bank_Name.toString(),
      "tag": _hostCallResult.toString(),
    });
    jsonData = json.decode(response.body);

  }

  Future<void> logout() async {
    return showDialog(
        context: (context),
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to LogOut?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }

  Widget items(text, image) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.13,
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.fill,
            ),
            gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade900])),
      ),
    );
  }

  Future<void> sendData() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      setState(() {
        connected = true;
        addVehicle();
      });
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/hanifFO.png');
    final Uint8List imgBytes = data.buffer.asUint8List();
    // final image = decodeImage(imgBytes)!;
    final images.Image image = images.decodeImage(imgBytes)!;
    images.Image resizeimage = images.copyResize(
      image,
      width: 350,
      height: 100,
    );
    bytes += generator.image(resizeimage);
    bytes += generator.text("--------------------------------");
    bytes += generator.row([
      PosColumn(
          text: 'Reg NO:',
          width: 2,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: '$vehicle_no',
          width: 10,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "AVC:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$avc",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Pass ID:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$randomNumber",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Toll Rate:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$ammount",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Lane No:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$lane",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "TC ID:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$user",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    // ticket.feed(2);
    bytes += generator.row([
      PosColumn(
          text: 'Date & Time:',
          width: 3,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "${formateddate}",
          width: 9,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    bytes += generator.text('Thank you! Have A Safe Journey..',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.text('O&M by Orion Infrastructure Limited.',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.cut();
    return bytes;
  }

  void randomnumbergenarator() {
    var random = Random();
    refareanceNumber = generateRandomNumber(22, random);
  }

  String generateRandomNumber(int length, Random random) {
    String firstDigit = (1 + random.nextInt(9)).toString();
    String remainingDigits =
        List.generate(length - 1, (index) => random.nextInt(50).toString())
            .join();
    return firstDigit + remainingDigits;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => DeviceList()));
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  logout();
                });
              },
              icon: Icon(Icons.logout_sharp)),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backg.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            height: size.height * 0.1,
                            width: size.width * 0.1,
                            child: Image.asset(
                              "assets/orion.png",
                            )),
                        Text(
                          "Orion Infrastructure Limited", // Regnum ETC Tolling
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      width: double.infinity,
                      color: Colors.white70,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Select Vehicle Class',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                InkWell(
                                  child: items(
                                    'Mototrcycle',
                                    'assets/motor_cycle2.png',
                                  ),
                                  onTap: () {
                                    setState(() {
                                      paymentmethod='Cash';
                                      lane = 1;
                                      ammount = 10;
                                      vehicleclass = 'Motor Cycle';
                                      avc = "MOTORCYCLE";
                                      vehiclenumber;
                                      randomNumber =
                                          Random().nextInt(max - min) + min;
                                    });
                                    // connected? this.addVehicle:null;
                                    sendData();
                                    printTicket();
                                    // printGraphics();
                                  },
                                ),
                                Text(
                                  "MotorCycle",
                                  style: textS(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                InkWell(
                                  child: items(
                                    '3/4 Wheeler',
                                    'assets/three_four_wheeler.png',
                                  ),
                                  onTap: () {
                                    searchVehicleTag();
                                  },
                                ),
                                Text(
                                  "3/4 Wheeler",
                                  style: textS(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Vehicle No",
                        ),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$vehicle_no",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       "RFID Tag",
                    //     ),
                    //     Container(
                    //       margin: const EdgeInsets.all(5.0),
                    //       padding: const EdgeInsets.all(2.0),
                    //       decoration: BoxDecoration(
                    //           border: Border.all(color: Colors.blueAccent)),
                    //       height: size.height * 0.05,
                    //       width: size.width * 0.6,
                    //       child: Center(
                    //           child: Text(
                    //         "$_hostCallResult",
                    //         style: TextStyle(
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       )),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "AVC Class",
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                            child: Text(
                              '$avc',
                              style: textStyle(),
                            ),
                            //for regnum
                            // child: Builder(
                            //   builder: (context) {
                            //     var avc = vehicleclass;
                            //     if (avc == "three_four_wheeler") {
                            //       return Text("3/4 WHEELER",
                            //           style: textStyle());
                            //     } else if (avc == "rickshaw_van") {
                            //       return Text(
                            //         "RICKSHAW",
                            //         style: textStyle(),
                            //       );
                            //     } else if (avc == 'motor_cycle') {
                            //       return Text(
                            //         "MOTORCYCLE",
                            //         style: textStyle(),
                            //       );
                            //     } else {
                            //       return Text("avc");
                            //     }
                            //   },
                            // ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Toll Rate",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$ammount",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Ticket ID",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$randomNumber",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Bank Name",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$bank_Name",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Account Number",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$mobile",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
