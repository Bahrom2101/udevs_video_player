class TvProgram {
  String scheduledTime;
  String programTitle;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['scheduledTime'] = scheduledTime;
    map['programTitle'] = programTitle;
    return map;
  }

  @override
  String toString() {
    return 'TvProgram{scheduledTime: $scheduledTime, programTitle: $programTitle}';
  }

  TvProgram({
    required this.scheduledTime,
    required this.programTitle,
  });
}
