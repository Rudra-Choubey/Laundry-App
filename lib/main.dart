import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_project/wardrobe.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


late Box box;
void main() async{
  await Hive.initFlutter();
  box = await Hive.openBox('wardrobe');
  // box.clear();
  Hive.registerAdapter(ClothAdapter());
  runApp(LaundryApp());
}
class CustomTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  const CustomTextBox({
    required this.controller,
    required this.name,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Full white background
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 8.0,       // Blur radius
              offset: Offset(0, 4),  // Shadow offset
            ),
          ],
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: TextField(
          controller: this.controller,
          decoration: InputDecoration(

              labelText: name,

              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8)
          ),

        ),
      ),
    );
  }
}
class LoginPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hostelController = TextEditingController();

  void _showHostelSelection(BuildContext context) {
    final List<String> hostels = [
      'Aibaan', 'Beauki', 'Chimair', 'Duven', 'Emiet',
      'Firpeal', 'Griwiksh', 'Hiqom', 'Ijokha', 'Jurqia',
      'Kyzeel', 'Lekhaag'
    ]; // Hostel names

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns in the grid
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: hostels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  hostelController.text = hostels[index];
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Gray background color for boxes
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      hostels[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _login(BuildContext context) {
    String name = nameController.text;
    String hostel = hostelController.text;

    if (name.isNotEmpty && hostel.isNotEmpty) {
      // Simulating box for demonstration
      box.put('isLoggedIn', true);
      box.put('name', name);
      box.put('hostel', hostel);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace with your HomePage widget
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextBox(controller: nameController, name: 'Name',),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showHostelSelection(context),
              child: AbsorbPointer(
                child: CustomTextBox(controller: hostelController, name: 'Hostel')
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background.png'),
                    fit: BoxFit.cover
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LaundryApp extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext){
    final isLoggedIn = box.get('isLoggedIn', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Sets back button color
        ),
      ),
    );
  }
}

class ClothesDropdownWidget extends StatefulWidget {
  final String title;
  final List<String> clothes;
  final Function(int index) onDelete; // Callback for deletion

  const ClothesDropdownWidget({
    required this.title,
    required this.clothes,
    required this.onDelete, // Pass callback to delete
    Key? key,
  }) : super(key: key);

  @override
  _ClothesDropdownWidgetState createState() => _ClothesDropdownWidgetState();
}

class _ClothesDropdownWidgetState extends State<ClothesDropdownWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.title} (${widget.clothes.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.clothes.length,
                itemBuilder: (context, index) {
                  final imagePath = widget.clothes[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            widget.onDelete(index); // Call the delete callback
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class BagPage extends StatefulWidget {
  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  late List<Map<String, String>> bagItems;

  @override
  void initState() {
    super.initState();
    bagItems = List<Map<String, String>>.from(
      box.get('bag', defaultValue: []).map((item) => Map<String, String>.from(item)),
    );
  }

  void _removeClothingItem(int index) {
    setState(() {
      // Remove the item from bagItems
      bagItems.removeAt(index);
    });

    // Update the box with the new list after removal
    box.put('bag', bagItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: "Bag"),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['bag']),
        builder: (context, Box box, _) {
          // Rebuild bagItems when box changes
          bagItems = List<Map<String, String>>.from(
            box.get('bag', defaultValue: []).map((item) => Map<String, String>.from(item)),
          );

          // Group items by 'type'
          Map<String, List<String>> groupedItems = {};
          for (var item in bagItems) {
            final type = item['type'] ?? '';
            final path = item['path'] ?? '';
            if (groupedItems.containsKey(type)) {
              groupedItems[type]?.add(path);
            } else {
              groupedItems[type] = [path];
            }
          }

          return groupedItems.isEmpty
              ? Center(child: Text('No items'))
              : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              final type = groupedItems.keys.elementAt(index);
              final clothes = groupedItems[type] ?? [];
              return ClothesDropdownWidget(
                title: type,
                clothes: clothes,
                onDelete: (itemIndex) {
                  _removeClothingItem(itemIndex);
                },
              );
            },
          );
        },
      ),
    );
  }
}



class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _logout(BuildContext context) {
    box.put('isLoggedIn', false);
    box.delete('name');
    box.delete('hostel');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = box.get('name', defaultValue: 'Guest');
    final hostel = box.get('hostel', defaultValue: 'Unknown');

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xff081A20),
        title: const Text(
          'IITGN Laundry App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        elevation: 8.0, // Adds a shadow to the AppBar
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildOverlayDrawer(context, name, hostel),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                'Welcome, $name',
                style: const TextStyle(fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            'Hostel: $hostel',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          CustomCard(
            icon: Icons.shopping_bag,
            name: 'Bag',
            imagePath: 'assets/bag.png',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BagPage()),
            ),
          ),
          CustomCard(
            icon: MdiIcons.hanger,
            name: 'Wardrobe',
            imagePath: 'assets/wardrobe.png',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Wardrobe())),
          ),
          CustomCard(
            icon: Icons.lock_clock,
            name: 'Bag Status',
            imagePath: 'assets/bag_status.png',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BagStatusPage()),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildOverlayDrawer(BuildContext context, String name, String hostel) {
    return Drawer(
      child: Container(
        color: Colors.black.withOpacity(0.8), // Translucent black background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[700],
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: $name',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hostel: $hostel',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red logout button
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _logout(context),
              child: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class BagStatusPage extends StatefulWidget {
  @override
  _BagStatusPageState createState() => _BagStatusPageState();
}

class _BagStatusPageState extends State<BagStatusPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeBagStatus();
  }

  // Initialize the notification plugin
  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('app_icon'); // Ensure you have an app_icon in your drawable folder
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    _notificationsPlugin.initialize(initializationSettings);
  }

  // Display notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'bag_status_channel',
      'Bag Status Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Hostel-specific schedules
  final Map<String, List<int>> _hostelSchedules = {
    'Aibaan': [DateTime.wednesday, DateTime.saturday],
    'Beauki': [DateTime.monday, DateTime.thursday],
    'Duven': [DateTime.monday, DateTime.thursday],
    'Emiet': [DateTime.tuesday, DateTime.friday],
    'Firpeal': [DateTime.monday, DateTime.thursday],
    'Griwiksh': [DateTime.monday, DateTime.thursday],
    'Hiqom': [DateTime.tuesday, DateTime.friday],
    'Ijokha': [DateTime.wednesday, DateTime.saturday],
    'Jurqia': [DateTime.wednesday, DateTime.saturday],
  };

  // Initialize bag status
  void _initializeBagStatus() {
    final isBagWithYou = box.get('isBagWithYou', defaultValue: false);
    final hostel = box.get('hostel', defaultValue: 'Jurqia');
    final schedule = _hostelSchedules[hostel] ?? [DateTime.monday, DateTime.friday];

    final today = DateTime.now().weekday;

    // Check for collection or submission day
    if (today == schedule[0] && !isBagWithYou) {
      _showNotification('Collection Day', 'Your bag is ready for collection today!');
    } else if (today == schedule[1] && isBagWithYou) {
      _showNotification('Submission Day', 'Remember to submit your bag today!');
    }

    // Auto-collect bag if today is collection day and bag is not collected
    if (today == schedule[0] && !isBagWithYou) {
      box.put('isBagWithYou', true);
      box.put('lastCollectionDay', DateTime.now());
    }

    setState(() {});
  }

  int _daysUntilNext(int targetWeekday) {
    final now = DateTime.now();
    final today = now.weekday;
    int daysToAdd = (targetWeekday - today) % 7;
    if (daysToAdd <= 0) daysToAdd += 7; // Ensure it's always a future day
    return daysToAdd;
  }

  void _toggleBagStatus() {
    final isBagWithYou = box.get('isBagWithYou', defaultValue: false);
    final now = DateTime.now();
    box.put('isBagWithYou', !isBagWithYou);
    if (!isBagWithYou) {
      // If bag is collected, record the collection day
      box.put('lastCollectionDay', now);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isBagWithYou = box.get('isBagWithYou', defaultValue: false);
    final hostel = box.get('hostel', defaultValue: 'Jurqia');
    final schedule = _hostelSchedules[hostel] ?? [DateTime.monday, DateTime.friday];

    int daysUntilNextEvent;
    String displayMessage;

    if (isBagWithYou) {
      // Bag is with the user, countdown to submission day
      daysUntilNextEvent = _daysUntilNext(schedule[1]);
      displayMessage = 'Bag to be submitted in';
    } else {
      // Bag is out, countdown to collection day
      daysUntilNextEvent = _daysUntilNext(schedule[0]);
      displayMessage = 'Bag due for collection in';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff081A20),
        title: const Text(
          'Bag Status',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Top Banner with Dynamic Content
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      isBagWithYou
                          ? 'assets/bag_with_you.png'
                          : 'assets/bag_out.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Cards Section
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(16),
              children: [
                // Days Until Event
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          '$daysUntilNextEvent',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'days',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                // Collect/Submit Bag Button
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: _toggleBagStatus,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              isBagWithYou ? 'Submit Bag' : 'Collect Bag',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MainAppBar extends StatelessWidget implements PreferredSize {
  final String title;
  const MainAppBar({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: null,
      title: Text(this.title, style: TextStyle(color: Colors.white)),

      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Color(0xff081A20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  // TODO: implement child
  Widget get child => throw UnimplementedError();

}
class RoundedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box box, _) {
            return FutureBuilder<int>(
              future: _getTotalClothCount(),
              builder: (context, snapshot) {
                String displayText = "Welcome to the wardrobe:\n <number> clothes";
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  displayText = "Welcome to the wardrobe:\n ${snapshot.data} clothes";
                } else if (snapshot.hasError) {
                  displayText = "Error loading clothes count";
                }
                return Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<int> _getTotalClothCount() async {
    int total = 0;
    List<String> clothTypes = [
      'TShirt',
      'LowersAndShorts',
      'Sweaters',
      'Coats',
      'DrapedApparel',
      'Saris',
      'JeansAndTrousers',
      'Kurtas',
      'Shirts',
      'Linens',
      'Tops',
      'DressesAndGowns',
    ];

    for (String cloth in clothTypes) {
      List<String> clothImages = List<String>.from(
        box.get('${cloth}_images', defaultValue: []),

      );
      print(box.keys);
      total += clothImages.length;
    }
    return total;
  }
}


class AddClothesPage extends StatefulWidget {
  final String cloth;

  const AddClothesPage({required this.cloth, super.key});

  @override
  State<AddClothesPage> createState() => _AddClothesPageState();
}

class _AddClothesPageState extends State<AddClothesPage> {
  late List<String> clothImages; // List to store image paths

  @override
  void initState() {
    super.initState();
    // Initialize the image list from Hive
    clothImages = List<String>.from(box.get('${widget.cloth}_images', defaultValue: []));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        clothImages.add(pickedFile.path); // Add image path to the list
        box.put('${widget.cloth}_images', clothImages); // Save the list in Hive
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: widget.cloth),
      body: Column(
        children: [
          SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, size: 40, color: Colors.black54),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(keys: ['${widget.cloth}_images', 'bag']),
              builder: (context, Box box, _) {
                clothImages = List<String>.from(box.get('${widget.cloth}_images', defaultValue: []));
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: clothImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = clothImages[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                clothImages.removeAt(index); // Remove image
                                box.put('${widget.cloth}_images', clothImages); // Update Hive
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              // Adding item to the bag with type
                              setState(() {
                                List<Map<String, String>> bagItems = List<Map<String, String>>.from(
                                    box.get('bag', defaultValue: []).map((item) => Map<String, String>.from(item)));
                                bagItems.add({'type': widget.cloth, 'path': imagePath});
                                box.put('bag', bagItems);
                              });

                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

Future<int> getClothCount(String clothType) async {
  // Get the list of images for the specified clothing type from the Hive box
  List<String> clothImages = List<String>.from(box.get('${clothType.replaceAll(RegExp(r'\s+'), '')}_images', defaultValue: []));

  // Return the length of the list (number of items)
  return clothImages.length;
}
class ImageContainer extends StatelessWidget {
  final String imagePath;
  final String ClothName;
  final Color fontColor;
  const ImageContainer({Key? key, required this.imagePath, required this.ClothName, required this.fontColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _getImageSize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          Size imageSize = snapshot.data!;

          // Using FutureBuilder for cloth count
          return FutureBuilder<int>(
            future: getClothCount(ClothName),  // Get cloth count asynchronously
            builder: (context, countSnapshot) {
              String displayText = ClothName;  // Default display text
              if (countSnapshot.connectionState == ConnectionState.done) {
                if (countSnapshot.hasData) {
                  displayText = '${countSnapshot.data} $ClothName';  // Cloth count
                } else if (countSnapshot.hasError) {
                  displayText = 'Error loading cloth count';
                }
              }

              return Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddClothesPage(cloth: ClothName.replaceAll(RegExp(r'\s+'), ''))))
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: imageSize.width,
                        height: imageSize.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8), // Optional rounded corners
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 20,
                            color: fontColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading image size'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Size> _getImageSize() async {
    final Completer<Size> completer = Completer();
    final Image image = Image.asset(imagePath);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final Size size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        completer.complete(size);
      }),
    );
    return completer.future;
  }
}
class Wardrobe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: "Wardrobe"),
      body: ListView(
        children: [
          RoundedHeader(),
          Center(  // Center the Row containing the columns
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Center the columns within the Row
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // Center the items inside the column
                  children: [
                    ImageContainer(imagePath: 'assets/Wardrobe/TShirt.png', ClothName: 'TShirt', fontColor: Color(0xff5D4A07)),
                    ImageContainer(imagePath: 'assets/Wardrobe/LowersShorts.png', ClothName: 'Lowers And\n Shorts', fontColor: Color(0xff564338)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Sweaters.png', ClothName: 'Sweaters', fontColor: Color(0xffCAA7DA)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Coats.png', ClothName: 'Coats', fontColor: Color(0xffFFFFFF)),
                    ImageContainer(imagePath: 'assets/Wardrobe/DrapedApparel.png', ClothName: 'Draped\nApparel', fontColor: Color(0xff32094D)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Saris.png', ClothName: 'Saris', fontColor: Color(0xffFFFFFF)),
                  ],
                ),
                SizedBox(width: 5),  // Add spacing between the two columns
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // Center the items inside the column
                  children: [
                    ImageContainer(imagePath: 'assets/Wardrobe/JeansTrousers.png', ClothName: 'Jeans And\n Trousers', fontColor: Color(0xffF7F8FC)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Kurtas.png', ClothName: 'Kurtas', fontColor: Color(0xffFFCBCB)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Shirts.png', ClothName: 'Shirts', fontColor: Color(0xffABBD8E)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Linens.png', ClothName: 'Linens', fontColor: Color(0xff000000)),
                    ImageContainer(imagePath: 'assets/Wardrobe/Tops.png', ClothName: 'Tops', fontColor: Color(0xffC9865C)),
                    ImageContainer(imagePath: 'assets/Wardrobe/DressesGowns.png', ClothName: 'Dresses And\nGowns', fontColor: Color(0xffF9AB7B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String imagePath;
  final VoidCallback? onTap;

  const CustomCard({
    required this.icon,
    required this.name,
    required this.imagePath,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(top: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 322,
                height: 167,
                fit: BoxFit.cover,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}