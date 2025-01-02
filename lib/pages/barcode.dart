// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:csv/csv.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:google_fonts/google_fonts.dart' as gf;
// import 'package:printing/printing.dart';
// import 'package:barcode/barcode.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import 'package:tes_importcsv/utils/bukuModel.dart';
// import 'package:tes_importcsv/utils/restapiBuku.dart';
// import 'package:tes_importcsv/utils/config.dart';

// class ManageScreen extends StatefulWidget {
//   final String collection;
//   final String title;
//   final Function(List<List<dynamic>>) onBooksImported;

//   const ManageScreen({
//     super.key,
//     required this.collection,
//     required this.title,
//     required this.onBooksImported,
//   });

//   @override
//   State<ManageScreen> createState() => _ManageScreenState();
// }

// class _ManageScreenState extends State<ManageScreen> {
//   DataService ds = DataService();
//   List<BukuModel> buku = [];
//   bool _isLoading = false;

//   Future<List<BukuModel>> selectAllBuku() async {
//     final String jsonResponse =
//         await ds.selectAll(token, project, 'buku', appid);
//     final List data = jsonDecode(jsonResponse);
//     return data.map((e) => BukuModel.fromJson(e)).toList();
//   }

//   Future<void> selectAllBukuAndUpdateState() async {
//     try {
//       final allBuku = await selectAllBuku();
//       setState(() {
//         buku = allBuku;
//       });
//     } catch (e) {
//       print("Error fetching books: $e");
//     }
//   }

//   Future<int> countBooksByCategory(String category) async {
//     final String jsonResponse = await ds.selectWhere(
//       token,
//       project,
//       'buku',
//       appid,
//       'kategori_buku', // field yang digunakan untuk pencarian
//       category, // nilai kategori yang dicari
//     );

//     final List data = jsonDecode(jsonResponse);
//     return data.length;
//   }

//   Future<bool> updateBookCode(
//       String whereField, String whereValue, String newCode) async {
//     return await ds.updateId(
//         'kode_buku', newCode, token, project, 'buku', appid, whereValue);
//   }

//   @override
//   void initState() {
//     super.initState();
//     selectAllBuku();
//   }

//   Future<void> generateAutomaticCodes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final List<BukuModel> allBuku = await selectAllBuku();

//       if (allBuku.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No books found in the database.')),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       Map<String, int> categoryCount = {};

//       for (var buku in allBuku) {
//         if (buku.kode_buku == "-") {
//           final String? kategori = buku.kategori_buku;
//           if (kategori == null || kategori.isEmpty) {
//             continue;
//           }

//           String? kodePrefix;
//           switch (kategori) {
//             case 'Tugas Akhir':
//               kodePrefix = 'TA';
//               break;
//             case 'Skripsi':
//               kodePrefix = 'SK';
//               break;
//             case 'Laporan Praktik Kerja':
//               kodePrefix = 'KP';
//               break;
//             case 'Laporan Akhir MBKM':
//               kodePrefix = 'MBKM';
//               break;
//             default:
//               continue;
//           }

//           categoryCount[kategori] = (categoryCount[kategori] ?? 0) + 1;
//           final String urutan =
//               categoryCount[kategori]!.toString().padLeft(3, '0');

//           final String penerbit = buku.penerbit;
//           if (penerbit.isEmpty || !penerbit.startsWith('16')) {
//             continue;
//           }

//           final String penerbitCode =
//               penerbit.substring(2, 6) + '-' + penerbit.substring(6);

//           final String newKode = '$kodePrefix-$urutan-$penerbitCode';

//           final bool updated = await updateBookCode('_id', buku.id, newKode);

//           if (!updated) {
//             print("Failed to update book ID ${buku.id}.");
//           }
//         }
//       }
//     } catch (e) {
//       print("An error occurred during the automatic code generation: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 'Automatic code generation process completed. Check logs for details.')),
//       );
//     }
//   }

//   Future<void> importData(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform
//           .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
//       if (result != null) {
//         final fileBytes = result.files.single.bytes;
//         if (fileBytes != null) {
//           final csvData = CsvToListConverter()
//               .convert(String.fromCharCodes(fileBytes), eol: '\n');
//           widget.onBooksImported(csvData.skip(1).toList());

//           for (var row in csvData.skip(1)) {
//             if (row.length >= 4) {
//               await FirebaseFirestore.instance
//                   .collection(widget.collection)
//                   .add({
//                 'author': row[0],
//                 'quantity': int.tryParse(row[1].toString()) ?? 0,
//                 'title': row[2],
//                 'year': int.tryParse(row[3].toString()) ?? 0,
//               });
//             }
//           }

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('CSV file successfully imported!')),
//           );
//         }
//       }
//     } catch (e) {
//       print("Error importing data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to import CSV file.')),
//       );
//     }
//   }

//   Future<void> exportDataToPDF() async {
//     setState(() {
//       _isLoading = true; // Tampilkan indikator loading
//     });

//     try {
//       final List<BukuModel> allBuku = await selectAllBuku();

//       if (allBuku.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No books found in the database.')),
//         );
//         return;
//       }

//       final pdf = pw.Document();
//       final font = await PdfGoogleFonts.notoSansRegular();

//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'Barcode Buku',
//                   style: pw.TextStyle(fontSize: 24, font: font),
//                 ),
//                 pw.SizedBox(height: 16),
//                 pw.Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: allBuku.map((buku) {
//                     final barcode = Barcode.code128();
//                     final barcodeSvg = barcode.toSvg(
//                       buku.id,
//                       width: 200,
//                       height: 80,
//                       fontHeight: 0,
//                     );

//                     return pw.Column(
//                       mainAxisSize: pw.MainAxisSize.min,
//                       children: [
//                         pw.Container(
//                           width: 200,
//                           height: 80,
//                           child: pw.SvgImage(
//                               svg: barcodeSvg), // Menampilkan barcode
//                         ),
//                         pw.SizedBox(height: 4),
//                         pw.Text(
//                           buku.kode_buku,
//                           style: pw.TextStyle(fontSize: 12, font: font),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ],
//             );
//           },
//         ),
//       );

//       final pdfBytes = await pdf.save();
//       await Printing.sharePdf(
//         bytes: pdfBytes,
//         filename: '${widget.collection}-barcodes.pdf',
//       );
//     } catch (e) {
//       print("Error exporting PDF: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to export barcodes to PDF.')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Sembunyikan indikator loading
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage ${widget.title}'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Books Data Table',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => importData(context),
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text('Import CSV'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12.0, horizontal: 16.0),
//                         backgroundColor: Colors.teal,
//                         foregroundColor: Colors.white,
//                         textStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: exportDataToPDF,
//                       icon: const Icon(Icons.picture_as_pdf),
//                       label: const Text('Export PDF'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12.0, horizontal: 16.0),
//                         backgroundColor: Colors.orange,
//                         foregroundColor: Colors.white,
//                         textStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: generateAutomaticCodes,
//                       icon: const Icon(Icons.picture_as_pdf),
//                       label: const Text('Generate Code'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12.0, horizontal: 16.0),
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         textStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: FutureBuilder<List<BukuModel>>(
//                     future: selectAllBuku(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }
//                       if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return const Center(child: Text('No data available'));
//                       }

//                       final data = snapshot.data!;

//                       return DataTable(
//                         columnSpacing: 50.0,
//                         columns: const [
//                           DataColumn(label: Text('Judul Buku')),
//                           DataColumn(label: Text('Pengarang')),
//                           DataColumn(label: Text('Penerbit')),
//                           DataColumn(label: Text('Kategori Buku')),
//                           DataColumn(label: Text('Kode Buku')),
//                         ],
//                         rows: data.map((item) {
//                           return DataRow(
//                             cells: [
//                               DataCell(Text(
//                                 item.judul_buku,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               )),
//                               DataCell(Text(item.pengarang)),
//                               DataCell(Text(item.penerbit)),
//                               DataCell(Text(item.kategori_buku)),
//                               DataCell(Text(item.kode_buku)),
//                             ],
//                           );
//                         }).toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
