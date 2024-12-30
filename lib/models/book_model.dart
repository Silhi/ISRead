class BukuModel {
  final String id;
  final String judul_buku;
  final String pengarang;
  final String penerbit;
  final String kategori_buku;
  final String tahun_terbit;
  final String sampul_buku;
  final String status;
  final String deskripsi;
  final String dosen_pembimbing;
  final String kode_buku;

  BukuModel(
      {required this.id,
      required this.judul_buku,
      required this.pengarang,
      required this.penerbit,
      required this.kategori_buku,
      required this.tahun_terbit,
      required this.sampul_buku,
      required this.status,
      required this.deskripsi,
      required this.dosen_pembimbing,
      required this.kode_buku});

  factory BukuModel.fromJson(Map data) {
    return BukuModel(
        id: data['_id'],
        judul_buku: data['judul_buku'],
        pengarang: data['pengarang'],
        penerbit: data['penerbit'],
        kategori_buku: data['kategori_buku'],
        tahun_terbit: data['tahun_terbit'],
        sampul_buku: data['sampul_buku'],
        status: data['status'],
        deskripsi: data['deskripsi'],
        dosen_pembimbing: data['dosen_pembimbing'],
        kode_buku: data['kode_buku']);
  }
}
