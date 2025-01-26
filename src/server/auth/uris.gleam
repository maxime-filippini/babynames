import gleam/option.{None, Some}
import gleam/uri
import server/auth/google

pub fn auth_uri(creds: google.AuthCredentials) {
  uri.Uri(
    scheme: Some("https"),
    userinfo: None,
    host: Some("accounts.google.com"),
    port: None,
    path: "o/oauth2/v2/auth",
    fragment: None,
    query: Some(
      uri.query_to_string([
        #("client_id", creds.client_id),
        #("redirect_uri", creds.redirect_uri),
        #("response_type", creds.response_type),
        #("access_type", creds.access_type),
        #("scope", creds.scope),
      ]),
    ),
  )
}
