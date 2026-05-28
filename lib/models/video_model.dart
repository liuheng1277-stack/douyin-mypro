class VideoModel {
  final int? id;
  final String videoId;
  final String title;
  final String author;
  final String authorId;
  final String coverUrl;
  final String? videoUrl;
  final String? localPath;
  final int? fileSize;
  final int? duration;
  final int? width;
  final int? height;
  final String? format;
  final int? createTime;
  final int? syncTime;
  final int downloadStatus;
  final int isFavorite;
  final String? description;

  VideoModel({
    this.id,
    required this.videoId,
    required this.title,
    required this.author,
    required this.authorId,
    required this.coverUrl,
    this.videoUrl,
    this.localPath,
    this.fileSize,
    this.duration,
    this.width,
    this.height,
    this.format,
    this.createTime,
    this.syncTime,
    this.downloadStatus = 0,
    this.isFavorite = 1,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_id': videoId,
      'title': title,
      'author': author,
      'author_id': authorId,
      'cover_url': coverUrl,
      'video_url': videoUrl,
      'local_path': localPath,
      'file_size': fileSize,
      'duration': duration,
      'width': width,
      'height': height,
      'format': format,
      'create_time': createTime,
      'sync_time': syncTime,
      'download_status': downloadStatus,
      'is_favorite': isFavorite,
      'description': description,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as int?,
      videoId: map['video_id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      authorId: map['author_id'] as String,
      coverUrl: map['cover_url'] as String,
      videoUrl: map['video_url'] as String?,
      localPath: map['local_path'] as String?,
      fileSize: map['file_size'] as int?,
      duration: map['duration'] as int?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      format: map['format'] as String?,
      createTime: map['create_time'] as int?,
      syncTime: map['sync_time'] as int?,
      downloadStatus: map['download_status'] as int? ?? 0,
      isFavorite: map['is_favorite'] as int? ?? 1,
      description: map['description'] as String?,
    );
  }

  VideoModel copyWith({
    int? id,
    String? videoId,
    String? title,
    String? author,
    String? authorId,
    String? coverUrl,
    String? videoUrl,
    String? localPath,
    int? fileSize,
    int? duration,
    int? width,
    int? height,
    String? format,
    int? createTime,
    int? syncTime,
    int? downloadStatus,
    int? isFavorite,
    String? description,
  }) {
    return VideoModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      coverUrl: coverUrl ?? this.coverUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      format: format ?? this.format,
      createTime: createTime ?? this.createTime,
      syncTime: syncTime ?? this.syncTime,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
    );
  }
}
