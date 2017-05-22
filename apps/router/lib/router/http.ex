defmodule Router.Http do
  import Plug.Conn

  @options [proxy: System.get_env("http_proxy"), follow_redirect: false, max_redirect: 5]
  # downcased list of headers to ignore
  @header_blacklist ["status", "content-length", "server", "transfer-encoding"]

  def forward_call(conn, url, root \\ "/") do
    {:ok, body, conn} = read_body(conn)
    headers = []
    cookies = []
    # cookies = [hackney: [cookie: "cookie1=111; cookie2=222"]]
    case HTTPoison.request(method(conn), url, body, headers, @options ++ cookies) do
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
      new_value = case String.downcase(key) do
        "location" -> String.replace(value, "https://maps.google.com", "http://localhost:4001/maps") # TODO: generic replacement
        "set-cookie" -> value # TODO: replace cookies
        _ -> value
      end
      put_resp_header(conn, String.downcase(key), new_value)
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
