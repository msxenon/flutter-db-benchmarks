abstract class EntityWithSettableId {
  int get id;
  set id(int value);
}

abstract class TestEntity extends EntityWithSettableId {
  String get tString;

  int get tInt; // 32-bit

  int get tLong; // 64-bit
  set tLong(int value);

  double get tDouble;

  static Map<String, dynamic> toMap(TestEntity object) => <String, dynamic>{
        'id': object.id == 0 ? null : object.id,
        'tString': object.tString,
        'tInt': object.tInt,
        'tLong': object.tLong,
        'tDouble': object.tDouble
      };
}

abstract class RelSourceEntity extends EntityWithSettableId {
  int get id;

  set id(int value);

  String get tString;

  int get tLong;

  // for hive & sqflite
  int get relTargetId;

  static Map<String, dynamic> toMap(RelSourceEntity object) =>
      <String, dynamic>{
        'id': object.id == 0 ? null : object.id,
        'tString': object.tString,
        'tLong': object.tLong,
        'relTargetId': object.relTargetId,
      };
}
