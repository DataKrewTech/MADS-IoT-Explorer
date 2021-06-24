defmodule Virta.Node do
  @enforce_keys [:id, :module]
  defstruct id: nil, module: nil, ref: nil, configuration: %{}, label: nil

  @typedoc """
  Represents the node in a graph used to generate the workflow.

  * `:id`: It should be unique to the node in a graph. Usually a string or an integer.
  * `:label`: Label to identify the node in a graph. Ideally it should be unique.
  * `:module`: The reference to the module. An atom.
  * `:ref`: In case of a workflow component, the name of the registered workflow. A string.
  * `:configuration`: Store the configuration as per the properties defined by the
      component module. The configuration done here will be used by component.
  """
  @type t :: %__MODULE__{
          id: any(),
          label: String.t(),
          module: atom,
          ref: String.t(),
          configuration: map()
        }
end
