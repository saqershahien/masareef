import 'package:flutter/material.dart';
import 'package:grade_project/database_helper.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:grade_project/masareef_transaction.dart';
import 'dart:math';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final transactions = await DatabaseHelper().getTransactions();
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions to export.')),
        );
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Transactions'];

      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Amount'),
        TextCellValue('Date'),
        TextCellValue('Category'),
        TextCellValue('Type'),
        TextCellValue('Notes'),
      ]);

      for (var tx in transactions) {
        sheet.appendRow([
          IntCellValue(tx.id ?? -1),
          DoubleCellValue(tx.amount),
          TextCellValue(tx.date.toIso8601String()),
          TextCellValue(tx.category),
          TextCellValue(tx.type),
          TextCellValue(tx.notes ?? ''),
        ]);
      }

      final String? outputDirectory = await FilePicker.platform.getDirectoryPath();

      if (outputDirectory != null) {
        final path = p.join(outputDirectory, 'Masareef_Transactions.xlsx');
        final fileBytes = excel.save();

        if (fileBytes != null) {
          final file = File(path);
          await file.create(recursive: true);
          await file.writeAsBytes(fileBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Exported successfully!'),
              action: SnackBarAction(
                label: 'Open File',
                onPressed: () {
                  OpenFile.open(path);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save Excel file.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  Future<void> _exportToPdf(BuildContext context) async {
    try {
      final transactions = await DatabaseHelper().getTransactions();
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions to export.')),
        );
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(level: 0, text: 'Masareef Transactions'),
            pw.Table.fromTextArray(
              headers: <String>['ID', 'Amount', 'Date', 'Category', 'Type', 'Notes'],
              data: transactions.map((tx) => [
                tx.id?.toString() ?? '',
                tx.amount.toString(),
                tx.date.toIso8601String(),
                tx.category,
                tx.type,
                tx.notes ?? '',
              ]).toList(),
            ),
          ],
        ),
      );

      final String? outputDirectory = await FilePicker.platform.getDirectoryPath();

      if (outputDirectory != null) {
        final path = p.join(outputDirectory, 'Masareef_Transactions.pdf');
        final file = File(path);
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported successfully!'),
            action: SnackBarAction(
              label: 'Open File',
              onPressed: () {
                OpenFile.open(path);
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  Future<void> _importFromExcel(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);

        final sheet = excel.tables[excel.tables.keys.first];
        if (sheet == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No sheet found in the Excel file.')),
          );
          return;
        }

        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final transaction = MasareefTransaction(
            amount: (row[1]!.value as double),
            date: DateTime.parse(row[2]!.value.toString()),
            category: row[3]!.value.toString(),
            type: row[4]!.value.toString(),
            notes: row[5]!.value.toString(),
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          );
          await DatabaseHelper().insertTransaction(transaction);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imported successfully!')),
        );
      } else {
        // User canceled the picker
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Import'),
        backgroundColor: Colors.grey[850],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _exportToExcel(context),
              icon: const Icon(Icons.table_chart),
              label: const Text('Export to Excel'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _exportToPdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export to PDF'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _importFromExcel(context),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Import from Excel'),
            ),
          ],
        ),
      ),
    );
  }
}
