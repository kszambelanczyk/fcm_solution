defmodule FcmSolution.ItineraryTest do
  alias FcmSolution.Itinerary
  use ExUnit.Case

  describe "sort_segments/1" do
    setup do
      itinerary = File.read!("test/fixtures/input.txt") |> FcmSolution.Parser.parse()
      {:ok, itinerary: itinerary}
    end

    test "sorts itinerary by arrival date", %{itinerary: itinerary} do
      assert %{segments: new_segments} = Itinerary.sort_segments(itinerary)

      assert new_segments
             |> Enum.map(& &1.dest_time)
             |> Enum.chunk_every(2, 1, :discard)
             |> Enum.all?(fn [a, b] -> DateTime.compare(a, b) == :lt end)
    end
  end

  describe "to_trips/1" do
    setup do
      itinerary =
        File.read!("test/fixtures/input.txt")
        |> FcmSolution.Parser.parse()
        |> Itinerary.sort_segments()

      {:ok, itinerary: itinerary}
    end

    test "sorts itinerary by arrival date", %{itinerary: itinerary} do
      assert %{trips: trips} = Itinerary.to_trips(itinerary)

      assert trips |> Enum.map(& &1.destinations) == [["BCN"], ["MAD"], ["NYC", "BOS"]]
    end
  end

  describe "to_string/1" do
    setup do
      itinerary =
        File.read!("test/fixtures/input.txt")
        |> FcmSolution.Parser.parse()
        |> Itinerary.sort_segments()
        |> Itinerary.to_trips()

      {:ok, itinerary: itinerary}
    end

    test "sorts itinerary by arrival date", %{itinerary: itinerary} do
      output = Itinerary.to_string(itinerary)

      # File.write!("test/fixtures/output.txt", output)

      assert """
             TRIP to BCN
             Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
             Hotel at BCN on 2023-01-05 to 2023-01-10
             Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

             TRIP to MAD
             Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
             Hotel at MAD on 2023-02-15 to 2023-02-17
             Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

             TRIP to NYC, BOS
             Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
             Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
             Flight from NYC to BOS at 2023-03-06 08:00 to 09:25
             """ =~ output
    end
  end
end
