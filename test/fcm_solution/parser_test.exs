defmodule FcmSolution.ParserTest do
  use ExUnit.Case

  alias FcmSolution.Parser
  alias FcmSolution.Itinerary

  setup do
    data = File.read!("test/fixtures/input.txt")
    {:ok, data: data}
  end

  test "parses input data", %{data: data} do
    assert %Itinerary{segments: segments} = Parser.parse(data)

    assert length(segments) == 9
  end
end
