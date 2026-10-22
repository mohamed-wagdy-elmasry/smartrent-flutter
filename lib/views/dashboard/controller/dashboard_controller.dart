import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/views/dashboard/model/area_has_type_model.dart';
import 'package:carbo/views/dashboard/model/car_area_model.dart';
import 'package:carbo/views/dashboard/model/type_has_model.dart';
import '../model/model_has_years.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:carbo/base/widgets/logger.dart';
import 'package:carbo/base/utils/local_storage.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../model/car_info_model.dart';
import '../model/dashboard_info_model.dart';

final log = logger(DashboardController);

class DashboardController extends GetxController {
  final List<String> carType = [];

  RxInt currentIndex = 0.obs;
  RxString selectedDate = ''.obs;
  RxString selectedTime = ''.obs;
  RxString userFullName = ''.obs;
  RxString userEmail = ''.obs;
  RxString userName = ''.obs;
  RxString userDefaultImageUrl = ''.obs;
  RxString userProfileImage = ''.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;
  var selectedCarIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (LocalStorage.isLoggedIn) {
      getDashboardInfo();
    }
  }

  void clearData() {
    cars.clear();
    selectedTime.value = '';
    selectedDate.value = '';
  }

  // Get Dashboard Info
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  late DashboardInfoModel _dashboardInfoModel;

  DashboardInfoModel get dashboardInfoModel => _dashboardInfoModel;

  Future<DashboardInfoModel?> getDashboardInfo() async {
    return RequestProcess().request<DashboardInfoModel>(
      fromJson: DashboardInfoModel.fromJson,
      apiEndpoint: ApiEndpoint.dashboardInfo,
      isLoading: _isLoading,
      showErrorMessage: false,
      onSuccess: (value) {
        _dashboardInfoModel = value!;
        // Update LocalStorage with latest KYC status from server
        final kycStatus = _dashboardInfoModel.data.userInfo.kycVerified;
        LocalStorage.save(
          kycStatus: kycStatus,
          isKycVerified: kycStatus == 1,
        );
        _getDashboardInfo();
        typeList.clear();
        getAllTypes(); // Fetch all types directly
      },
    );
  }

  void _getDashboardInfo() {
    var baseUrl = _dashboardInfoModel.data.profileImagePaths.baseUrl;
    var path = _dashboardInfoModel.data.profileImagePaths.pathLocation;
    var img = _dashboardInfoModel.data.userInfo.image;
    var defaultImg = _dashboardInfoModel.data.profileImagePaths.defaultImage;
    userProfileImage.value = '${baseUrl}/$path/$img';
    userDefaultImageUrl.value = '${baseUrl}/$defaultImg';
    userFullName.value = _dashboardInfoModel.data.userInfo.fullname;
    userEmail.value = _dashboardInfoModel.data.userInfo.email;
  }

  //// GET ARE - - - - - - - - - - - - - - - - - (DEPRECATED - Keeping for backwards compatibility)
  Rxn<Datum> selectedArea = Rxn<Datum>();
  final List<Datum> areaList = [];

  RxInt areaId = 0.obs;
  RxString selectArea = ''.obs;

  late CarAreaModel _carAreaModel;

  CarAreaModel get carAreaModel => _carAreaModel;

  Future<CarAreaModel?> getArea() async {
    return RequestProcess().request<CarAreaModel>(
      fromJson: CarAreaModel.fromJson,
      apiEndpoint: ApiEndpoint.getArea,
      isLoading: _isLoading,
      showErrorMessage: false,
      onSuccess: (value) {
        _carAreaModel = value!;
        selectArea.value = _carAreaModel.data.first.name;
        _carAreaModel.data.forEach((v) {
          areaList.add(
            Datum(
              name: v.name,
              status: v.status,
              createdAt: v.createdAt,
              id: v.id,
              lastEditBy: v.lastEditBy,
              slug: v.slug,
              updatedAt: v.updatedAt,
            ),
          );
        });
      },
    );
  }

  // GET ALL TYPES - Fetch all car types without area filter
  RxInt carTypeId = 0.obs;
  RxString alis = RxString(Strings.SelectType);
  RxString selectedModelName = RxString(Strings.SelectModel);

  Rxn<TypesAll> selectType = Rxn<TypesAll>();
  final List<TypesAll> typeList = [];

  final _isLoad = false.obs;

  bool get isLoad => _isLoad.value;

  late AreaHasTypeModel _allTypesModel;

  AreaHasTypeModel get allTypesModel => _allTypesModel;

  // Fetch all types directly without area dependency
  Future<void> getAllTypes() async {
    // Some backends return a plain List for /user/car-booking/type.
    // The generic RequestProcess expects a Map and will throw when
    // a List is returned. Here we call the endpoint directly and
    // handle both List and Map responses.
    try {
      _isLoad.value = true;
      typeList.clear();

      final url = ApiEndpoint.getAllTypes.url();
      // Use a direct http call to avoid ApiMethod's strict Map return type
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${LocalStorage.token}',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        log.i('getAllTypes response type: ${decoded.runtimeType}');

        // Debug: log top-level keys/summary to help diagnose mixed-type responses
        try {
          if (decoded is Map) {
            log.d('getAllTypes decoded keys: ${decoded.keys.toList()}');
          } else if (decoded is List) {
            log.d('getAllTypes decoded is List of length: ${decoded.length}');
          }
        } catch (_) {}

        // Find a List within the response to use as our types list
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          // Common shapes:
          // { data: { area: { typesAll: [...] } } }
          // { data: [...] }
          // { typesAll: [...] }
          try {
            if (decoded['data'] is Map &&
                decoded['data']['area'] is Map &&
                decoded['data']['area']['typesAll'] is List) {
              list = decoded['data']['area']['typesAll'];
            } else if (decoded['data'] is List) {
              list = decoded['data'];
            } else if (decoded['typesAll'] is List) {
              list = decoded['typesAll'];
            } else {
              // Fallback: pick the first List found in values
              for (var v in decoded.values) {
                if (v is List) {
                  list = v;
                  break;
                }
              }
            }
          } catch (e) {
            log.e('Failed to detect types list in response: $e');
          }
        }

        if (list.isEmpty) {
          log.w('No types list found in getAllTypes response');
        } else {
          // Debug: log first few items' runtime types to detect unexpected shapes
          try {
            log.d('getAllTypes detected list length: ${list.length}');
            if (list.isNotEmpty) {
              final preview = list.take(3).map((e) => e.runtimeType).toList();
              log.d('getAllTypes list item types (first 3): $preview');
              // If first item is printable, log a truncated JSON of it
              final first = list.first;
              if (first is Map || first is List || first is String) {
                final s = first is String ? first : jsonEncode(first);
                log.d(
                  'getAllTypes first item (truncated): ${s.length > 1000 ? s.substring(0, 1000) : s}',
                );
              }
            }
          } catch (_) {}
        }

        for (var item in list) {
          if (item is! Map) continue;
          try {
            final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
            final name = item['name']?.toString() ?? '';
            DateTime createdAt;
            if (item['created_at'] != null) {
              createdAt =
                  DateTime.tryParse(item['created_at'].toString()) ??
                  DateTime.now();
            } else if (item['createdAt'] != null) {
              createdAt =
                  DateTime.tryParse(item['createdAt'].toString()) ??
                  DateTime.now();
            } else {
              createdAt = DateTime.now();
            }

            dynamic updatedAtRaw = item['updated_at'] ?? item['updatedAt'];
            dynamic updatedAt;
            if (updatedAtRaw != null) {
              updatedAt =
                  DateTime.tryParse(updatedAtRaw.toString()) ?? updatedAtRaw;
            } else {
              updatedAt = null;
            }

            final carTypeIdVal =
                int.tryParse(item['car_type_id']?.toString() ?? '') ?? id;
            final carAreaIdVal =
                int.tryParse(item['car_area_id']?.toString() ?? '') ?? 0;

            typeList.add(
              TypesAll(
                name: name,
                id: id,
                updatedAt: updatedAt,
                createdAt: createdAt,
                type: item['type'] is Map ? item['type'] : null,
                carTypeId: carTypeIdVal,
                carAreaId: carAreaIdVal,
              ),
            );
          } catch (e) {
            log.e('Error parsing type item safely: $e');
            continue;
          }
        }
      } else {
        log.e('Failed to fetch types: ${response.statusCode}');
      }
    } catch (e) {
      log.e('getAllTypes error: $e');
    } finally {
      _isLoad.value = false;
    }
  }

  // AREA HAS TYPE POST - (DEPRECATED - Kept for backwards compatibility)
  late AreaHasTypeModel _areaHasTypeModel;

  AreaHasTypeModel get areaHasTypeModel => _areaHasTypeModel;

  Future<AreaHasTypeModel?> areaHasType() async {
    Map<String, dynamic> inputBody = {'area': areaId.value.toString()};
    return RequestProcess().request<AreaHasTypeModel>(
      fromJson: AreaHasTypeModel.fromJson,
      apiEndpoint: ApiEndpoint.postAreaHasType,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        _areaHasTypeModel = value!;
        _areaHasTypeModel.data.area.typesAll?.forEach((v) {
          typeList.add(
            TypesAll(
              name: v.type?.name,
              id: v.id,
              updatedAt: v.updatedAt,
              createdAt: v.createdAt,
              type: v.type,
              carTypeId: v.carTypeId,
              carAreaId: v.carAreaId,
            ),
          );
        });
      },
    );
  }

  // TYPE HAS MODEL POST - - - - - - - - - - - - - - - - -
  Rxn<ModelsAll> selectModel = Rxn<ModelsAll>();
  final List<ModelsAll> modelList = [];

  // Model years
  final List<String> modelYearsList = [];
  RxString selectedYearName = RxString(Strings.SelectYear);
  RxnInt selectedYear = RxnInt();
  RxInt carModelId = 0.obs;
  RxInt carYear = 0.obs;

  late TypeHasModelModel _typeHasModelModel;

  TypeHasModelModel get typeHasModelModel => _typeHasModelModel;

  Future<TypeHasModelModel?> typeHasModel() async {
    Map<String, dynamic> inputBody = {'type': carTypeId.value.toString()};
    return RequestProcess().request<TypeHasModelModel>(
      fromJson: TypeHasModelModel.fromJson,
      apiEndpoint: ApiEndpoint.postTypeHasModel,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        _typeHasModelModel = value!;
        // API returns models under data.type.models
        _typeHasModelModel.data.type.models?.forEach((v) {
          modelList.add(
            ModelsAll(
              id: v.id,
              carTypeId: v.carTypeId,
              slug: v.slug,
              name: v.name,
              status: v.status,
              lastEditBy: v.lastEditBy,
              createdAt: v.createdAt,
              updatedAt: v.updatedAt,
            ),
          );
        });
        // reset selected model title to default after fetching
        selectedModelName.value = Strings.SelectModel;
        // clear years when models are fetched
        modelYearsList.clear();
        selectedYearName.value = Strings.SelectYear;
        selectedYear.value = null;
      },
    );
  }

  Future<ModelHasYearsModel?> modelHasYears() async {
    // Ensure both car type and model are selected before requesting years
    if (selectModel.value == null || carTypeId.value == 0) return null;
    Map<String, dynamic> inputBody = {
      'type': carTypeId.value.toString(),
      'model': selectModel.value!.id.toString(),
    };
    return RequestProcess().request<ModelHasYearsModel>(
      fromJson: ModelHasYearsModel.fromJson,
      apiEndpoint: ApiEndpoint.postModelHasYears,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        var res = value!;
        modelYearsList.clear();
        res.data.years.forEach((y) {
          modelYearsList.add(y.toString());
        });
        // reset selected year label
        selectedYearName.value = Strings.SelectYear;
        selectedYear.value = null;
      },
    );
  }

  // Model Has Years

  // =  SEARCH CAR API

  var cars = <Car>[].obs;
  RxString carImgUrl = ''.obs;
  final _isSearchingCar = false.obs;

  bool get isSearchingCar => _isSearchingCar.value;

  late CarInfoModel _carInfoModel;

  CarInfoModel get carInfoModel => _carInfoModel;

  Future<CarInfoModel?> searchAllCar() async {
    cars.clear();
    Map<String, dynamic> inputBody = {
      // 'car_area': areaId.value, // Remove area requirement
      'car_type': carTypeId.value,
      'car_model': carModelId.value,
      'car_year': carYear.value,
      'pickup_time': selectedTime.value,
      'pickup_date': selectedDate.value,
    };
    return RequestProcess().request<CarInfoModel>(
      fromJson: CarInfoModel.fromJson,
      apiEndpoint: ApiEndpoint.searchCar,
      isLoading: _isSearchingCar,
      method: HttpMethod.POST,
      body: inputBody,
      showResult: true,
      onSuccess: (value) {
        _carInfoModel = value!;
        carToken.value = _carInfoModel.data.token;

        carImgUrl.value =
            '${_carInfoModel.data.dataPath.baseUrl}/${_carInfoModel.data.dataPath.imagePath}/';
        _carInfoModel.data.cars.forEach((element) {
          cars.add(
            Car(
              carAreaId: element.carAreaId,
              id: element.id,
              carTypeId: element.carTypeId,
              // carNumber: element.carNumber,
              slug: element.slug,
              status: element.status,
              fees: element.fees,
              image: element.image,
              approval: element.approval,
              carModel: element.carModel,
              carType: element.carType,
              carYear: element.carYear,
              createdAt: element.createdAt,
              // experience: element.experience,
              seat: element.seat,
              updatedAt: element.updatedAt,
              vendorId: element.vendorId,
              carTitle: element.carTitle,
            ),
          );
        });
        if (cars.isEmpty) {
          CustomSnackBar.error(
            DynamicLanguage.isLoading
                ? ""
                : DynamicLanguage.key(Strings.noCarFindMessage),
          );
        }
      },
    );
  }
}
