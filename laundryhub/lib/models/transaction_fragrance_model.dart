class TransactionFragranceModel {

  final String fragranceName;

  TransactionFragranceModel({

    required this.fragranceName,

  });

  factory TransactionFragranceModel.fromJson(
      Map<String,dynamic> json){

    return TransactionFragranceModel(

      fragranceName:
      json["fragrance_name"] ?? "",

    );

  }

}