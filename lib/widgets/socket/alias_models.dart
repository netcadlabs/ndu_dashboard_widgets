import 'package:ndu_api_client/models/api_models.dart';

class ResolvedAliasFilterResult {
  List<EntityInfo> entities;
  bool stateEntity;
  String entityParamName;

  ResolvedAliasFilterResult({this.entities, this.stateEntity, this.entityParamName});
}

class EntityInfo {
  BaseEntity origEntity;
  String name;
  String label;
  String entityType;
  String id;
  String entityDescription;

  EntityInfo({this.origEntity, this.name, this.label, this.entityType, this.id, this.entityDescription});
}

class AliasInfo {
  dynamic alias;

  bool stateEntity;
  String entityParamName;
  bool resolveMultiple;
  List<EntityInfo> resolvedEntities;
  dynamic currentEntity;

  AliasInfo({this.alias, this.stateEntity, this.entityParamName, this.resolvedEntities, this.currentEntity, this.resolveMultiple});
}

class SearchQuery {
  String rootId;
  String rootType;
  var direction;
  var fetchLastLevelOnly;
  var filters;
  double maxLevel;

  SearchQuery({this.rootId, this.rootType, this.direction, this.fetchLastLevelOnly, this.filters, this.maxLevel});
}
