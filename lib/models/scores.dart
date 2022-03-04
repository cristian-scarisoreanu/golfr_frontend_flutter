class Scores {
  int? id;
  int? user_id;
  String? user_name;
  int? total_score;
  String? played_at;

  Scores({
    this.id,
    this.user_id,
    this.user_name,
    this.total_score,
    this.played_at,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': user_id,
        'user_name': user_name,
        'total_score': total_score,
        'played_at': played_at
      };

  Scores.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user_id = json['user_id'],
        user_name = json['user_name'],
        total_score = json['total_score'],
        played_at = json['played_at'];
}
