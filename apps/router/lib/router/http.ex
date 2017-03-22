defmodule Porto.Router.Http do
  import Plug.Conn

  @options [proxy: System.get_env("http_proxy"), follow_redirect: false, max_redirect: 5]
  # downcased list of headers to ignore
  @header_blacklist ["status", "content-length", "server", "transfer-encoding"]

  def forward_call(conn, url) do
    case HTTPoison.get(url, [], @options) do
      {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}} ->
        # IO.inspect headers
        conn
        |> set_headers(headers)
        |> send_resp(status_code, body)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        send_resp(conn, 500, reason)
    end
  end


  defp set_headers(conn, []), do: conn
  defp set_headers(conn, [{key, value} | tail]) do
    # IO.puts "Setting header: #{key} -> #{value}"
    conn
    |> add_header(key, value)
    |> set_headers(tail)
  end

  defp add_header(conn, key, value) do
    if Enum.member?(@header_blacklist, String.downcase(key)) do
      conn
    else
      put_resp_header(conn, String.downcase(key), value)
    end
  end

end
