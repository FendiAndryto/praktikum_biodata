import 'package:flutter/material.dart';
import 'package:saturday_firebase_project/features/biodata/model/biodata_model.dart';
import 'package:saturday_firebase_project/features/biodata/repositories/biodata_repository.dart';
import 'biodata_upsert_screen.dart';
import '../../camera/screens/camera_screen.dart'; // Import CameraScreen

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  final BiodataRepository _repository = BiodataRepository();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteBiodata(String id) async {
    try {
      await _repository.deleteBiodata(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biodata berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text('Daftar Biodata')
            : TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari biodata...',
                ),
                onChanged: (value) => setState(() {}),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt), // Tambahkan ikon kamera
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BiodataUpsertScreen(),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<BiodataModel>>(
              stream: _isSearching && _searchController.text.isNotEmpty
                  ? _repository.searchBiodata(_searchController.text)
                  : _repository.getAllBiodata(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final biodataList = snapshot.data!;
                if (biodataList.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data biodata'),
                  );
                }

                return ListView.builder(
                  itemCount: biodataList.length,
                  itemBuilder: (context, index) {
                    final biodata = biodataList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(biodata.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${biodata.age} tahun'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(biodata.address),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BiodataUpsertScreen(
                                      selectedBiodata: biodata,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus data ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteBiodata(biodata.id);
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
