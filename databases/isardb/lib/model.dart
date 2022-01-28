import 'package:core/model.dart';
import 'package:isar/isar.dart';

part 'model.g.dart';

@Collection()
class TestEntityPlain implements TestEntity {
  int id;

  String tString;

  int tInt; // 32-bit

  int tLong; // 64-bit

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
@Collection()
class TestEntityIndexed implements TestEntity {
  int id;

  @Index(type: IndexType.value)
  String tString;

  @Index()
  int tInt; // 32-bit

  int tLong; // 64-bit

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

@Collection()
class RelSourceEntityPlain implements RelSourceEntity {
  int id;

  final String tString;

  final int tLong; // 64-bit

  @Ignore()
  final int relTargetId;

  final isarRelTarget = IsarLink<RelTargetEntity>();

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityPlain(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]);

  RelSourceEntityPlain.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {
    isarRelTarget.value = relTarget;
  }

  RelSourceEntityPlain.forIsar()
      : id = 0,
        tString = '',
        tLong = 0,
        relTargetId = 0;

  static RelSourceEntityPlain fromMap(Map<String, dynamic> map) =>
      RelSourceEntityPlain(
          map['id'] ?? 0, map['tString'], map['tLong'], map['relTargetId']);
}

@Collection()
class RelSourceEntityIndexed implements RelSourceEntity {
  int id;

  @Index(type: IndexType.value)
  final String tString;

  final int tLong; // 64-bit

  @Ignore()
  final int relTargetId;

  final isarRelTarget = IsarLink<RelTargetEntity>();

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityIndexed(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]) {}

  RelSourceEntityIndexed.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {
    isarRelTarget.value = relTarget;
  }

  RelSourceEntityIndexed.forIsar()
      : id = 0,
        tString = '',
        tLong = 0,
        relTargetId = 0;

  static RelSourceEntityIndexed fromMap(Map<String, dynamic> map) =>
      RelSourceEntityIndexed(
          map['id'] ?? 0, map['tString'], map['tLong'], map['relTargetId']);
}

@Collection()
class RelTargetEntity extends EntityWithSettableId {
  int id;

  @Index(type: IndexType.value)
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
