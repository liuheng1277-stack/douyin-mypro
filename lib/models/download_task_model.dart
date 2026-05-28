class DownloadTaskModel {
  final int? id;
  final String videoId;
  final String url;
  final String? localPath;
  final int status;
  final double progress;
  final int? totalSize;
  final int? downloadedSize;
  final String? errorMsg;
  final int? createTime;

  DownloadTaskModel({
    this.id,
    required this.videoId,
    required this.url,
    this.localPath,
    this.status = 0,
    this.progress = 0.0,
    this.totalSize,
    this.downloadedSize,
    this.errorMsg,
    this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_id': videoId,
      'url': url,
      'local_path': localPath,
      'status': status,
      'progress': progress,
      'total_size': totalSize,
      'downloaded_size': downloadedSize,
      'error_msg': errorMsg,
      'create_time': createTime,
    };
  }

  factory DownloadTaskModel.fromMap(Map<String, dynamic> map) {
    return DownloadTaskModel(
      id: map['id'] as int?,
      videoId: map['video_id'] as String,
      url: map['url'] as String,
      localPath: map['local_path'] as String?,
      status: map['status'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      totalSize: map['total_size'] as int?,
      downloadedSize: map['downloaded_size'] as int?,
      errorMsg: map['error_msg'] as String?,
      createTime: map['create_time'] as int?,
    );
  }
}
