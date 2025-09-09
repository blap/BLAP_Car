import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:blap_car/modules/data/data_provider.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Export Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Export your vehicle data to a file for backup or transfer'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: dataProvider.isExporting ? null : () {
                                dataProvider.exportToExcel();
                              },
                              icon: const Icon(Icons.file_download),
                              label: const Text('Export to Excel'),
                            ),
                            ElevatedButton.icon(
                              onPressed: dataProvider.isExporting ? null : () {
                                dataProvider.exportToCsv();
                              },
                              icon: const Icon(Icons.file_download),
                              label: const Text('Export to CSV'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text('Import Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Import vehicle data from a previously exported file'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: dataProvider.isImporting ? null : () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx'],
                                );
                                
                                if (result != null && result.files.single.path != null) {
                                  dataProvider.importFromExcel(result.files.single.path!);
                                }
                              },
                              icon: const Icon(Icons.file_upload),
                              label: const Text('Import from Excel'),
                            ),
                            ElevatedButton.icon(
                              onPressed: dataProvider.isImporting ? null : () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['csv'],
                                );
                                
                                if (result != null && result.files.single.path != null) {
                                  dataProvider.importFromCsv(result.files.single.path!);
                                }
                              },
                              icon: const Icon(Icons.file_upload),
                              label: const Text('Import from CSV'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Backup Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('• Export your data regularly to prevent loss'),
                        const Text('• Store backup files in a safe location'),
                        const Text('• You can import data on a new device or after reinstalling the app'),
                      ],
                    ),
                  ),
                ),
                
                if (dataProvider.isExporting || dataProvider.isImporting) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
                
                if (dataProvider.message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: dataProvider.message.toLowerCase().contains('error') 
                      ? Colors.red.shade100 
                      : Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(dataProvider.message),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}