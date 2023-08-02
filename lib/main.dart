import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrotherHack 2023',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Print'),
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

  // Tracks the currently selected printer.
  Model _selectedModel = Model.QL_1110NWB;

  // List of printers to choose from.
  final List<Model> _printers = [
    Model.QL_1110NWB,
    Model.QL_820NWB,
    Model.QL_810W
  ];

  // Selected paper for a printer.
  late ALabelName _selectedPaper;

  // This are the paper options we support.
  // Each printer has a specific set of papers it supports.
  // Because of that we will track these options in a map of printer to paper options.
  // We'll then pick the paper options based on the printer selected.
  final Map<Model, List<ALabelName>> _paperChoices = {
    Model.QL_1110NWB: [QL1100.W103, QL1100.W62],
    Model.QL_820NWB: [QL700.W62, QL700.W62H29],
    Model.QL_810W: [QL700.W62, QL700.W62H29]
  };

  // Currently selected print mode.
  PrintMode _selectedFit = PrintMode.FIT_TO_PAGE;

  // List of print modes we currently support.
  final List<PrintMode> _pageFit = [
    PrintMode.FIT_TO_PAGE,
    PrintMode.SCALE,
    PrintMode.ORIGINAL
  ];

  // Selected halftone.
  Halftone _selectedHalftone = Halftone.PATTERNDITHER;

  // List of halftone options we currently support.
  final List<Halftone> _halftone = [
    Halftone.PATTERNDITHER,
    Halftone.ERRORDIFFUSION
  ];

  // Bytes of the selected image that was picked by the user.
  Uint8List? _selectedFileBytes;

  @override
  void initState() {
    super.initState();
    // When the widget is initialized we'll make sure the default paper is
    // one for the default printer by selecting the first paper for that printer
    // from the paper choices map.
    _selectedPaper = _paperChoices[_selectedModel]!.first;
  }

  @override
  Widget build(BuildContext context) {
    print("Image Bytes: $_selectedFileBytes");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // In order to allow the user to pick an image we'll user a gesture
            // detector to detect user taps.
            // When the user taps we'll open up the image picker.
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Open the file picker.
                _pickImage();
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                        style: BorderStyle.solid)),
                child: Stack(
                  children: [
                    // Once the image is selected will display it ot the user.
                    if (_selectedFileBytes != null) ...[
                      Center(child: Image.memory(_selectedFileBytes!))
                    ] else ...[
                      // If no image is selected we'll just display a text prompting the user to do so.
                      const Center(child: Text("Tap to pick file")),
                    ]
                  ],
                ),
              ),
            ),

            // This will be the list of available printer models to print with.
            const Text("Select printer model"),
            DropdownButton<Model>(
              value: _selectedModel, // Sets the active printer, this will update as the user makes a choice.
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Model? value) {
                // This is called when the user selects an item.
                setState(() {
                  // When the user picks a printer we track the printer model selected.
                  _selectedModel = value!;
                  // We'll also update the selected paper to ensure it matches a paper
                  // allowed for that printer.
                  _selectedPaper = _paperChoices[_selectedModel]!.first;
                });
              },
              // For every printer model we'll create a dropdown item for the user.
              items: _printers.map<DropdownMenuItem<Model>>((Model value) {
                return DropdownMenuItem<Model>(
                  value: value,
                  child: Text(value.getName()), // We'll show the user the printer name.
                );
              }).toList(),
            ),

            // Paper Selection Dropdown
            // This sections follows the same format as the one above using the labels
            // as the list.
            const Text("Select label"),
            DropdownButton<ALabelName>(
              key: ValueKey<String>(_selectedModel.getName()),
              value: _selectedPaper,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (ALabelName? value) {
                // This is called when the user selects an item.
                setState(() {
                  // Track the selected label.
                  _selectedPaper = value!;
                });
              },
              // The paper options will change based on the selected printer.
              // So will display the list of labels by first using the printer model
              // as the key to our labels map and generate our user options from the
              // values list.
              items: _paperChoices[_selectedModel]!
                  .map<DropdownMenuItem<ALabelName>>((ALabelName value) {
                return DropdownMenuItem<ALabelName>(
                  value: value,
                  child: Text(value.getName()),
                );
              }).toList(),
            ),

            // Fit Selection Dropdown
            // This sections follows the same format as the one above using the fit options
            // as the list.
            const Text("Select print mode"),
            DropdownButton<PrintMode>(
              value: _selectedFit,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (PrintMode? value) {
                // This is called when the user selects an item.
                setState(() {
                  _selectedFit = value!;
                });
              },
              items:
                  _pageFit.map<DropdownMenuItem<PrintMode>>((PrintMode value) {
                return DropdownMenuItem<PrintMode>(
                  value: value,
                  child: Text(value.getName()),
                );
              }).toList(),
            ),

            // Halftone selection
            // This sections follows the same format as the one above using the halftone options
            // as the list.
            const Text("Select halftone"),
            DropdownButton<Halftone>(
              value: _selectedHalftone,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Halftone? value) {
                // This is called when the user selects an item.
                setState(() {
                  _selectedHalftone = value!;
                });
              },
              items:
                  _halftone.map<DropdownMenuItem<Halftone>>((Halftone value) {
                return DropdownMenuItem<Halftone>(
                  value: value,
                  child: Text(value.getName()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _print, // When the FAB is pressed we'll start the printing process.
        tooltip: 'Print',
        child: const Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _print() async {
    var printer = Printer();
    var printInfo = PrinterInfo();

    // Set the printer model to the one we selected.
    printInfo.printerModel = _selectedModel;
    // Set the print mode to the one we selected.
    printInfo.printMode = _selectedFit;
    printInfo.isAutoCut = true;
    // Print over WiFi.
    printInfo.port = Port.NET;
    // Set the label type to the one we selected.
    printInfo.labelNameIndex = _getOrdinalFromLabel(_selectedPaper);

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<NetPrinter> printers =
        await printer.getNetPrinters([_selectedModel.getName()]);


    // If no printer is found we'll notify the user using a snackbard.
    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No printers found."),
        ),
      ));

      return;
    }
    // Get IP Address from the first printer found.
    printInfo.ipAddress = printers.single.ipAddress;

    // Convert the bytes of the image we selected into an image object we can send to
    // another_brother to be printed.
    var imageToPrint = await getImageFromBytes(_selectedFileBytes!);

    // Update the printer with the latest print settings.
    printer.setPrinterInfo(printInfo);

    // Send the image to be printer.
    printer.printImage(imageToPrint);
  }

  ///
  /// Helper method to get the label index from the Label name.
  ///
  int _getOrdinalFromLabel(ALabelName label) {
    if (label is QL1100) {
      return QL1100.ordinalFromID(label.getId());
    } else if (label is QL700) {
      return QL700.ordinalFromID(label.getId());
    }

    return 0;
  }

  ///
  /// Helper method to pick an image file.
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom, // Set to custom so we may specify the file formats.
      allowedExtensions: ['jpg', 'png'], // Allow only images in the jpg or png format.
    );

    if (result != null) {
      print("Result ${result}");
      // If there is a result will select the first file and read it into memory.
      setState(() {
        _selectedFileBytes = result.files[0].bytes;
        print("Selected Bytes: $_selectedFileBytes");
      });
    } else {
      // User canceled the picker
    }
  }

  ///
  /// Helper function to convert a list of bytes representing an image
  /// into an image we can print.
  ///
  Future<ui.Image> getImageFromBytes(Uint8List imageBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
