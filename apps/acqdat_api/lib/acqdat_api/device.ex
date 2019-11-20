defmodule AcqdatApi.Device do
  alias AcqdatCore.Model.Device, as: DeviceModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      access_token: access_token,
      description: description
    } = params

    verify_device(
      DeviceModel.create(%{
        name: name,
        access_token: access_token,
        description: description
      })
    )
  end

  defp verify_device({:ok, device}) do
    {:ok,
     %{
       id: device.id,
       name: device.name,
       access_token: device.access_token,
       description: device.description,
       uuid: device.uuid
     }}
  end

  defp verify_device({:error, device}) do
    {:error, %{error: extract_changeset_error(device)}}
  end
end
