defmodule Porto.Router.Endpoint do
  use Plug.Router
  require Logger

  alias Porto.Router.Http

  plug Plug.RequestId, http_header: "x-request-id"
  plug Plug.Logger
  plug :match
  plug :dispatch

  match "/cms" do
    conn
    |> Http.forward_call("https://github.com")
    |> halt
  end

  match _ do
    conn
    # TODO: add a small description / some help
    |> send_resp(404, "Nothing here")
    |> halt
  end

end
