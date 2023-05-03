defmodule FcmSolution.Trip do
  defstruct destinations: [], segments: []

  @type t :: %__MODULE__{
          destinations: list(String.t()),
          segments: list(FcmSolution.Segment.t())
        }
end
