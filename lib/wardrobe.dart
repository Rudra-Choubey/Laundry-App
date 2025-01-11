
import 'package:hive/hive.dart';
part 'wardrobe.g.dart';

@HiveType(typeId: 1)
class Cloth {
  Cloth({required this.type, required this.count});
  @HiveField(0)
  String type;

  @HiveField(1)
  int count;
}