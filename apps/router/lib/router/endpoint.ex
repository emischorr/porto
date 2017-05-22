defmodule Router.Endpoint do
  use Plug.Router
  require Logger

  alias Router.Http

  plug Plug.RequestId, http_header: "x-request-id"
  plug Plug.Logger
  plug :match
  plug :dispatch

  match "/git/*glob" do
    conn
    # |> Session.load
    |> Http.forward_call("https://github.com/#{glob}", "/git")
    # |> Session.save
    |> halt
  end

  match "/maps/*glob" do
    conn
    |> Http.forward_call("https://maps.google.com/#{glob}", "/maps")
    |> halt
  end

  match "/wrong/url" do
    conn
    # TODO: redirect
    # |> redirect(to: "/correct/url")
    |> halt
  end

  match _ do
    conn
    # TODO: add a small description / some help
    |> send_resp(404, "Nothing here")
    |> halt
  end

end
