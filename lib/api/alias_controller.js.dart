import 'dart:async';

import 'package:ndu_api_client/assets_api.dart';
import 'package:ndu_api_client/device_api.dart';
import 'package:ndu_api_client/models/api_models.dart';
import 'package:ndu_api_client/models/assets.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/page_base_model.dart';
import 'package:ndu_api_client/util/constants.dart';

class AliasController {
  Map<String, AliasInfo> resolvedAliases = {};
  Map<String, EntityAliases> entityAliases;

  AliasController({this.entityAliases});

  Future<List<Datasources>> resolveDatasource(Datasources datasource, bool isSingle) async {
    if (datasource.type == "entity") {
      if (datasource.entityAliasId != null) {
        // try{
        //
        // }catch(err){
        //   throw Exception(err.toString());
        // }

        try {
          AliasInfo aliasInfo = await getAliasInfo(datasource.entityAliasId);

          datasource.aliasName = aliasInfo.alias.toString();
          if (aliasInfo.resolveMultiple && !isSingle) {
            Datasources newDatasource;
            var resolvedEntities = aliasInfo.resolvedEntities;
            if (resolvedEntities != null && resolvedEntities.length > 0) {
              List<Datasources> datasources = List();

              for (var i = 0; i < datasources.length; i++) {
                EntityInfo resolvedEntity = resolvedEntities[i];
                newDatasource = datasource;
                if (resolvedEntity.origEntity != null) {
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

              return datasources;
            } else {
              if (aliasInfo.stateEntity) {
                newDatasource = datasource;
                newDatasource.unresolvedStateEntity = true;
                return [newDatasource];
              } else {
                // Future.error('resolveDatasource error - 3');
                throw Exception('resolveDatasource error - 3');
              }
            }
          } else {
            var entity = aliasInfo.currentEntity;
            if (entity != null) {
              if (entity.origEntity != null) {
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
              return [datasource];
            } else {
              if (aliasInfo.stateEntity != null) {
                datasource.unresolvedStateEntity = true;
                return [datasource];
              } else {
                // Future.error('resolveDatasource error - 1');
                throw Exception('resolveDatasource error - 1');
              }
            }
          }
        } catch (err) {
          print(err);
          throw Exception(err.toString());
        }

        // ).catchError((err) {
        //   print(err);
        //   Future.error('resolveDatasource error - 2');
        // });
      } else {
        datasource.aliasName = datasource.entityName;
        datasource.name = datasource.entityName;
        return [datasource];
      }
    } else {
      return [datasource];
    }
  }

  Future<AliasInfo> getAliasInfo(String aliasId) async {
    // AliasInfo aliasInfo = this.resolvedAliases[aliasId];
    if (resolvedAliases.containsKey(aliasId)) {
      return resolvedAliases[aliasId];
    }

    if (this.entityAliases.containsKey(aliasId)) {
      var entityAlias = this.entityAliases[aliasId];

      try {
        AliasInfo aliasInfo = await EntityService.resolveAlias(entityAlias, null);
        resolvedAliases[aliasId] = aliasInfo;

        return aliasInfo;
      } catch (err) {
        throw Exception(err.toString() + ' resolveAlias hatasi - 1');
      }

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
        // return Future.error('resolveAlias hatasi - 1');
        throw Exception('resolveAlias hatasi - 1');
      });
    } else {
      // return Future.error('$aliasId verilen aliases listesinde bulunamadi');
      throw Exception('$aliasId verilen aliases listesinde bulunamadi');
    }
  }
}

class EntityService {
  static Future<AliasInfo> resolveAlias(EntityAliases entityAlias, dynamic stateParams) async {
    var filter = entityAlias.filter;

    try {
      ResolvedAliasFilterResult result = await resolveAliasFilter(filter, stateParams, -1, false);

      AliasInfo aliasInfo = AliasInfo(
          alias: entityAlias.alias,
          stateEntity: result.stateEntity,
          entityParamName: result.entityParamName,
          resolveMultiple: filter.resolveMultiple,
          resolvedEntities: result.entities,
          currentEntity: null);

      if (aliasInfo.resolvedEntities.length > 0) {
        aliasInfo.currentEntity = aliasInfo.resolvedEntities[0];
      }

      return aliasInfo;
    } catch (err) {
      throw Exception('${err.toString()} resolveAlias hata');
    }

    // resolveAliasFilter(filter, stateParams, -1, false).then((result) {
    //   AliasInfo aliasInfo = AliasInfo(
    //       alias: entityAlias.alias,
    //       stateEntity: result.stateEntity,
    //       entityParamName: result.entityParamName,
    //       resolveMultiple: filter.resolveMultiple,
    //       resolvedEntities: result.entities,
    //       currentEntity: null);
    //
    //   if (aliasInfo.resolvedEntities.length > 0) {
    //     aliasInfo.currentEntity = aliasInfo.resolvedEntities[0];
    //   }
    //
    //   Future.value(aliasInfo);
    // }).catchError((onError) {
    //   return Future.error('resolveAlias hata');
    // });
  }

  static Future<ResolvedAliasFilterResult> resolveAliasFilter(Filter filter, dynamic stateParams, int maxItems,
      bool failOnEmpty) async {
    ResolvedAliasFilterResult result = ResolvedAliasFilterResult();
    result.entities = List();
    result.stateEntity = false;
    result.entityParamName = "";

    EntityId stateEntityId = getStateEntityInfo(filter, stateParams);
    if (filter.stateEntityParamName != null) {
      result.entityParamName = filter.stateEntityParamName;
    }
    try {
      switch (filter.type) {
        case 'singleEntity':
          EntityId aliasEntityId = resolveAliasEntityId(filter.singleEntity.entityType, filter.singleEntity.id);
          var entity = await getEntity(aliasEntityId.entityType, aliasEntityId.id, null);
          result.entities = entitiesToEntitiesInfo([entity]);
          return result;

          getEntity(aliasEntityId.entityType, aliasEntityId.id, null).then((entity) {
            result.entities = entitiesToEntitiesInfo([entity]);
            return Future.value(result);
          }).catchError((err) {
            print(err);
            return Future.error('singleEntity resolve edilemedi : ${aliasEntityId.id} ');
          });
          break;
        case 'entityList':
          var entities = getEntities(filter.entityType, filter, null);
          if (entities != null && entities.length || !failOnEmpty) {
            result.entities = entitiesToEntitiesInfo(entities);
          } else {

          }
          break;

        case 'entityName':
          PageBaseModel entities =
          await getEntitiesByNameFilter(filter.entityType, filter.entityNameFilter, maxItems, ignoreLoading: true);
          if (entities != null && entities.data.length > 0) {
            result.entities = entitiesToEntitiesInfo(entities.data);
            return result;
          } else {
            throw Exception("Device listesi boş geldi.");
          }
          break;

        case 'stateEntity':
          result.stateEntity = true;
          if (stateEntityId != null) {
            var entity = await getEntity(stateEntityId.entityType, stateEntityId.id, null);
            result.entities = entitiesToEntitiesInfo([entity]);
          } else {
            throw Exception("Device listesi boş geldi.");
          }

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
    } catch (err) {
      print(err);
      throw Exception(err.toString());
    }

    throw Exception('${filter.type}  desteklenmiyor!');
  }

  static dynamic getEntities(entityType, entityIds, config) {
    switch (entityType) {
      case "DEVICE":
        DeviceApi deviceApi = DeviceApi();
        var response = deviceApi.getDeviceIds(entityType, entityIds);
        break;
      case "Asset":
        break;
      case "types.entityType.entityView":
        break;
      case "types.entityType.tenant":
        break;
      case "types.entityType.customer":
        break;
      case "types.entityType.dashboard":
        break;
      case "types.entityType.user":
        break;
      case "types.entityType.alarm":
        break;
    }

    return null;
  }

  static EntityId getStateEntityInfo(Filter filter, dynamic stateParams) {
    EntityId entityId;
    //TODO - JS KODU
     if (stateParams!=null) {
       if (filter.stateEntityParamName!=null && filter.stateEntityParamName.length>0) {
         if (stateParams[filter.stateEntityParamName]) {
           entityId = stateParams[filter.stateEntityParamName].entityId;
         }
       } else {
         entityId = stateParams.entityId;
       }
     }
    if (entityId == null) {
      entityId = filter.defaultStateEntity;
    }

    if (entityId != null) {
      entityId = resolveAliasEntityId(filter.entityType, entityId.id);
    }

    return entityId;
  }

  static Future<PageBaseModel> getEntitiesByNameFilter(String entityType, String entityNameFilter, int limit,
      {ignoreLoading: true, subType}) async {
    try {
      PageLink pageLink = PageLink(limit: limit, textSearch: entityNameFilter);
      pageLink.limit = 100;
      PageBaseModel result = await getEntitiesByPageLinkPromise(entityType, pageLink, ignoreLoading, null);
      return result;
    } catch (err) {
      throw Exception(err);
    }
  }

  static Future<PageBaseModel> getEntitiesByPageLinkPromise(String entityType, PageLink pageLink, var config,
      String subType) async {
    switch (entityType) {
      case "DEVICE":
        DeviceApi _deviceApi = DeviceApi();
        PageBaseModel result = await _deviceApi.getDevices(pageLink);
        if (result != null && result.data.length > 0) {
          return result;
        } else {
          throw Exception("getEntitiesByPageLinkPromise liste boş geldi");
        }
        break;
      case "Asset":
        AssetsApi _assetsApi = AssetsApi();
        PageBaseModel result = await _assetsApi.getAssetList(pageLink);
        if (result != null && result.data.length > 0) {
          return result;
        } else {
          throw Exception("getEntitiesByPageLinkPromise liste boş geldi");
        }
        break;
      case "types.entityType.entityView":
        break;
      case "types.entityType.tenant":
        break;
      case "types.entityType.customer":
        break;
      case "types.entityType.rulechain":
        break;
      case "types.entityType.dashboard":
        break;
      case "types.entityType.user":
        break;
      default:
        throw Exception("$entityType caselerde bulunamadı.");
        break;
    }
    throw Exception("$entityType caselerde bulunamadı.");
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

  static List<EntityInfo> entitiesToEntitiesInfo(List<BaseEntity> entities) {
    List<EntityInfo> entitiesInfo = List();
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

  static Future<BaseEntity> getEntity(String entityType, String entityId, dynamic config) async {
    return await getEntityPromise(entityType, entityId, config);
  }

  static Future<BaseEntity> getEntityPromise(String entityType, String entityId, dynamic config) async {
    var promise;
    switch (entityType) {
      case "DEVICE":
        DeviceApi deviceApi = DeviceApi();
        try {
          Device device = await deviceApi.getDevice(entityId);
          return device;
        } catch (err) {
          throw Exception(err.toString());
          // return Future.error('device bulunamadi');
        }
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
      // Future.error('entitiy type desteklenmiyor : $entityType');
        throw Exception('entitiy type desteklenmiyor : $entityType');
        break;
    }
    return promise;
  }
}

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

  AliasInfo({this.alias,
    this.stateEntity,
    this.entityParamName,
    this.resolvedEntities,
    this.currentEntity,
    this.resolveMultiple});
}

class EntityId {
  String id;
  String entityType;

  EntityId({this.id, this.entityType});
}
