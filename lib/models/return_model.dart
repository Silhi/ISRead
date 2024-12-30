class PengembalianModel {
  final String id;
  final String id_pinjam;
  final String tgl_dikembalikan;
  final String bukti_foto;

  PengembalianModel(
      {required this.id,
      required this.id_pinjam,
      required this.tgl_dikembalikan,
      required this.bukti_foto});

  factory PengembalianModel.fromJson(Map data) {
    return PengembalianModel(
        id: data['_id'],
        id_pinjam: data['id_pinjam'],
        tgl_dikembalikan: data['tgl_dikembalikan'],
        bukti_foto: data['bukti_foto']);
  }
}
