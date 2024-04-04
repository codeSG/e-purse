import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';

class AnotherClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Credentials'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              MyForm(), // Include MyForm widget here
            ],
          ),
        ),
      ),
    );
  }
}
class FormData {
  final int id; // Change identifier to integer
  final String domain;
  final String email;
  final String password;
  final Map<String, dynamic> optionalFields;

  FormData({
    required this.id,
    required this.domain,
    required this.email,
    required this.password,
    required this.optionalFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'email': email,
      'password': password,
      'optionalFields': optionalFields,
    };
  }

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      id: json['id'],
      domain: json['domain'],
      email: json['email'],
      password: json['password'],
      optionalFields: json['optionalFields'] ?? {},
    );
  }
}
class DatabaseHelper {
  static const String databaseDomain = 'form_data1.db';
  final store = intMapStoreFactory.store('form_data_store');

  Future<Database> openDatabase() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDirectory.path, databaseDomain);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> saveFormData(FormData formData) async {
    final database = await openDatabase();

    // Find the maximum ID currently in use
    final finder = Finder(
      sortOrders: [SortOrder('id', false)], // Sorting in descending order
      limit: 1, // Retrieve only the first record (max ID)
    );

    final maxIdRecord = await store.find(database, finder: finder);
    print("*********************");
    //print(maxIdRecord.first['id']);
    print("###############");
    int? newId = 1; // Default ID for a new entry
    if (maxIdRecord != null && maxIdRecord.isNotEmpty) {
      // If there is an existing record, increment the ID
      print(maxIdRecord);
      print("@@@");
      newId = ((maxIdRecord.first['id'] as int?)! + 1)!;
    }

    // Set the new ID for the FormData
    formData = FormData(
      id: newId,
      domain: formData.domain,
      email: formData.email,
      password: formData.password,
      optionalFields: formData.optionalFields,
    );

    // Save the FormData with the new ID
    await store.record(newId).put(database, formData.toJson());
  }


  Future<void> deleteFormData(int id) async {
    final database = await openDatabase();
    await store.record(id).delete(database);
  }

  Future<void> editFormData(FormData formData) async {
    print(formData.id);
    print(formData.toJson());
    final database = await openDatabase();
    await store.record(formData.id).put(database, formData.toJson());
  }

  Future<List<FormData>> getFormDataList() async {
    final database = await openDatabase();
    final finder = Finder(sortOrders: [SortOrder(Field.key)]);
    final records = await store.find(database, finder: finder);
    return records.map((record) => FormData.fromJson(record.value)).toList();
  }
}
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController domainController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, dynamic> optionalFields = {};

  List<Widget> optionalFieldWidgets = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: domainController,
              decoration: InputDecoration(labelText: 'Domain'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            _buildOptionalFields(context),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => saveForm(context),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToDisplayScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DisplayStoredDataScreen()),
    );
  }

  Widget _buildOptionalFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Optional Fields',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...optionalFieldWidgets,
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _addOptionalField(context),
          child: Text('+ Add Field'),
          style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),)
        ),
      ],
    );
  }

  void _addOptionalField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController labelController = TextEditingController();

        return AlertDialog(
          title: Text('Enter Label for Optional Field'),
          content: TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: 'Label'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String label = labelController.text.trim();
                if (label.isNotEmpty) {
                  setState(() {
                    int fieldNumber = optionalFieldWidgets.length + 1;
                    String key = '$label';

                    optionalFields[key] = ''; // Initial value for the optional field

                    optionalFieldWidgets.add(_buildOptionalField(key));
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Field'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionalField(String key) {
    return TextField(
      onChanged: (value) {
        setState(() {
          optionalFields[key] = value;
        });
      },
      decoration: InputDecoration(labelText: '$key'),
    );
  }

  void saveForm(BuildContext context) async {
    final formData = FormData(
      id: 0,
      domain: domainController.text,
      email: emailController.text,
      password: passwordController.text,
      optionalFields: optionalFields,
    );

    final dbHelper = DatabaseHelper();
    await dbHelper.saveFormData(formData);

    // Optionally, clear the form fields after saving
    domainController.clear();
    emailController.clear();
    passwordController.clear();
    setState(() {
      optionalFields.clear();
      optionalFieldWidgets.clear();
    });
    navigateToDisplayScreen(context);
  }
}


class DisplayStoredDataScreen extends StatefulWidget {
  @override
  _DisplayStoredDataScreenState createState() => _DisplayStoredDataScreenState();
}

class _DisplayStoredDataScreenState extends State<DisplayStoredDataScreen>{
//class DisplayStoredDataScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Credentials'),
      ),
      body:
          Column(
            children: [

              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => navigateToFormScreen(context),
                  child: Text('+ Add New Credential'),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<FormData>>(
                  future: DatabaseHelper().getFormDataList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No stored data.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final formData = snapshot.data![index];
                          String domain = ' ${formData.domain}';

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.blue.shade100,// Background color of the ListTile
                              leading: CircleAvatar(
                                backgroundColor: Colors.white, // Background color of the CircleAvatar
                                child: Text(
                                  domain.substring(0,2).toUpperCase(), // Initial character
                                  style: TextStyle(
                                    color: Colors.blue, // Text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(domain,
                                  style: TextStyle(fontSize: 25, )),
                             // subtitle: Text('Email: ${formData.email}, Password: ${formData.password}'),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () {
                                _showDataDialog(context, formData);
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
    );
  }

  void navigateToFormScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnotherClass()),
    );
  }

  void _showDataDialog(BuildContext context, FormData formData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Text('Saved Credential',
                style: TextStyle(fontSize: 30)),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Domain:  ${formData.domain}',
                  style: TextStyle(fontSize: 25)),
              Text('Email:  ${formData.email}',
                  style: TextStyle(fontSize: 25)),
              Text('Password:  ${formData.password}',
                  style: TextStyle(fontSize: 25)),
              if(formData.optionalFields.entries.isNotEmpty)
              Text('Optional Fields:'),
              ...formData.optionalFields.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}',
                    style: TextStyle(fontSize: 20));
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close',style: TextStyle(fontSize: 25, color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _editFormData(context, formData);
              },
              child: Text('Edit',style: TextStyle(fontSize: 25, color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteFormData(context, formData.id);
              },
              child: Text('Delete',style: TextStyle(fontSize: 25, color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),),
            ),
          ],
        );
      },
    );
  }


  void _editFormData(BuildContext context, FormData formData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Controllers for editing fields
        TextEditingController domainController = TextEditingController(text: formData.domain);
        TextEditingController emailController = TextEditingController(text: formData.email);
        TextEditingController passwordController = TextEditingController(text: formData.password);

        // Controllers for optional fields
        Map<String, TextEditingController> optionalFieldsControllers = {};
        formData.optionalFields.forEach((key, value) {
          optionalFieldsControllers[key] = TextEditingController(text: value);
        });
        return AlertDialog(
          title: Text('Edit Credentials',style: TextStyle(fontSize: 25)),
          content: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: domainController,
                    decoration: InputDecoration(labelText: 'Domain', ),
                      style: TextStyle(fontSize: 20)
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                      style: TextStyle(fontSize: 20)
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                      style: TextStyle(fontSize: 20)
                  ),
                  // UI for optional fields
                  ...formData.optionalFields.keys.map((fieldKey) {
                    return TextField(
                      controller: optionalFieldsControllers[fieldKey],
                      decoration: InputDecoration(labelText: fieldKey),
                        style: TextStyle(fontSize: 20)
                    );
                  }).toList(),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Save the edited data
                      FormData editedData = FormData(
                        id: formData.id,
                        domain: domainController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        optionalFields: Map.fromEntries(
                          optionalFieldsControllers.entries.map((entry) => MapEntry(entry.key, entry.value.text)),
                        ),
                      );
                      _saveEditedData(context, editedData);
                    },
                    child: Text('Save',style: TextStyle(fontSize: 25, color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),),
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  Future<void> _saveEditedData(BuildContext context, FormData formData) async {
    // Implement logic to save the edited data, you can use your DatabaseHelper
    // For example: DatabaseHelper().editFormData(editedData);
    final dbHelper = DatabaseHelper();
    await dbHelper.editFormData(formData);
    // Close the bottom sheet
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data updated successfully'),
      ),
    );

    // Fetch and update the data again to trigger a rebuild
    setState(() {});
  }

  void _deleteFormData(BuildContext context, int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteFormData(id);

    // Update the UI to reflect the deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data deleted successfully'),
      ),
    );

    // Fetch and update the data again to trigger a rebuild
    setState(() {});
    // You may want to refresh the displayed data in the UI after deletion
    // For example, you could call setState to trigger a rebuild of the UI
    // Or you could re-fetch the data and update the FutureBuilder's future
  }
}
