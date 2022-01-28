import 'package:core/model.dart';
import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 1)
class TestEntityPlain implements TestEntity {
  @HiveField(0)
  int id;

  @HiveField(1)
  String tString;

  @HiveField(2)
  int tInt; // 32-bit

  @HiveField(3)
  int tLong; // 64-bit

  @HiveField(4)
  double tDouble;

  TestEntityPlain(this.id, this.tString, this.tInt, this.tLong, this.tDouble);

  // TODO remove later; isar v0.4.0 needs a "public zero-arg constructor"
  // NOTE: you also need to fix isar.g.dart after each generation to use this
  // constructor.
  TestEntityPlain.forIsar()
      : id = 0,
        tString = '',
        tInt = 0,
        tLong = 0,
        tDouble = 0;

  static TestEntityPlain fromMap(Map<String, dynamic> map) => TestEntityPlain(
      map['id'] ?? 0,
      map['tString'],
      map['tInt'],
      map['tLong'],
      map['tDouble']);
}

// A separate entity for queried data so that indexes don't change CRUD results.
@HiveType(typeId: 2)
class TestEntityIndexed implements TestEntity {
  @HiveField(0)
  int id;

  @HiveField(1)
  String tString;

  @HiveField(2)
  int tInt; // 32-bit

  @HiveField(3)
  int tLong; // 64-bit

  @HiveField(4)
  double tDouble;

  TestEntityIndexed(this.id, this.tString, this.tInt, this.tLong, this.tDouble);

  TestEntityIndexed.forIsar()
      : id = 0,
        tString = '',
        tInt = 0,
        tLong = 0,
        tDouble = 0;

  static TestEntityIndexed fromMap(Map<String, dynamic> map) =>
      TestEntityIndexed(map['id'] ?? 0, map['tString'], map['tInt'],
          map['tLong'], map['tDouble']);
}

@HiveType(typeId: 3)
class RelSourceEntityPlain implements RelSourceEntity {
  @HiveField(0)
  int id;

  @HiveField(1)
  final String tString;

  @HiveField(2)
  final int tLong; // 64-bit

  @HiveField(3)
  final int relTargetId;

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityPlain(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]);

  RelSourceEntityPlain.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {}

  RelSourceEntityPlain.forIsar()
      : id = 0,
        tString = '',
        tLong = 0,
        relTargetId = 0;

  static RelSourceEntityPlain fromMap(Map<String, dynamic> map) =>
      RelSourceEntityPlain(
          map['id'] ?? 0, map['tString'], map['tLong'], map['relTargetId']);
}

@HiveType(typeId: 4)
class RelSourceEntityIndexed implements RelSourceEntity {
  @HiveField(0)
  int id;

  @HiveField(1)
  final String tString;

  @HiveField(2)
  final int tLong; // 64-bit

  @HiveField(3)
  final int relTargetId;

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityIndexed(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]) {}

  RelSourceEntityIndexed.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {}

  RelSourceEntityIndexed.forIsar()
      : id = 0,
        tString = '',
        tLong = 0,
        relTargetId = 0;

  static RelSourceEntityIndexed fromMap(Map<String, dynamic> map) =>
      RelSourceEntityIndexed(
          map['id'] ?? 0, map['tString'], map['tLong'], map['relTargetId']);
}

@HiveType(typeId: 5)
class RelTargetEntity extends EntityWithSettableId {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  RelTargetEntity(this.id, this.name);

  RelTargetEntity.forIsar()
      : id = 0,
        name = '';

  static Map<String, dynamic> toMap(RelTargetEntity object) =>
      <String, dynamic>{
        'id': object.id == 0 ? null : object.id,
        'name': object.name
      };

  static RelTargetEntity fromMap(Map<String, dynamic> map) =>
      RelTargetEntity(map['id'] ?? 0, map['name']);
}
