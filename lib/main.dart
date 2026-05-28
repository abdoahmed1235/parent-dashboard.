import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لوحة التحكم المباشرة',
      theme: ThemeData.dark(),
      home: const DirectDashboard(),
    );
  }
}

class DirectDashboard extends StatefulWidget {
  const DirectDashboard({super.key});

  @override
  State<DirectDashboard> createState() => _DirectDashboardState();
}

class _DirectDashboardState extends State<DirectDashboard> {
  // الـ IP الحقيقي اللي أنت بعته والبورت الافتراضي للتطبيق الآخر
  final String targetIP = "192.168.1.61";
  final String port = "8080"; 
  
  Map<String, dynamic> deviceData = {
    "photos": "0",
    "videos": "0",
    "audios": "0",
    "location": "غير معروف"
  };
  bool isLoading = false;

  // إرسال أمر مباشر للجهاز لسحب البيانات عبر الـ IP
  Future<void> fetchDeviceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://$targetIP:$port/get_data'));
      
      if (response.statusCode == 200) {
        setState(() {
          deviceData = json.decode(response.body);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم سحب البيانات بنجاح عبر الاتصال المباشر!')),
        );
      } else {
        showError('فشل الاتصال: رمز الاستجابة ${response.statusCode}');
      }
    } catch (e) {
      showError('لا يمكن الوصول للجهاز. تأكد أنه متصل بنفس الشبكة والبرنامج يعمل.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المراقبة المباشرة عبر IP'),
        actions: [
          Chip(
            label: Text(targetIP),
            backgroundColor: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.orange),
                title: const Text('الموقع الحالي'),
                subtitle: Text(deviceData['location']),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  buildStatCard('الصور', deviceData['photos'], Icons.photo),
                  buildStatCard('الفيديوهات', deviceData['videos'], Icons.movie),
                  buildStatCard('التسجيلات', deviceData['audios'], Icons.mic),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
              ),
              onPressed: isLoading ? null : fetchDeviceData,
              icon: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Icon(Icons.refresh),
              label: const Text('سحب البيانات الآن (اتصال مباشر)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String count, IconData icon) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: bold)),
          ],
        ),
      ),
    );
  }
}
