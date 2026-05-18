class UserInfo {
  String id;
  String username;
  String phone;
  String? avatar;
  int coins;
  int trialDays;
  int caseCount;
  String token;

  UserInfo({
    required this.id,
    required this.username,
    required this.phone,
    this.avatar,
    required this.coins,
    required this.trialDays,
    required this.caseCount,
    required this.token,
  });

  factory UserInfo.fromJSON(Map<String, dynamic> json) {
    return UserInfo(
      id: json["id"]?.toString() ?? "",
      username: json["username"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      avatar: json["avatar"]?.toString(),
      coins: json["coins"] as int? ?? 0,
      trialDays: json["trial_days"] as int? ?? 0,
      caseCount: json["case_count"] as int? ?? 0,
      token: json["token"]?.toString() ?? "",
    );
  }
}