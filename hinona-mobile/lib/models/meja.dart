class MejaModel {
  final int id;
  final String nomorMeja;

  MejaModel({
    required this.id,
    required this.nomorMeja,
  });

  factory MejaModel.fromJson(Map<String, dynamic> json) {
    return MejaModel(
      id: json['id'] ?? 0,
      nomorMeja: '${json['nomor_meja'] ?? json['nomor'] ?? ''}',
    );
  }
}

typedef Meja = MejaModel;