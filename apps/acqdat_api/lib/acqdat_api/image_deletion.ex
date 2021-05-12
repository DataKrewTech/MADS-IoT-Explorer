defmodule AcqdatApi.ImageDeletion do
  def delete_operation(image_url, params) do
    Task.Supervisor.async(Datakrew.TaskSupervisor, fn ->
      delete_file(image_url, params)
    end)
  end

  defp delete_file(file_url, prefix) do
    path = String.split(file_url, "/")
    path_file_name = List.last(path) |> String.replace("%20", " ")

    list =
      ExAws.S3.list_objects(System.get_env("AWS_S3_BUCKET"), prefix: "uploads/#{prefix}")
      |> ExAws.stream!()
      |> Enum.to_list()

    Enum.each(list, fn obj ->
      [_, _, _, file_name] = String.split(obj.key, "/")

      if file_name == path_file_name do
        ExAws.S3.delete_object(System.get_env("AWS_S3_BUCKET"), obj.key)
        |> ExAws.request()
      end
    end)
  end
end
