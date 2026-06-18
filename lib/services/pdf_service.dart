import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/test_model.dart';
import '../screens/test_catalog_screen.dart';

class PdfService {
  static const String pageSizeKey = 'pdf_page_size';

  static Future<Uint8List> generateReportBytes(Order order) async {
    final pdf = await _buildPdf(order);
    return await pdf.save();
  }

  static Future<String> generateReport(Order order, {String? savePath}) async {
    final pdf = await _buildPdf(order);
    final bytes = await pdf.save();
    final fileName = 'Patient_Report_${order.orderId.isNotEmpty ? order.orderId : DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
    final directory = await getDownloadsDirectory();
    final filePath = savePath ?? '${directory!.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    print('PDF saved to: $filePath');
    return filePath;
  }

  static Future<pw.Document> _buildPdf(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final sizeName = prefs.getString(pageSizeKey) ?? 'A4';
    final format = _getPageFormat(sizeName);

    final doc = pw.Document();

    final simpleResults = <String, String>{};
    final panelResults = <String, Map<String, String>>{};

    for (var entry in order.results.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key.contains('_')) {
        final parts = key.split('_');
        final testName = parts.first;
        final paramName = parts.sublist(1).join('_');
        panelResults.putIfAbsent(testName, () => {});
        panelResults[testName]![paramName] = value;
      } else {
        simpleResults[key] = value;
      }
    }

    if (simpleResults.isNotEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(order, 'Test Results'),
                pw.SizedBox(height: 20),
                _buildSimpleTestTable(simpleResults),
                pw.SizedBox(height: 30),
                _buildFooter(),
              ],
            );
          },
        ),
      );
    }

    for (var entry in panelResults.entries) {
      final testName = entry.key;
      final params = entry.value;
      Test? testInfo;
      for (var t in []) {
        if (t.name == testName) {
          testInfo = t;
          break;
        }
      }
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(order, testName),
                pw.SizedBox(height: 20),
                _buildPanelTable(testName, params, testInfo),
                pw.SizedBox(height: 30),
                _buildFooter(),
              ],
            );
          },
        ),
      );
    }

    return doc;
  }

  static pw.Widget _buildHeader(Order order, String sectionTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('PATHOLOGY LAB',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              pw.Text('123 Health Street, City, State',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text('Phone: +92 300 1234567 | Email: lab@pathology.com',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(height: 10),
              pw.Divider(),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Patient: ${order.patientName}', style: const pw.TextStyle(fontSize: 14)),
                if (order.referredBy != null)
                  pw.Text('Ref Dr: ${order.referredBy}',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.Text('Order: ${order.orderId}',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Date: ${order.orderDate.toLocal().toString().split(' ')[0]}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Time: ${order.orderDate.toLocal().toString().split(' ')[1]}',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.Text(sectionTitle,
                    style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSimpleTestTable(Map<String, String> results) {
    final rows = <pw.TableRow>[];
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.indigo100),
        children: [
          _cell('Test', bold: true),
          _cell('Result', bold: true),
          _cell('Unit', bold: true),
          _cell('Normal Range', bold: true),
          _cell('Flag', bold: true),
        ],
      ),
    );
    for (var entry in results.entries) {
      final testName = entry.key;
      final resultValue = entry.value;
      Test? testInfo;
      for (var t in []) {
        if (t.name == testName) {
          testInfo = t;
          break;
        }
      }
      String unit = '', normalRange = '', flag = '';
      if (testInfo != null) {
        if (testInfo.isQualitative) {
          flag = resultValue;
        } else {
          unit = testInfo.unit ?? '';
          normalRange = '${testInfo.minRange?.toString() ?? ''} - ${testInfo.maxRange?.toString() ?? ''}';
          final numResult = double.tryParse(resultValue);
          if (numResult != null && testInfo.minRange != null && testInfo.maxRange != null) {
            if (numResult < testInfo.minRange!) flag = 'L';
            else if (numResult > testInfo.maxRange!) flag = 'H';
            else flag = 'N';
          }
        }
      }
      rows.add(
        pw.TableRow(
          children: [
            _cell(testName),
            _cell(resultValue),
            _cell(unit),
            _cell(normalRange),
            _cell(flag, color: flag == 'H' || flag == 'L' ? PdfColors.red : flag == 'N' ? PdfColors.green : PdfColors.black),
          ],
        ),
      );
    }
    return pw.Table(border: pw.TableBorder.all(), children: rows);
  }

  static pw.Widget _buildPanelTable(String testName, Map<String, String> params, Test? testInfo) {
    final rows = <pw.TableRow>[];
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.indigo100),
        children: [
          _cell('Parameter', bold: true),
          _cell('Result', bold: true),
          _cell('Unit', bold: true),
          _cell('Normal Range', bold: true),
          _cell('Flag', bold: true),
        ],
      ),
    );
    for (var entry in params.entries) {
      final paramName = entry.key;
      final resultValue = entry.value;
      String unit = '', normalRange = '', flag = '';
      if (testInfo != null) {
        for (var comp in testInfo.components) {
          if (comp.name == paramName) {
            unit = comp.unit ?? '';
            normalRange = '${comp.minRange?.toString() ?? ''} - ${comp.maxRange?.toString() ?? ''}';
            final numResult = double.tryParse(resultValue);
            if (numResult != null && comp.minRange != null && comp.maxRange != null) {
              if (numResult < comp.minRange!) flag = 'L';
              else if (numResult > comp.maxRange!) flag = 'H';
              else flag = 'N';
            }
            break;
          }
        }
      }
      rows.add(
        pw.TableRow(
          children: [
            _cell(paramName),
            _cell(resultValue),
            _cell(unit),
            _cell(normalRange),
            _cell(flag, color: flag == 'H' || flag == 'L' ? PdfColors.red : flag == 'N' ? PdfColors.green : PdfColors.black),
          ],
        ),
      );
    }
    return pw.Table(border: pw.TableBorder.all(), children: rows);
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Text(
        'Report generated on ${DateTime.now().toLocal().toString().split(' ')[0]}',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : null,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static PdfPageFormat _getPageFormat(String name) {
    switch (name) {
      case 'A4':
        return PdfPageFormat.a4;
      case 'A5':
        return PdfPageFormat.a5;
      case 'Letter':
        return PdfPageFormat.letter;
      default:
        return PdfPageFormat.a4;
    }
  }

  static Future<void> savePageSize(String sizeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pageSizeKey, sizeName);
  }
}
