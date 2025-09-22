import 'package:flutter/material.dart';
import 'package:waiwan/components/bottom_appbar.dart';

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});
  final String title = 'หน้าแรก';

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  int _currentIndex = 0;
  String _currentTitle = 'หน้าแรก';

  static const List<Destination> destinations = <Destination>[
    Destination(
      icon: Icons.home_outlined,
      iconSelected: Icons.home,
      label: 'หน้าแรก',
    ),
    Destination(
      icon: Icons.message_outlined,
      iconSelected: Icons.message,
      label: 'ข้อความ',
    ),
    Destination(
      icon: Icons.notifications_outlined,
      iconSelected: Icons.notifications,
      label: 'แจ้งเตือน',
    ),
    Destination(
      icon: Icons.person_outlined,
      iconSelected: Icons.person,
      label: 'โปรไฟล์',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [


          // search bar 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SearchBar(
                    hintText: 'ค้นหา',
                    leading: const Icon(Icons.search , size: 30),
                    constraints: const BoxConstraints(
                      maxHeight: 60,
                      minHeight: 50,
                    ),
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 24.0),
                    ),
                    hintStyle: MaterialStatePropertyAll<TextStyle>(
                      TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    elevation: const MaterialStatePropertyAll<double>(1.0),
                  ),
                ),

                //ปุ่มคูปอง
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          elevation: 1,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/coupon.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'ดูปองของฉัน',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    //ปุ่มดูคะแนน
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green[100],
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          elevation: 1,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/p.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          '1000 คะแนน',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // หน้าข้อความ
          const Center(
            child: Text(''),
          ),
          // หน้าแจ้งเตือน
          const Center(
            child: Text(''),
          ),
          // หน้าโปรไฟล์
          const Center(
            child: Text(''),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        destinations: destinations
            .map<NavigationDestination>(
              (Destination destination) => NavigationDestination(
                icon: Icon(
                  destination.icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                selectedIcon: Icon(
                  destination.iconSelected,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: destination.label,
              ),
            )
            .toList(),
        selectedIndex: _currentIndex,
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
            _currentTitle = destinations[index].label;
          });
        },
      ),
    );
  }
}
