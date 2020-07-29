defmodule Virta.Component do
  @moduledoc """
  The component specification.

  It provides the behaviour and `__using__` macro which helps to create a component. For example:

  ```elixir
  defmodule Add do
    @inports [ :addend, :augend ]
    @outports [ :sum ]

    use Virta.Component

    @impl true
    def run(request_id, inport_args, _outport_args, _instance_pid) do
      value = Map.get(inport_args, :augend) + Map.get(inport_args, :addend)
      { request_id, :reply, %{ sum: value } }
    end
  end
  ```

  A Component is simply a module which implements the `Virta.Component` behaviour such that it
  allows Virta to run it.

  #### Concept

  A component communicates with other components using ports. There are two type of ports:
  * In-ports
  * Out-ports

  The component waits for message to arrive on each inport. Once all the messages are received, it
  executes the component functional logic.

  Once the execution is done, the messages are passed on to the outports (if any).

  #### Implementation

  Each component must publish a list of inports and outports.
  The `loop` method maintains the state of the component, listens to the incoming messages and once
  all the messages arrive over the inports and invokes the `run` method, which executes the
  component logic and returns a token. Which is received by the `dispatch`.

  The token can be of two types:
  * `{ request_id, :noreply }` - if the component doesn't have any outports.
  * `{ request_id, :reply, value }` - if the component has outports.

  The dispatch handles dispatching the respective messages to the outports.

  `Virta.Component` provides a `__using__` macro which defines the inports, outports, loop and
  dispatch methods. It can be used for most of the use cases. `Virta` also provides three special
  components which overrides the loop method implemented by the `__using__` macro.

  * `Virta.Core.In`
  * `Virta.Core.Out`
  * `Virta.Core.Workflow`

  Check the documentation of the above components to know more.
  """

  @doc """
  Returns a list of inports

  #### This is the method defined in __using__ macro
  ```elixir
  def inports, do: @inports
  ```
  """
  @callback inports :: [atom]

  @doc """
  Returns a list of outports

  #### This is the method defined in __using__ macro
  ```elixir
  def outports, do: @outports
  ```
  """
  @callback outports :: [atom]

  @doc """
  Dispatches the repsonses to the components connected over the outports

  The token returned by the `run` method is received by dispatch:
  * `{ request_id, :noreply }` - if the component doesn't have any outports.
  * `{ request_id, :reply, value }` - if the component has outports.
  The dispatch handles dispatching the respective messages to the outports.

  The second argument contains a `List` of outport configs, which contains information required for
  passing the output over the connections.

  #### This is the method defined in __using__ macro
  ```elixir
  # Dispatch for a component with no outports will be

  def dispatch({ request_id, :noreply }, outport_args) do
    unless length(outport_args) == 0 do
      raise ":reply expected"
    end
  end

  def dispatch({ request_id, :reply, args }, outport_args) do
    Enum.map(outport_args, fn(outport_arg) ->
      %{ pid: pid, to: to, from: from } = outport_arg
      send(pid, { request_id, to, Map.get(args, from) })
    end)
  end
  ```
  """
  @callback dispatch({any(), :noreply} | {any(), :reply, any()}, %{}) :: any

  @doc """
  Maintains the state of the component, listens to the incoming messages and once all the messages
  arrive over the inports, it invokes the `run` method.

  The first argument is an empty Map which stores the value received over the inports with inport
  as the key and its respective values.

  The second argument contains a `List` of outport configs, which contains information required for
  passing the output over the connections.

  The third argument contains a pid of the process that spawned this process.

  #### This is the method defined in __using__ macro
  ```elixir
  def loop(inport_args, outport_args, instance_pid) do
    receive do
      { request_id, port, value } when port in @inports ->
        inport_args = Map.put(inport_args, port, value)
        if(@inports |> Enum.all?(&(Map.has_key?(inport_args, &1)))) do
          run(request_id, inport_args, outport_args, instance_pid)
          |> dispatch(outport_args)
          loop(%{}, outport_args, instance_pid)
        else
          loop(inport_args, outport_args, instance_pid)
        end
    end
  end
  ```
  """
  @callback loop(%{}, %{}, pid) :: any

  @doc """
  Contains the logic of the component. Once executed, returns a token which is received by the
  `dispatch` method.

  The first argument is the request_id

  The second argument contains a `List` of outport configs, which contains information required for
  passing the output over the connections.

  The second argument contains a `Map` which contains the messages passed to components with the
  port name as the key.

  The second argument contains a `List` of outport configs, which contains information required for
  passing the output over the connections.

  The fourth argument contains a pid of the process that spawned this process.

  Once the execution is done, the following is returned
  * `{ request_id, :noreply }` - if the component doesn't have any outports.
  * `{ request_id, :reply, value }` - if the component has outports.

  The value is a Map with keys as the outport port name with its respective values.

  #### Sample without outports
  ```elixir
  def run(request_id, inport_args, _outport_args, _instance_pid) do
    value = Map.get(inport_args, :data)
    IO.inspect(value)
    { request_id, :noreply }
  end
  ```

  #### Sample with outports
  The following example has two outports :sum, :product

  ```elixir
  def run(request_id, inport_args, _outport_args, _instance_pid) do
    sum = Map.get(inport_args, :augend) + Map.get(inport_args, :addend)
    product = Map.get(inport_args, :augend) * Map.get(inport_args, :addend)
    { request_id, :reply, %{ sum: sun, product: product } }
  end
  ```
  """
  @callback run(any, %{}, %{}, pid) :: {any, :noreply} | {any, :reply, any}

  @doc """
  Returns info about the component.

  In order for the user to use a component on there must be a detailed
  information with probably some examples to explain the purpose
  of the component. The info can be written in markdown.
  """
  @callback info() :: String.t()

  @doc """
  A set of properties that can be set for a component.

  Returns a map with keys and their types, the component can make use
  of these properties in the `run` function.
  """
  @callback properties() :: Map.t()

  @doc """
  Returns the category to which the the following component belongs
  """
  @callback category() :: atom()

  @doc """
  The display name for the component.
  """
  @callback display_name() :: String.t()

  @doc """
  Returns all the properties of a component in a map.
  """
  @callback component_properties() :: map()

  defmacro __using__(_) do
    quote do
      @behaviour Virta.Component

      @impl true
      def inports, do: @inports

      @impl true
      def outports, do: @outports

      @impl true
      def properties, do: @properties

      @impl true
      def category, do: @category

      @impl true
      def info, do: @info

      @impl true
      def display_name, do: @display_name

      @impl true
      def component_properties do
        %{
          inports: @inports,
          outports: @outports,
          properties: @properties,
          category: @category,
          info: @info,
          display_name: @display_name
        }
      end

      @impl true
      def loop(inport_args, outport_args, instance_pid) do
        receive do
          {request_id, port, value} when port in @inports ->
            inport_args = Map.put(inport_args, port, value)

            if(@inports |> Enum.all?(&Map.has_key?(inport_args, &1))) do
              run(request_id, inport_args, outport_args, instance_pid)
              |> dispatch(outport_args)

              loop(%{}, outport_args, instance_pid)
            else
              loop(inport_args, outport_args, instance_pid)
            end
        end
      end

      @impl true
      def dispatch({request_id, :noreply}, outport_args) do
        unless length(outport_args) == 0 do
          raise ":reply expected"
        end
      end

      @impl true
      def dispatch({request_id, :reply, args}, outport_args) do
        Enum.map(outport_args, fn outport_arg ->
          %{pid: pid, to: to, from: from} = outport_arg
          send(pid, {request_id, to, Map.get(args, from)})
        end)
      end

      defoverridable loop: 3
    end
  end
end
