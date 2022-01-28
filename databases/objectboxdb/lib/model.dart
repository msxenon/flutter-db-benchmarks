import 'package:core/model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TestEntityPlain implements TestEntity {
  int id;

  String tString;

  @Property(type: PropertyType.int)
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
@Entity()
class TestEntityIndexed implements TestEntity {
  int id;

  @Index()
  String tString;

  @Index()
  @Property(type: PropertyType.int)
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

@Entity()
class RelSourceEntityPlain implements RelSourceEntity {
  int id;

  final String tString;

  final int tLong; // 64-bit

  final obxRelTarget = ToOne<RelTargetEntity>();

  @Transient()
  final int relTargetId;

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityPlain(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]) {
    obxRelTarget.targetId = relTargetId;
  }

  RelSourceEntityPlain.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {
    obxRelTarget.targetId = relTargetId;
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

@Entity()
class RelSourceEntityIndexed implements RelSourceEntity {
  int id;

  @Index()
  final String tString;

  final int tLong; // 64-bit

  final obxRelTarget = ToOne<RelTargetEntity>();

  @Transient()
  final int relTargetId;

  // Note: constructor arg types must match with fromMap used by sqflite.
  RelSourceEntityIndexed(this.id, this.tString, this.tLong,
      [this.relTargetId = 0]) {
    obxRelTarget.targetId = relTargetId;
  }

  RelSourceEntityIndexed.forInsert(
      this.tString, this.tLong, RelTargetEntity? relTarget)
      : id = 0,
        relTargetId = relTarget?.id ?? 0 {
    obxRelTarget.targetId = relTargetId;
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

@Entity()
class RelTargetEntity extends EntityWithSettableId {
  int id;

  @Index()
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
