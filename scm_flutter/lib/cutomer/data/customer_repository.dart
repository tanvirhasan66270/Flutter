import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';


/// Mirrors services/customer.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class CustomerRepository {
  CustomerRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<CustomerResponseModel> create(
      CustomerRequestModel customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.post(ApiConstants.customer, data: form);
    return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CustomerResponseModel> update(
      int id,
      CustomerRequestModel customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.put(ApiConstants.customerById(id), data: form);
    return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CustomerResponseModel> findByUserId(int userId) async {
    final res = await _dio.get(ApiConstants.customerByUserId(userId));
    return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<CustomerResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.customer);
    return (res.data as List)
        .map((e) => CustomerResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> _buildForm(CustomerRequestModel customer, File? image) async {
    return FormData.fromMap({
      // Backend reads this part as a raw JSON string (@RequestPart String)
      // then parses it — mirrors `formData.append('customer', JSON.stringify(customer))`.
      'customer': jsonEncode(customer.toJson()),
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
    });
  }
}