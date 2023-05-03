defmodule FcmSolution.Itinerary do
  defstruct [:based, segments: [], trips: []]

  alias FcmSolution.Segment
  alias FcmSolution.Trip

  @type t :: %__MODULE__{
          based: String.t(),
          segments: list(Segment.t()),
          trips: list(Trip.t())
        }

  @spec sort_segments(t()) :: t()
  def sort_segments(itinerary) do
    %{segments: segments} = itinerary

    segments = Enum.sort_by(segments, & &1.dest_time, {:asc, DateTime})

    %{itinerary | segments: segments}
  end

  @spec to_trips(t()) :: t()
  def to_trips(itinerary) do
    # Grouping assuming that trip starts always from based value
    %{segments: segments, based: based} = itinerary

    trips =
      _to_trips(segments, based)
      |> fill_trips_destinations(based)

    %{itinerary | trips: trips}
  end

  defp _to_trips(segments, based), do: _to_trips(segments, based, [])

  defp _to_trips([%{start: start} = segment | segments], based, trips) when start == based do
    # when segment matches based value -> create new trip
    trip = %Trip{segments: [segment]}

    _to_trips(segments, based, [trip | trips])
  end

  defp _to_trips([segment | segments], based, [trip | trips]) do
    trip = %{trip | segments: [segment | trip.segments]}

    _to_trips(segments, based, [trip | trips])
  end

  defp _to_trips([], _based, trips),
    do:
      trips
      |> Enum.map(fn trip -> %{trip | segments: Enum.reverse(trip.segments)} end)
      |> Enum.reverse()

  defp fill_trips_destinations(trips, based) do
    Enum.map(trips, fn trip ->
      %{trip | destinations: fill_destinations(trip.segments, based)}
    end)
  end

  defp fill_destinations(segments, based), do: fill_destinations(segments, based, [])

  # catching connection when less than 24 hours difference
  defp fill_destinations(
         [
           %{type: type, dest: dest, dest_time: dest_time}
           | [%{type: type2, start_time: start_time, dest: dest2} | _] = segments
         ],
         based,
         destinations
       )
       when type in [:train, :flight] and type2 != :hotel and dest != based and dest2 != based do
    if DateTime.diff(start_time, dest_time, :hour) < 24 do
      fill_destinations(segments, based, destinations)
    else
      fill_destinations(segments, based, [dest | destinations])
    end
  end

  defp fill_destinations([%{type: type, dest: dest} | segments], based, destinations)
       when type in [:train, :flight] and dest != based do
    fill_destinations(segments, based, [dest | destinations])
  end

  defp fill_destinations([_ | segments], based, destinations),
    do: fill_destinations(segments, based, destinations)

  defp fill_destinations([], _based, destinations), do: destinations |> Enum.reverse()

  @spec to_string(t()) :: String.t()
  def to_string(%{trips: trips}),
    do:
      trips
      |> Enum.map(&trip_to_string/1)
      |> Enum.join("\n")

  defp trip_to_string(%Trip{segments: segments, destinations: destinations}) do
    "TRIP to #{Enum.join(destinations, ", ")}\n" <> segments_to_string(segments)
  end

  defp segments_to_string(segments), do: segments_to_string(segments, "")

  defp segments_to_string([segment | segments], result) do
    result = result <> segment_to_string(segment) <> "\n"

    segments_to_string(segments, result)
  end

  defp segments_to_string([], result), do: result

  defp segment_to_string(%{
         type: type,
         start: start,
         start_time: start_time,
         dest: dest,
         dest_time: dest_time
       })
       when type in [:flight, :train] do
    type_str = if type == :flight, do: "Flight", else: "Train"

    type_str <>
      " from #{start} to #{dest} at #{Timex.format!(start_time, "{YYYY}-{0M}-{0D} {h24}:{m}")} to #{Timex.format!(dest_time, "{h24}:{m}")}"
  end

  defp segment_to_string(%{
         type: :hotel,
         start: start,
         start_time: start_time,
         dest_time: dest_time
       }),
       do:
         "Hotel at #{start} on #{Timex.format!(start_time, "{YYYY}-{0M}-{0D}")} to #{Timex.format!(dest_time, "{YYYY}-{0M}-{0D}")}"
end
