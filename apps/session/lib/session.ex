defmodule Session do
  @moduledoc """
  Documentation for Session.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Session.hello
      :world

  """
  def hello do
    :world
  end

  def save(session, value) do
    #TODO: save some value in the session
  end

  def load(session) do
     #TODO: load values from given session
  end
end
