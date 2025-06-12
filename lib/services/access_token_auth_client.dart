import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth.dart';

class AccessTokenAuthClient extends http.BaseClient {
  final AccessToken _accessToken;
  final http.Client _inner = http.Client();

  AccessTokenAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] =
        '${_accessToken.type} ${_accessToken.data}';
    return _inner.send(request);
  }
}
