import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> dataList = [];
  Map<String, dynamic>? selectedData;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }Future<void> loadJsonData() async {
    final jsonString = await rootBundle.rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);

    setState(() {
      dataList = jsonResponse.map((data) => Map<String, dynamic>.from(data)).toList();
    });
  }

  void onNameSelected(Map<String, dynamic>? selected) {
    if (selected != null) {
      setState(() {
        selectedData = selected;
        nameController.text = selected['name'] ?? '';
        mobileNumberController.text = selected['mobileNumber'] ?? '';
        addressController.text = selected['address'] ?? '';
        gstNumberController.text = selected['gstNumber'] ?? '';
      });
    } else {
      // Handle null case, maybe clear the text fields or do nothing
      setState(() {
        nameController.clear();
        mobileNumberController.clear();
        addressController.clear();
        gstNumberController.clear();
      });
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final selected = await showSearch<Map<String, dynamic>>(
                      context: context,
                      delegate: DataSearch(dataList),
                    );
                    onNameSelected(selected); // Handle potential null
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: mobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: gstNumberController,
                  decoration: InputDecoration(labelText: 'GST Number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class DataSearch extends SearchDelegate<Map<String, dynamic>> {
  final List<Map<String, dynamic>> dataList;

  DataSearch(this.dataList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, dataList as Map<String, dynamic>); // This can return null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = dataList.where((element) =>
        element['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text(
            'Mobile: ${item['mobileNumber']}\nAddress: ${item['address']}\nGST: ${item['gstNumber']}',
          ),
          onTap: () {
            close(context, results[index]);  // Returns selected item
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = dataList.where((element) =>
        element['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text(
            'Mobile: ${item['mobileNumber']}\nAddress: ${item['address']}\nGST: ${item['gstNumber']}',
          ),
          onTap: () {
            query = suggestions[index]['name'];
            showResults(context);
          },
        );
      },
    );
  }
}