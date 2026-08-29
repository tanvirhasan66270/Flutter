import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/address_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class AddressRepository {
  AddressRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<List<Country>> getCountries() async {
    final response = await _dio.get(ApiConstants.country);
    final List data = response.data ?? [];
    return data.map((e) => Country.fromJson(e)).toList();
  }

  Future<List<Division>> getDivisionsByCountryId(int countryId) async {
    final response = await _dio.get(ApiConstants.divisionsByCountry(countryId));
    final List data = response.data ?? [];
    return data.map((e) => Division.fromJson(e)).toList();
  }

  Future<List<District>> getDistrictsByDivisionId(int divisionId) async {
    final response = await _dio.get(ApiConstants.districtsByDivision(divisionId));
    final List data = response.data ?? [];
    return data.map((e) => District.fromJson(e)).toList();
  }

  Future<List<PoliceStation>> getPoliceStationsByDistrictId(int districtId) async {
    final response = await _dio.get(ApiConstants.policeStationsByDistrict(districtId));
    final List data = response.data ?? [];
    return data.map((e) => PoliceStation.fromJson(e)).toList();
  }

  Future<PoliceStation> getPoliceStationById(int id) async {
    final response = await _dio.get('policeStation/$id');
    return PoliceStation.fromJson(response.data);
  }

  Future<District> getDistrictById(int id) async {
    final response = await _dio.get('district/getById/$id');
    return District.fromJson(response.data);
  }

  Future<Division> getDivisionById(int id) async {
    final response = await _dio.get('division/getById/$id');
    return Division.fromJson(response.data);
  }
}
