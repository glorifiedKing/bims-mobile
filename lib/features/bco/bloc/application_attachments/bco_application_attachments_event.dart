abstract class BcoApplicationAttachmentsEvent {}

class FetchBcoApplicationAttachments extends BcoApplicationAttachmentsEvent {
  final String applicationKey;
  FetchBcoApplicationAttachments(this.applicationKey);
}

class LoadMoreBcoApplicationAttachments extends BcoApplicationAttachmentsEvent {
  final String applicationKey;
  LoadMoreBcoApplicationAttachments(this.applicationKey);
}
