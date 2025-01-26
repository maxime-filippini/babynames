import wisp.{type Request, type Response}

pub fn with_invalidated_user_cookie(req: Request, resp: Response) -> Response {
  wisp.set_cookie(resp, req, "user_id", "", wisp.Signed, 0)
}
