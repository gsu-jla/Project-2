import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/art_service.dart';
import '../../services/user_preferences_service.dart';
import '../../services/currency_service.dart';
import '../../utils/currency_utils.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final ArtService _artService;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final CurrencyService _currencyService = CurrencyService();
  File? _imageFile;
  bool _isLoading = false;
  String _currentCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _artService = await ArtService.create();
    await _loadPreferredCurrency();
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  Future<String> _getFormattedPrice(double price) async {
    try {
      final preferredCurrency = await _prefsService.getPreferredCurrency();
      final symbol = CurrencyUtils.getCurrencySymbol(preferredCurrency);
      final formattedPrice = await CurrencyUtils.formatAndConvertPrice(price, 'USD');
      return formattedPrice;
    } catch (e) {
      print('Error formatting price: $e');
      return CurrencyUtils.formatPrice(price, currency: 'USD');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadArtwork() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _artService.uploadArtwork(
          title: _titleController.text,
          price: _priceController.text,
          description: _descriptionController.text,
          imageFile: _imageFile!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artwork uploaded successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
        title: const Text(
          'Upload Artwork',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to select image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: CurrencyUtils.getCurrencySymbol(_currentCurrency),
                  suffixText: _currentCurrency,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final numericValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (numericValue != null) {
                      _getFormattedPrice(numericValue).then((formattedPrice) {
                        setState(() {
                          _priceController.text = formattedPrice;
                          _priceController.selection = TextSelection.fromPosition(
                            TextPosition(offset: formattedPrice.length),
                          );
                        });
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadArtwork,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Upload Artwork',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 