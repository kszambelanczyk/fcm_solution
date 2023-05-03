defmodule FcmSolution do
  @moduledoc """
  Documentation for `FcmSolution`.
  """

  alias FcmSolution.Parser
  alias FcmSolution.Itinerary

  def convert(), do: File.read!("./input.txt") |> _convert()

  def convert(path), do: File.read!(path) |> _convert()

  defp _convert(data) do
    data
    |> Parser.parse()
    |> Itinerary.sort_segments()
    |> Itinerary.to_trips()
    |> Itinerary.to_string()
  end
end
