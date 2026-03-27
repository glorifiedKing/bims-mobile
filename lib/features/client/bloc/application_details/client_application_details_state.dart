import '../../models/application_detail_model.dart';

abstract class ClientApplicationDetailsState {}

class ClientApplicationDetailsInitial extends ClientApplicationDetailsState {}

class ClientApplicationDetailsLoading extends ClientApplicationDetailsState {}

class ClientApplicationDetailsLoaded extends ClientApplicationDetailsState {
  final ApplicationDetailModel application;
  final bool isDownloadingPdf;
  final String? downloadPdfPath;
  final String? downloadPdfError;

  ClientApplicationDetailsLoaded(
    this.application, {
    this.isDownloadingPdf = false,
    this.downloadPdfPath,
    this.downloadPdfError,
  });

  ClientApplicationDetailsLoaded copyWith({
    ApplicationDetailModel? application,
    bool? isDownloadingPdf,
    String? downloadPdfPath,
    String? downloadPdfError,
  }) {
    return ClientApplicationDetailsLoaded(
      application ?? this.application,
      isDownloadingPdf: isDownloadingPdf ?? this.isDownloadingPdf,
      downloadPdfPath: downloadPdfPath ?? this.downloadPdfPath,
      downloadPdfError: downloadPdfError ?? this.downloadPdfError,
    );
  }
}

class ClientApplicationDetailsError extends ClientApplicationDetailsState {
  final String message;

  ClientApplicationDetailsError(this.message);
}
