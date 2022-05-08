class UserModel {
  String id;
  String name;
  String username;
  String password;
  String cookie;
  bool isMain;

  UserModel(this.id, this.name, this.username, this.password, this.cookie,
      this.isMain);

  UserModel.formJson(Map json)
      : id = json['id'],
        name = json['name'],
        username = json['username'],
        password = json['password'],
        cookie = json['cookie'],
        isMain = json['isMain'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'cookie': cookie,
      'isMain': isMain,
    };
  }
}
