defmodule FcmSolution.Segment do
  defstruct [:type, :start, :start_time, :dest, :dest_time]

  @enforce_keys [:type, :start, :start_time, :dest, :dest_time]

  @type t :: %__MODULE__{
          type: atom(),
          start: String.t(),
          start_time: DateTime.t(),
          dest: String.t(),
          dest_time: DateTime.t()
        }

  def new(type, start, start_time, dest, dest_time) do
    %__MODULE__{
      type: type,
      start: start,
      start_time: start_time,
      dest: dest,
      dest_time: dest_time
    }
  end
end
