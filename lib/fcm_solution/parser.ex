defmodule FcmSolution.Parser do
  @moduledoc false

  alias FcmSolution.Itinerary
  alias FcmSolution.Segment

  @spec parse(binary) :: Itinerary.t()
  def parse(data) do
    data |> String.split("\n") |> Enum.reduce(%Itinerary{}, &parse_line(&1, &2))
  end

  defp parse_line("BASED: " <> based, itinerary), do:
    %{itinerary | based: based}

  defp parse_line("SEGMENT: " <> segment, itinerary), do: parse_segment(segment, itinerary)

  defp parse_line(_line, itinerary), do: itinerary

  defp parse_segment("Flight " <> <<start::binary-size(3)>> <> rest, itinerary),
    do: parse_segment(:flight, start, rest, itinerary)

  defp parse_segment("Train " <> <<start::binary-size(3)>> <> rest, itinerary),
    do: parse_segment(:train, start, rest, itinerary)

  defp parse_segment("Hotel " <> <<start::binary-size(3)>> <> rest, itinerary) do
    [start_time_str, dest_time_str] = rest |> String.split("->") |> Enum.map(&String.trim/1)
    start_time = parse_date(start_time_str)
    dest_time = parse_date(dest_time_str)

    %{
      itinerary
      | segments: [Segment.new(:hotel, start, start_time, start, dest_time) | itinerary.segments]
    }
  end

  defp parse_segment(type, start, rest, itinerary) do
    [start_time_str, <<dest::binary-size(3)>> <> " " <> dest_time_str] =
      rest |> String.split("->") |> Enum.map(&String.trim/1)

    start_time = parse_date(start_time_str)
    dest_time = parse_date(dest_time_str, start_time)

    %{
      itinerary
      | segments: [Segment.new(type, start, start_time, dest, dest_time) | itinerary.segments]
    }
  end

  defp parse_date(
         <<year::binary-size(4)>> <>
           "-" <>
           <<month::binary-size(2)>> <>
           "-" <>
           <<day::binary-size(2)>> <>
           " " <> <<hour::binary-size(2)>> <> ":" <> <<minute::binary-size(2)>>
       ) do
    {:ok, date, _} = DateTime.from_iso8601("#{year}-#{month}-#{day}T#{hour}:#{minute}:00Z")
    date
  end

  defp parse_date(
         <<year::binary-size(4)>> <>
           "-" <>
           <<month::binary-size(2)>> <>
           "-" <>
           <<day::binary-size(2)>>
       ) do
    {:ok, date, _} = DateTime.from_iso8601("#{year}-#{month}-#{day}T00:00:00Z")
    date
  end

  defp parse_date(
         <<hour::binary-size(2)>> <> ":" <> <<minute::binary-size(2)>>,
         start_time
       ),
       do: Timex.set(start_time, hour: String.to_integer(hour), minute: String.to_integer(minute))
end
