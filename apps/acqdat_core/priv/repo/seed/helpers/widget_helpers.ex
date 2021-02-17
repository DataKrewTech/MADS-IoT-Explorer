defmodule AcqdatCore.Seed.Helpers.WidgetHelpers do
  alias AcqdatCore.Repo
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Widgets.Schema.WidgetType
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget.VisualSettings
  alias AcqdatCore.Widgets.Schema.Widget.DataSettings
  import Tirexs.HTTP
  import Ecto.Query

  @non_value_types ~w(object list)a

  def find_or_create_widget_type(widget_name) do
    query = from(widget_type in WidgetType,
      where: widget_type.name == ^widget_name,
      select: widget_type
      )

    case Repo.all(query) do
      [] ->
        create_widget_type(widget_name)
      data ->
        List.first(data)
    end
  end

  def do_settings(%{visual: settings}, :visual, vendor_struct) do
    Enum.map(settings, fn {key, value} ->
      set_keys_from_vendor(key, value, Map.get(vendor_struct, key))
    end)
  end

  def do_settings(%{data: settings}, :data, _vendor_struct) do
    Enum.map(settings, fn {key, value} ->
      set_data_keys(key, value)
    end)
  end

  def set_data_keys(key, %{properties: properties} = value) when properties == %{} do
    %DataSettings{
      key: key,
      value: value.value,
      data_type: value.data_type,
      properties: []
    }
  end

  def set_data_keys(key, value) do
    %DataSettings{
      key: key,
      data_type: value.data_type,
      value: value.value,
      properties: Enum.map(value.properties, fn {key, value} ->
        set_data_keys(key, value)
      end)
    }
  end

  def set_keys_from_vendor(key, value, metadata) when is_tuple(value) do
    %VisualSettings{
      key: key,
      data_type: metadata.data_type,
      user_controlled: metadata.user_controlled,
      value: set_default_or_given_value(key, value, metadata),
      source: %{},
      properties: Enum.map(value,
        fn {child_key, child_value} ->
          set_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    }
  end

  def set_keys_from_vendor(key, value, metadata) when is_list(value) do
    %VisualSettings{
      key: key,
      data_type: metadata.data_type,
      user_controlled: metadata.user_controlled,
      value: set_default_or_given_value(key, value, metadata),
      source: %{},
      properties: Enum.map(value,
        fn {child_key, child_value} ->
          set_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    }
  end

  def set_keys_from_vendor(key, value, metadata) when is_map(value) do
    %VisualSettings{
      key: key,
      data_type: metadata.data_type,
      user_controlled: metadata.user_controlled,
      source: %{},
      value: set_default_or_given_value(key, value, metadata),
      properties: properties_parsing(value, metadata)
    }
  end

  def properties_parsing(prop, metadata) do
    if Map.has_key?(prop, :properties) do
      Enum.map(prop.properties,
        fn {child_key, child_value} ->
          set_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    else
      []
    end
  end

  def set_default_or_given_value(key, value, metadata) do
    #TODO: Need to remove key workaround from here
    if !is_list(value) ||  key == :center do
      %{
        data:
        cond do
          Map.has_key?(value, :value) ->
            value.value
          Map.has_key?(metadata, :default_value) ->
           metadata.default_value
          true ->
          %{}
        end
      }
    else
      %{}
    end
  end

  def seed_in_elastic() do
    Enum.each(Repo.all(Widget), fn widget ->
      WidgetHelpers.create("widgets", widget)
    end)
  end

  def create(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      label: params.label,
      uuid: params.uuid,
      properties: params.properties,
      category: params.category
    )
  end

  defp create_widget_type(name) do
     params = %{
      name: name,
      vendor: name,
      module: "Elixir.AcqdatCore.Widgets.Schema.Vendors.#{name}",
      vendor_metadata: %{}
    }

    changeset = WidgetType.changeset(%WidgetType{}, params)
    {:ok, widget_type} = Repo.insert(changeset)
    widget_type
  end

  ############### changes done to handle update ######################
  # The above functions create schemas/structs which are good for insert however
  # update only takes map as input the below functions does the same work
  # however they return maps instead of structs.

  def do_update_settings(%{visual: settings}, :visual, vendor_struct) do
    Enum.map(settings, fn {key, value} ->
      set_mapped_keys_from_vendor(key, value, Map.get(vendor_struct, key))
    end)
  end

  def set_mapped_keys_from_vendor(key, value, metadata) when is_tuple(value) do
    %{
      key: to_string(key),
      data_type: to_string(metadata.data_type),
      user_controlled: metadata.user_controlled,
      value: set_default_or_given_value(key, value, metadata),
      source: %{},
      properties: Enum.map(value,
        fn {child_key, child_value} ->
          set_mapped_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    }
  end

  def set_mapped_keys_from_vendor(key, value, metadata) when is_list(value) do
    %{
      key: to_string(key),
      data_type: to_string(metadata.data_type),
      user_controlled: metadata.user_controlled,
      value: set_default_or_given_value(key, value, metadata),
      source: %{},
      properties: Enum.map(value,
        fn {child_key, child_value} ->
          set_mapped_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    }
  end

  def set_mapped_keys_from_vendor(key, value, metadata) when is_map(value) do
    %{
      key: to_string(key),
      data_type: to_string(metadata.data_type),
      user_controlled: metadata.user_controlled,
      source: %{},
      value: set_default_or_given_value(key, value, metadata),
      properties: mapped_properties_parsing(value, metadata)
    }
  end

  def mapped_properties_parsing(prop, metadata) do
    if Map.has_key?(prop, :properties) do
      Enum.map(prop.properties,
        fn {child_key, child_value} ->
          set_mapped_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    else
      []
    end
  end


end
