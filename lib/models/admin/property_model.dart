import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class PropertyModel {
  List<String> sliders = [];

  PropertyModel({

    this.sliders = const  [],

  });

  PropertyModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    sliders = ParsingHelper.parseListMethod<dynamic, String>(map['sliders']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "sliders": sliders,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}