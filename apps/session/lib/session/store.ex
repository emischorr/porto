defmodule Session.Store do
  use GenServer

  @process_name :session_store

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: @process_name)
  end

  def save(session, value) do
     GenServer.call(@process_name, {:save, {session, value}})
  end

  def load(session) do
     GenServer.call(@process_name, {:load, session})
  end

  # Server (callbacks)

  def init(state) do
    :ets.new(:session_store, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, state}
  end

  def handle_call({:save, {session, value}}, _from, state) do
    #TODO: replace with mnesia
    :ets.insert(:session_store, {session, value})
    {:reply, :ok, state}
  end

  def handle_call({:load, session}, _from, state) do
    #TODO: replace with mnesia
    case :ets.lookup(:session_store, session) do
      [{^session, value}] -> {:reply, {:ok, value}, state}
      [] -> {:reply, {:error}, state}
    end
  end

end
