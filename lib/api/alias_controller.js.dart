import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:ndu_api_client/assets_api.dart';
import 'package:ndu_api_client/device_api.dart';
import 'package:ndu_api_client/entity_view_api.dart';
import 'package:ndu_api_client/models/api_models.dart';
import 'package:ndu_api_client/models/assets.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/find_by_query_body.dart';
import 'package:ndu_api_client/models/page_base_model.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/alias_models.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/state_controller.dart';
import 'package:synchronized/synchronized.dart';

class AliasController {
  Map<String, AliasInfo> resolvedAliases = {};
  Map<String, EntityAliases> entityAliases;
  Map<String, AliasInfo> entityAliasesFutureMap = Map();
  Map<String, Lock> aliasInfoLockMap = Map();
  StateController stateController;

  AliasController({this.stateController, this.entityAliases});

  Future<List<Datasources>> resolveDatasource(Datasources datasource, bool isSingle) async {
    if (datasource.type == "entity") {
      if (datasource.entityAliasId != null) {
        try {
          AliasInfo aliasInfo = await getAliasInfo(datasource.entityAliasId);

          datasource.aliasName = aliasInfo.alias.toString();
          if (aliasInfo.resolveMultiple && !isSingle) {
            var resolvedEntities = aliasInfo.resolvedEntities;
            if (resolvedEntities != null && resolvedEntities.length > 0) {
              List<Datasources> dataSources = List();
              for (var i = 0; i < resolvedEntities.length; i++) {
                EntityInfo resolvedEntity = resolvedEntities[i];
                Datasources newDataSource = datasource.clone();
                if (resolvedEntity.origEntity != null) {
                  newDataSource.entity = resolvedEntity.origEntity;
                } else {
                  newDataSource.entity = {};
                }
                newDataSource.entityId = resolvedEntity.id;
                newDataSource.entityType = resolvedEntity.entityType;
                newDataSource.entityName = resolvedEntity.name;
                newDataSource.entityLabel = resolvedEntity.label;
                newDataSource.entityDescription = resolvedEntity.entityDescription;
                newDataSource.name = resolvedEntity.name;
                newDataSource.generated = i > 0 ? true : false;
                dataSources.add(newDataSource);
              }

              return dataSources;
            } else {
              if (aliasInfo.stateEntity) {
                Datasources newDataSource = datasource;
                newDataSource.unresolvedStateEntity = true;
                return [newDataSource];
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
    if (!aliasInfoLockMap.containsKey(aliasId)) {
      aliasInfoLockMap[aliasId] = Lock();
    }
    return aliasInfoLockMap[aliasId].synchronized(() async {
      if (entityAliasesFutureMap.containsKey(aliasId)) {
        return entityAliasesFutureMap[aliasId];
      } else {
        if (this.entityAliases.containsKey(aliasId)) {
          var entityAlias = this.entityAliases[aliasId];
          try {
            entityAliasesFutureMap[aliasId] = await EntityService.resolveAlias(entityAlias, stateController?.getStateParams());
            return Future.value(entityAliasesFutureMap[aliasId]);
          } catch (err) {
            return Future.error(Exception(err.toString() + ' resolveAlias hatasi - 1'));
          }
        } else {
          return Future.error(Exception('$aliasId verilen aliases listesinde bulunamadi'));
        }
      }
    });
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
  }

  static Future<ResolvedAliasFilterResult> resolveAliasFilter(Filter filter, dynamic stateParams, int maxItems, bool failOnEmpty) async {
    ResolvedAliasFilterResult result = ResolvedAliasFilterResult();
    result.entities = List();
    result.stateEntity = false;
    result.entityParamName = "";
    var rootEntityType;
    var rootEntityId;
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
          break;
        case 'entityList':
          var entities = getEntities(filter.entityType, filter, null);
          if (entities != null && entities.length || !failOnEmpty) {
            result.entities = entitiesToEntitiesInfo(entities);
          } else {
            throw Exception("entityList hatası.");
          }
          break;
        case 'entityName':
          PageBaseModel entities =
              await getEntitiesByNameFilter(filter.entityType, filter.entityNameFilter, maxItems, {'ignoreLoading': true}, filter.deviceType);
          if (entities != null && entities.data.length > 0) {
            result.entities = entitiesToEntitiesInfo(entities.data);
          } else {
            throw Exception("Device listesi boş geldi.");
          }
          break;
        case 'stateEntity':
          result.stateEntity = true;
          if (stateEntityId != null) {
            var entity = await getEntity(stateEntityId.entityType, stateEntityId.id, {'ignoreLoading': true});
            result.entities = entitiesToEntitiesInfo([entity]);
          } else {
            throw Exception("Device listesi boş geldi.");
          }
          break;
        case 'deviceType':
          PageBaseModel entities =
              await getEntitiesByNameFilter('DEVICE', filter.deviceNameFilter, maxItems, {'ignoreLoading': true}, filter.deviceType);
          if (entities != null && entities.data.length > 0) {
            result.entities = entitiesToEntitiesInfo(entities.data);
          } else {
            throw Exception("Device listesi boş geldi.");
          }
          break;
        case 'relationsQuery':
          result.stateEntity = filter.rootStateEntity;
          if (result.stateEntity != null && stateEntityId != null) {
            rootEntityType = stateEntityId.entityType;
            rootEntityId = stateEntityId.id;
          } else if (result.stateEntity != null) {
            rootEntityType = filter.rootEntity.entityType;
            rootEntityId = filter.rootEntity.id;
          }
          if (rootEntityType != null && rootEntityId != null) {
            var relationQueryRootEntityId = resolveAliasEntityId(rootEntityType, rootEntityId);
            SearchQuery searchQuery = SearchQuery(
                rootId: relationQueryRootEntityId.id,
                rootType: relationQueryRootEntityId.entityType,
                direction: filter.direction,
                fetchLastLevelOnly: filter.fetchLastLevelOnly,
                filters: filter.filters);
            searchQuery.maxLevel = filter.maxLevel != null && filter.maxLevel > 0 ? filter.maxLevel : -1;
          }

          break;
        case 'assetSearchQuery':
        case 'deviceSearchQuery':
        case 'entityViewSearchQuery':
          result.stateEntity = filter.rootStateEntity;
          if (result.stateEntity != null && stateEntityId != null) {
            rootEntityType = stateEntityId.entityType;
            rootEntityId = stateEntityId.id;
          } else if (!result.stateEntity) {
            rootEntityType = filter.rootEntity.entityType;
            rootEntityId = filter.rootEntity.id;
          }
          if (rootEntityType != null && rootEntityId != null) {
            var searchQueryRootEntityId = resolveAliasEntityId(rootEntityType, rootEntityId);
            FindByQueryBody body = FindByQueryBody(
                parameters: Parameters(
                    rootId: searchQueryRootEntityId.id,
                    rootType: searchQueryRootEntityId.entityType,
                    direction: filter.direction,
                    fetchLastLevelOnly: filter.fetchLastLevelOnly,
                    maxLevel: filter.maxLevel != null && filter.maxLevel > 0 ? filter.maxLevel : -1),
                relationType: filter.relationType);
            List<BaseEntity> list;
            if (filter.type == describeEnum(AliasFilterType.assetSearchQuery)) {
              body.assetTypes = filter.assetTypes;
              AssetsApi assetsApi = AssetsApi();
              var bodyString = json.encode(body);
              list = await assetsApi.findByQuery(bodyString);
            } else if (filter.type == describeEnum(AliasFilterType.deviceSearchQuery)) {
              body.deviceTypes = filter.deviceTypes;
              DeviceApi deviceApi = DeviceApi();
              var bodyString = json.encode(body);
              list = await deviceApi.findByQuery(bodyString);
            } else if (filter.type == describeEnum(AliasFilterType.entityViewSearchQuery)) {
              body.entityViewTypes = filter.entityViewTypes;
              EntityViewApi entityService = EntityViewApi();
              var bodyString = json.encode(body);
              list = await entityService.findByQuery(bodyString);
            }
            if (list.length > 0) {
              result.entities = entitiesToEntitiesInfo(list);
            }
            print('${result.entities}');
          }
          break;
        case 'entityViewType':
          PageBaseModel model =
              await getEntitiesByNameFilter(rootEntityType, filter.entityViewNameFilter, maxItems, {"ignoreLoading": true}, filter.entityViewType);
          result.entities = entitiesToEntitiesInfo(model.data);
          break;
        case 'assetType':
          PageBaseModel model =
              await getEntitiesByNameFilter(rootEntityType, filter.assetNameFilter, maxItems, {"ignoreLoading": true}, filter.assetType);
          result.entities = entitiesToEntitiesInfo(model.data);
          break;
      }
      return result;
    } catch (err) {
      print(err);
      throw Exception(err.toString());
    }
  }

  static Future<List<EntityInfo>> entityRelationInfosToEntitiesInfo(List<dynamic> entityRelations, String direction) async {
    List<EntityInfo> entitiesInfoTaks = List();
    if (entityRelations != null) {
      for (int i = 0; i < entityRelations.length; i++) {
        EntityInfo entityInfo = await entityRelationInfoToEntityInfo(entityRelations[i], direction);
        entitiesInfoTaks.add(entityInfo);
      }
    }
    print('${entitiesInfoTaks.toString()}');
    return entitiesInfoTaks;
  }

  static Future<EntityInfo> entityRelationInfoToEntityInfo(var entityRelationInfo, String direction) async {
// var entityId = (direction == describeEnum(EntitySearchDirection.FROM)) ? entityRelationInfo.to : entityRelationInfo.from;

    var entity = await getEntity(entityRelationInfo["id"]["entityType"], entityRelationInfo["id"]["id"], true);
    return entityToEntityInfo(entity);
  }

  static dynamic getEntities(String entityType, entityIds, config) {
    var result;
    switch (entityType) {
      case "DEVICE":
        DeviceApi deviceApi = DeviceApi();
        result = deviceApi.getDeviceIds(entityType, entityIds);
        break;
      case "ASSET":
        AssetsApi assetsApi = AssetsApi();
        result = assetsApi.getAsset(entityIds);
        break;
      case "ENTITY_VIEW":
      case "TENANT":
      case "CUSTOMER":
      case "DASHBOARD":
      case "USER":
      case "ALARM":
    }

    return result;
  }

  static EntityId getStateEntityInfo(Filter filter, dynamic stateParams) {
    EntityId entityId;
//TODO - JS KODU
    if (stateParams != null) {
      if (filter.stateEntityParamName != null && filter.stateEntityParamName.length > 0) {
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
      entityId = resolveAliasEntityId(entityId.entityType, entityId.id);
    }

    return entityId;
  }

  static Future<PageBaseModel> getEntitiesByNameFilter(String entityType, String entityNameFilter, int limit, Map config, String subType) async {
    try {
      PageLink pageLink = PageLink(limit: limit, textSearch: entityNameFilter);
      if (limit == -1 || limit == 0) {
        pageLink.limit = 100;
      } else {}

      PageBaseModel result = await getEntitiesByPageLinkPromise(entityType, pageLink, config, subType);

      return result;
    } catch (err) {
      throw Exception(err);
    }
  }

  static Future<PageBaseModel> getEntitiesByPageLinkPromise(String entityType, PageLink pageLink, Map config, String subType) async {
    switch (entityType) {
      case "DEVICE":
        DeviceApi _deviceApi = DeviceApi();
        PageBaseModel result = await _deviceApi.getDevices(pageLink, type: subType);
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
      case "TENANT":
        break;
      case "CUSTOMER":
        break;
      case "RULE_CHAIN":
        break;
      case "DASHBOARD":
        break;
      case "USER":
        break;
      default:
        throw Exception("$entityType caselerde bulunamadı.");
        break;
    }
    throw Exception("$entityType caselerde bulunamadı.");
  }

  void getSingleTenantByPageLinkPromise() {}

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
        try {
          AssetsApi assetApi = AssetsApi();
          Assets assets = await assetApi.getAsset(entityId);
          return assets;
        } catch (err) {
          throw Exception(err.toString());
        }
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
