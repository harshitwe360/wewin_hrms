import 'dart:convert';

ApiResponse apiResponseFromJson(String str) => ApiResponse.fromJson(json.decode(str));

String apiResponseToJson(ApiResponse data) => json.encode(data.toJson());

class ApiResponse {
  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
    this.metaPagination,
    this.error,
  });

  final bool status;
  final String message;
  final dynamic data;
  final Pagination? pagination;
  final MetaPagination? metaPagination;
  final dynamic error;

  ApiResponse copyWith({
    bool? status,
    String? message,
    dynamic data,
    Pagination? pagination,
    MetaPagination? metaPagination,
    dynamic error,
  }) =>
      ApiResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
        pagination: pagination ?? this.pagination,
        metaPagination: metaPagination ?? this.metaPagination,
        error: error ?? this.error,
      );

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    status: json["status"] ?? json["success"] ?? false,
    message: json["message"] == null ? "" : json["message"].toString(),
    data: json["data"] == null ? [] : (json["data"]),
    pagination: json["optional"] != null
        ? Pagination.fromJson(json["optional"]["pagination"]) : null,
    metaPagination: json["meta"] != null
        ? MetaPagination.fromJson(json["meta"]) : null,
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
    "error": error,
    "optional": {"pagination" : pagination?.toJson()},
  };
}

class Pagination {
  final int totalRecords;
  final int currentPage;
  final int limit;
  final int prePage;
  final int nextPage;
  final int leftPage;

  Pagination({
    this.totalRecords =0,
    this.currentPage = 1,
    this.limit = 10,
    this.prePage = 0,
    this.nextPage = 0,
    this.leftPage = 0,
  });

  Pagination copyWith({
    int? totalRecords,
    int? currentPage,
    int? limit,
    int? prePage,
    int? nextPage,
    int? leftPage,
  }) =>
      Pagination(
        totalRecords: totalRecords ?? this.totalRecords,
        currentPage: currentPage ?? this.currentPage,
        limit: limit ?? this.limit,
        prePage: prePage ?? this.prePage,
        nextPage: nextPage ?? this.nextPage,
        leftPage: leftPage ?? this.leftPage,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalRecords: int.tryParse(json["total_records"].toString().toUpperCase()) ?? 0,
    currentPage: int.tryParse(json["current_page"].toString()) ?? 1,
    limit: int.tryParse(json["limit"].toString()) ?? 0,
    prePage: int.tryParse(json["pre_page"].toString()) ?? 0,
    nextPage: int.tryParse(json["next_page"].toString()) ?? 0,
    leftPage: int.tryParse(json["left_page"].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "total_records": totalRecords,
    "current_page": currentPage,
    "limit": limit,
    "pre_page": prePage,
    "next_page": nextPage,
    "left_page": leftPage,
  };
}

class MetaPagination {
  final int totalCount;
  final int currentPage;
  final int currentCount;
  final int totalPages;

  MetaPagination({
    this.totalCount = 0,
    this.currentPage = 1,
    this.currentCount = 0,
    this.totalPages = 0,
  });

  MetaPagination copyWith({
    int? totalCount,
    int? currentPage,
    int? currentCount,
    int? totalPages,
  }) =>
      MetaPagination(
        totalCount: totalCount ?? this.totalCount,
        currentPage: currentPage ?? this.currentPage,
        currentCount: currentCount ?? this.currentCount,
        totalPages: totalPages ?? this.totalPages,
      );

  factory MetaPagination.fromJson(Map<String, dynamic> json) => MetaPagination(
    totalCount: int.tryParse(json["totalCount"].toString().toUpperCase()) ?? 0,
    currentPage: int.tryParse(json["currentPage"].toString()) ?? 1,
    currentCount: int.tryParse(json["currentCount"].toString()) ?? 0,
    totalPages: int.tryParse(json["totalPages"].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "currentPage": currentPage,
    "currentCount": currentCount,
    "totalPages": totalPages,
  };
}