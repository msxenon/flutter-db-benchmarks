import 'package:core/model.dart';

void assignIds<EntityT>(List<EntityWithSettableId> list) {
  for (var i = 0; i < list.length; i++) {
    list[i].id = i + 1;
  }
}