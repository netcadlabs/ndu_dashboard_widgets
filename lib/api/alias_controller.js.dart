import 'dart:async';

import 'package:ndu_api_client/device_api.dart';
import 'package:ndu_api_client/models/api_models.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';

class AliasController {
  Map resolvedAliases = {};
  Map<String, EntityAliases> entityAliases;

  AliasController({this.entityAliases});


  Future<List<Datasources>> resolveDatasource(Datasources datasource, bool isSingle) {
    if (datasource.type == "entity") {
      if (datasource.entityAliasId != null) {
        getAliasInfo(datasource.entityAliasId).then((aliasInfo) {
          datasource.aliasName = aliasInfo.alias.toString();
          if (aliasInfo.resolveMultiple && !isSingle) {
            Datasources newDatasource;
            var resolvedEntities = aliasInfo.resolvedEntities;
            if (resolvedEntities != null && resolvedEntities.length > 0) {
              List<Datasources> datasources = List();

              for (var i = 0; i < datasources.length; i++) {
                var resolvedEntity = resolvedEntities[i];
                newDatasource = datasource;
                if (resolvedEntity.origEntity) {
                  newDatasource.entity = resolvedEntity.origEntity;
                } else {
                  newDatasource.entity = {};
                }
                newDatasource.entityId = resolvedEntity.id;
                newDatasource.entityType = resolvedEntity.entityType;
                newDatasource.entityName = resolvedEntity.name;
                newDatasource.entityLabel = resolvedEntity.label;
                newDatasource.entityDescription = resolvedEntity.entityDescription;
                newDatasource.name = resolvedEntity.name;
                newDatasource.generated = i > 0 ? true : false;
                datasources.add(newDatasource);
              }

              return Future.value(datasources);
            } else {
              if (aliasInfo.stateEntity) {
                newDatasource = datasource;
                newDatasource.unresolvedStateEntity = true;
                return Future.value([newDatasource]);
              }
              else {
                Future.error('resolveDatasource error - 3');
              }
            }
          } else {
            var entity = aliasInfo.currentEntity;
            if (entity != null) {
              if (entity.origEntity) {
                datasource.entity = entity.origEntity;
              } else {
                datasource.entity = {};
              }
              datasource.entityId = entity.id;
              datasource.entityType = entity.entityType;
              datasource.entityName = entity.name;
              datasource.entityLabel = entity.label;
              datasource.name = entity.name;
              datasource.entityDescription = entity.entityDescription;
              return Future.value([datasource]);
            } else {
              if (aliasInfo.stateEntity) {
                datasource.unresolvedStateEntity = true;
                return Future.value([datasource]);
              } else {
                Future.error('resolveDatasource error - 1');
              }
            }
          }
        }).catchError((err) {
          print(err);
          Future.error('resolveDatasource error - 2');
        });
      } else {
        datasource.aliasName = datasource.entityName;
        datasource.name = datasource.entityName;
        return Future.value([datasource]);
      }
    } else {
      return Future.value([datasource]);
    }
  }

  Future<AliasInfo> getAliasInfo(String aliasId) async {
    var aliasInfo = this.resolvedAliases[aliasId];
    if (aliasInfo) {
      return Future.value(aliasInfo);
    }

    if (this.entityAliases.containsKey(aliasId)) {
      var entityAlias = this.entityAliases[aliasId];
      EntityService.resolveAlias(entityAlias, null).then((aliasInfo) {
        resolvedAliases[aliasId] = aliasInfo;

        // TODO - JS KODU
        // if (aliasInfo.stateEntity) {
        // var stateEntityInfo = {
        //   entityParamName: aliasInfo.entityParamName,
        //   entityId: aliasCtrl.stateController.getEntityId(aliasInfo.entityParamName)
        // };
        // aliasCtrl.resolvedAliasesToStateEntities[aliasId] = stateEntityInfo;
        // }

        return Future.value(aliasInfo);
      }).catchError((onError) {
        return Future.error('resolveAlias hatasi - 1');
      });
    } else {
      return Future.error('$aliasId verilen aliases listesinde bulunamadi');
    }
  }
}

class EntityService {

  static Future<AliasInfo> resolveAlias(EntityAliases entityAlias, dynamic stateParams) {
    var filter = entityAlias.filter;

    resolveAliasFilter(filter, stateParams, -1, false).then((result) {
      AliasInfo aliasInfo = AliasInfo(
          alias: entityAlias.alias,
          stateEntity: result.stateEntity,
          entityParamName: result.entityParamName,
          resolveMultiple: filter.resolveMultiple,
          resolvedEntities: result.entities,
          currentEntity: null
      );

      if (aliasInfo.resolvedEntities.length > 0) {
        aliasInfo.currentEntity = aliasInfo.resolvedEntities[0];
      }

      Future.value(aliasInfo);
    }).catchError((onError) {
      return Future.error('resolveAlias hata');
    });
  }

  static Future<ResolvedAliasFilterResult> resolveAliasFilter(Filter filter, dynamic stateParams, int maxItems,
      bool failOnEmpty) {
    ResolvedAliasFilterResult result = ResolvedAliasFilterResult();
    result.entities = List();
    result.stateEntity = false;
    result.entityParamName = "";

    EntityId stateEntityId = getStateEntityInfo(filter, stateParams);
    if (filter.stateEntityParamName != null) {
      result.entityParamName = filter.stateEntityParamName;
    }

    switch (filter.type) {
      case 'singleEntity':
        EntityId aliasEntityId = resolveAliasEntityId(filter.singleEntity.entityType, filter.singleEntity.id);
        getEntity(aliasEntityId.entityType, aliasEntityId.id, null).then((entity) {
          result.entities = entitiesToEntitiesInfo([entity]);
          return Future.value(result);
        }).catchError((err) {
          print(err);
          return Future.error('singleEntity resolve edilemedi : ${aliasEntityId.id} ');
        });
        break;
      case 'entityList':
        break;

      case 'entityName':
        break;

      case 'stateEntity':
        break;

      case 'assetType':
        break;

      case 'deviceType':
        break;

      case 'entityViewType':
        break;

      case 'relationsQuery':
        break;

      case 'assetSearchQuery':
      case 'deviceSearchQuery':
      case 'entityViewSearchQuery':
        break;
    }

    return Future.error('${filter.type}  desteklenmiyor!');
  }

  static EntityId getStateEntityInfo(Filter filter, dynamic stateParams) {
    EntityId entityId;
    //TODO - JS KODU
    // if (stateParams) {
    //   if (filter.stateEntityParamName && filter.stateEntityParamName.length) {
    //     if (stateParams[filter.stateEntityParamName]) {
    //       entityId = stateParams[filter.stateEntityParamName].entityId;
    //     }
    //   } else {
    //     entityId = stateParams.entityId;
    //   }
    // }
    if (entityId == null) {
      entityId = filter.defaultStateEntity;
    }
    if (entityId != null) {
      entityId = resolveAliasEntityId(entityId.entityType, entityId.id);
    }

    return entityId;
  }

  static EntityId resolveAliasEntityId(String entityType, String id) {
    //TODO - JS KODU
    // if (entityType == types.aliasEntityType.current_customer) {
    //   var user = userService.getCurrentUser();
    //   entityId.entityType = types.entityType.customer;
    //   if (user.authority === 'CUSTOMER_USER') {
    //     entityId.id = user.customerId;
    //   }
    // }
    return EntityId(id: id, entityType: entityType);
  }

  List<EntityInfo> entitiesToEntitiesInfo(List<BaseEntity> entities) {
    var entitiesInfo = [];
    if (entities != null) {
      for (var d = 0; d < entities.length; d++) {
        entitiesInfo.add(entityToEntityInfo(entities[d]));
      }
    }
    return entitiesInfo;
  }

  static EntityInfo entityToEntityInfo(BaseEntity entity) {
    EntityInfo entityInfo = EntityInfo();

    entityInfo.origEntity = entity;
    entityInfo.name = entity.name;
    entityInfo.label = entity.label;
    entityInfo.entityType = entity.id.entityType;
    entityInfo.id = entity.id.id;
    entityInfo.entityDescription = entityInfo.entityDescription;

    return entityInfo;
  }

  static Future<BaseEntity> getEntity(String entityType, String entityId, dynamic config) {
    return getEntityPromise(entityType, entityId, config);
  }

  static Future<BaseEntity> getEntityPromise(String entityType, String entityId, dynamic config) {
    var promise;
    switch (entityType) {
      case "DEVICE":
        DeviceApi deviceApi = DeviceApi();
        return deviceApi.getDevice(entityId);
        break;
      case "ASSET":
      //TODO
      // AssetApi assetApi = AssetApi();
      // promise = assetApi.getAsset(entityId, true, config);
        break;
    //TODO
    // case types.entityType.entityView:
    //   promise = entityViewService.getEntityView(entityId, true, config);
    //   break;
    // case types.entityType.tenant:
    //   promise = tenantService.getTenant(entityId, config);
    //   break;
    // case types.entityType.customer:
    //   promise = customerService.getCustomer(entityId, config);
    //   break;
    // case types.entityType.dashboard:
    //   promise = dashboardService.getDashboardInfo(entityId, config);
    //   break;
    // case types.entityType.user:
    //   promise = userService.getUser(entityId, true, config);
    //   break;
    // case types.entityType.rulechain:
    //   promise = ruleChainService.getRuleChain(entityId, config);
    //   break;
    // case types.entityType.alarm:
    //   $log.error('Get Alarm Entity is not implemented!');
    //   break;
      default:
        Future.error('entitiy type desteklenmiyor : $entityType');
        break;
    }
    return promise;
  }

}


class ResolvedAliasFilterResult {
  List<dynamic> entities;
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
  List<dynamic> resolvedEntities;
  dynamic currentEntity;

  AliasInfo({
    this.alias,
    this.stateEntity,
    this.entityParamName,
    this.resolvedEntities,
    this.currentEntity,
    this.resolveMultiple
  });
}

class EntityId {
  String id;
  String entityType;

  EntityId({this.id, this.entityType});
}