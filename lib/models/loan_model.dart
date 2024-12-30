class PeminjamanModel {
  final String id;
  final String id_buku;
  final String id_user;
  final String tgl_pinjam;
  final String tgl_kembali;
  final String denda;
  final String status;
  final String judul_buku;

  PeminjamanModel(
      {required this.id,
      required this.id_buku,
      required this.id_user,
      required this.tgl_pinjam,
      required this.tgl_kembali,
      required this.denda,
      required this.status,
      required this.judul_buku});

  factory PeminjamanModel.fromJson(Map data) {
    return PeminjamanModel(
        id: data['_id'],
        id_buku: data['id_buku'],
        id_user: data['id_user'],
        tgl_pinjam: data['tgl_pinjam'],
        tgl_kembali: data['tgl_kembali'],
        denda: data['denda'],
        status: data['status'],
        judul_buku: data['judul_buku']);
  }
}
