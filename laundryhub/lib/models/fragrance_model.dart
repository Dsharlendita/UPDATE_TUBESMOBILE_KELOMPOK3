class FragranceModel {

  final int id;
  final String name;
  final String color;
  final bool isActive;
  final String createdAt;

  FragranceModel({

    required this.id,
    required this.name,
    required this.color,
    required this.isActive,
    required this.createdAt,

  });

  factory FragranceModel.fromJson(
      Map<String,dynamic> json){

    return FragranceModel(

      id: json["id"],

      name:
      json["name"] ?? "",

      color:
      json["color"] ?? "blue",

      isActive:
      json["is_active"] ?? false,

      createdAt:
      json["created_at"] ?? "",

    );

  }

}