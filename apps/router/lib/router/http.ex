defmodule Porto.Router.Http do
  import Plug.Conn

  @options [proxy: System.get_env("http_proxy"), follow_redirect: false, max_redirect: 5]
  # downcased list of headers to ignore
  @header_blacklist ["status", "content-length", "server", "transfer-encoding"]

  def forward_call(conn, url, root \\ "/") do
    {:ok, body, conn} = read_body(conn)
    case HTTPoison.request(method(conn), url, body, [], @options) do
      {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}} ->
        # IO.inspect headers
        conn
        |> set_headers(headers)
        |> send_resp(status_code, replace_root(body, root))
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        send_resp(conn, 500, Atom.to_string(reason))
      x -> IO.inspect x
    end
  end


  defp set_headers(conn, []), do: conn
  defp set_headers(conn, [{key, value} | tail]) do
    # IO.puts "Setting header: #{key} -> #{value}"
    conn
    |> add_header(key, value)
    |> set_headers(tail)
  end

  # TODO: replace domain/url in location header
  defp add_header(conn, key, value) do
    if Enum.member?(@header_blacklist, String.downcase(key)) do
      conn
    else
      put_resp_header(conn, String.downcase(key), value)
    end
  end

  defp replace_root(content, root) do
    content
    |> String.replace("href=\"/", "href=\"#{root}/")
    |> String.replace("src=\"/", "src=\"#{root}/")
  end

  defp method(conn) do
     String.to_atom(String.downcase(conn.method))
  end

end
