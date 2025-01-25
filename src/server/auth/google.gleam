import envoy
import gleam/dynamic/decode
import gleam/hackney
import gleam/http.{Get, Post}
import gleam/http/request
import gleam/json
import gleam/option.{None, Some}
import gleam/result
import gleam/uri

pub type AuthCredentials {
  AuthCredentials(
    client_id: String,
    client_secret: String,
    redirect_uri: String,
    response_type: String,
    access_type: String,
    scope: String,
  )
}

pub type TokenResponse {
  TokenResponse(
    access_token: String,
    expires_in: Int,
    scope: String,
    token_type: String,
    id_token: String,
  )
}

pub type TokenInfo {
  TokenInfo(
    iss: String,
    azp: String,
    aud: String,
    sub: String,
    email: String,
    email_verified: String,
    at_hash: String,
    name: String,
    picture: String,
    given_name: String,
    family_name: String,
    iat: String,
    exp: String,
    alg: String,
    kid: String,
    typ: String,
  )
}

fn token_response_decoder() -> decode.Decoder(TokenResponse) {
  use access_token <- decode.field("access_token", decode.string)
  use expires_in <- decode.field("expires_in", decode.int)
  use scope <- decode.field("scope", decode.string)
  use token_type <- decode.field("token_type", decode.string)
  use id_token <- decode.field("id_token", decode.string)
  decode.success(TokenResponse(
    access_token:,
    expires_in:,
    scope:,
    token_type:,
    id_token:,
  ))
}

fn token_info_decoder() -> decode.Decoder(TokenInfo) {
  use iss <- decode.field("iss", decode.string)
  use azp <- decode.field("azp", decode.string)
  use aud <- decode.field("aud", decode.string)
  use sub <- decode.field("sub", decode.string)
  use email <- decode.field("email", decode.string)
  use email_verified <- decode.field("email_verified", decode.string)
  use at_hash <- decode.field("at_hash", decode.string)
  use name <- decode.field("name", decode.string)
  use picture <- decode.field("picture", decode.string)
  use given_name <- decode.field("given_name", decode.string)
  use family_name <- decode.field("family_name", decode.string)
  use iat <- decode.field("iat", decode.string)
  use exp <- decode.field("exp", decode.string)
  use alg <- decode.field("alg", decode.string)
  use kid <- decode.field("kid", decode.string)
  use typ <- decode.field("typ", decode.string)
  decode.success(TokenInfo(
    iss:,
    azp:,
    aud:,
    sub:,
    email:,
    email_verified:,
    at_hash:,
    name:,
    picture:,
    given_name:,
    family_name:,
    iat:,
    exp:,
    alg:,
    kid:,
    typ:,
  ))
}

pub fn request_token(creds: AuthCredentials, code: String) -> TokenResponse {
  let outbound_req =
    request.Request(
      method: Post,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "oauth2.googleapis.com",
      port: None,
      path: "token",
      query: Some(
        uri.query_to_string([
          #("client_id", creds.client_id),
          #("client_secret", creds.client_secret),
          #("code", code),
          #("grant_type", "authorization_code"),
          #("redirect_uri", creds.redirect_uri),
        ]),
      ),
    )

  // TODO: Handle properly
  let assert Ok(resp) = hackney.send(outbound_req)
  let assert Ok(auth_obj) =
    json.parse(from: resp.body, using: token_response_decoder())

  auth_obj
}

pub fn load_credentials() -> Result(AuthCredentials, Nil) {
  use client_id <- result.try(envoy.get("GOOGLE_CLIENT_ID"))
  use client_secret <- result.try(envoy.get("GOOGLE_CLIENT_SECRET"))
  use scope <- result.try(envoy.get("GOOGLE_SCOPE"))
  use redirect_uri <- result.try(envoy.get("GOOGLE_REDIRECT_URI"))

  Ok(AuthCredentials(
    client_id:,
    client_secret:,
    redirect_uri:,
    response_type: "code",
    access_type: "online",
    scope:,
  ))
}

pub fn request_token_info(id_token: String) -> TokenInfo {
  let outbound_req =
    request.Request(
      method: Get,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "oauth2.googleapis.com",
      port: None,
      path: "tokeninfo",
      query: Some(uri.query_to_string([#("id_token", id_token)])),
    )

  let assert Ok(resp) = hackney.send(outbound_req)
  let assert Ok(token_info) =
    json.parse(from: resp.body, using: token_info_decoder())

  token_info
}
