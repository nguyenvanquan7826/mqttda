abstract class ServerInfo {
  int getPort() {
    return 1883;
  }

  String getHost();

  String getUser();

  String getPassword();
}

class ServerTest extends ServerInfo {
  @override
  String getHost() {
    //return "maqiatto.com";
    return "150.95.109.0";
  }

  @override
  String getPassword() {
    //return "123456";
    return "admin";
  }

  @override
  String getUser() {
//    return "tnutmqtt@gmail.com";
    return "admin";
  }
}
