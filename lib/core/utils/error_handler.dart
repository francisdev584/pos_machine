import 'dart:io';

import 'package:dio/dio.dart';

/// Classe responsável por tratar erros de requisições HTTP e outros erros comuns na aplicação
class AppErrorHandler {
  /// Método para processar erros Dio (erros de rede) e retornar mensagens amigáveis
  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão excedido. Verifique sua conexão com a internet.';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio excedido. Verifique sua conexão com a internet.';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de recebimento excedido. Verifique sua conexão com a internet.';
      case DioExceptionType.badCertificate:
        return 'Certificado inválido. Por favor, entre em contato com o suporte.';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'A requisição foi cancelada.';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique se você está conectado à internet.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'Não foi possível se conectar ao servidor. Verifique sua conexão com a internet.';
        }
        return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    }
  }

  /// Método para tratar códigos de erro HTTP específicos
  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitação inválida. Verifique os dados enviados.';
      case 401:
        return 'Não autorizado. Por favor, faça login novamente.';
      case 403:
        return 'Acesso negado. Você não tem permissão para acessar este recurso.';
      case 404:
        return 'Recurso não encontrado.';
      case 408:
        return 'Tempo de solicitação esgotado. Por favor, tente novamente.';
      case 500:
        return 'Erro interno do servidor. Por favor, tente novamente mais tarde.';
      case 502:
        return 'Servidor indisponível. Por favor, tente novamente mais tarde.';
      case 503:
        return 'Serviço temporariamente indisponível. Por favor, tente novamente mais tarde.';
      case 504:
        return 'Tempo limite do gateway. Por favor, tente novamente mais tarde.';
      default:
        return 'Ocorreu um erro na comunicação com o servidor (código $statusCode).';
    }
  }

  /// Método para lidar com erros genéricos
  static String handleGenericError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    } else {
      return 'Ocorreu um erro inesperado: $error';
    }
  }
}

/// Exceção personalizada para erros da aplicação
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic error;

  AppException(this.message, {this.code, this.error});

  @override
  String toString() => message;
}
