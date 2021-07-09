defmodule AcqdatApi.ToolManagement do
  alias AcqdatCore.Model.ToolManagement.{Employee, ToolBox, Tool}
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.{ToolIssue, ToolReturn}
  alias Ecto.Multi

  @in_inventory_status "in_inventory"
  @issued_status "issued"

  @spec verify_employee(map) :: {:error, String.t()} | {:ok, String.t()}
  def verify_employee(params) do
    case Employee.get(params) do
      {:ok, employee} ->
        {:ok, employee}

      {:error, message} ->
        {:error, message}
    end
  end

  @spec tool_transaction(map) :: {:ok, map} | {:error, map}
  def tool_transaction(params) do
    %{
      transaction: transaction_type,
      tool_ids: tool_uuids,
      user_uuid: user_uuid,
      tool_box_uuid: tool_box_uuid
    } = params

    tool_uuids = tool_uuids |> MapSet.new() |> Enum.to_list()

    with {:employee, {:ok, employee}} <- {:employee, Employee.get(%{uuid: user_uuid})},
         {:tool_box, {:ok, tool_box}} <- {:tool_box, ToolBox.get(%{uuid: tool_box_uuid})} do
      %{}
      |> Map.put(:employee_id, employee.id)
      |> Map.put(:tool_box_id, tool_box.id)
      |> Map.put(:tool_ids, tool_uuids)
      |> run_transaction(transaction_type)
    else
      {:employee, {:error, message}} ->
        {:error, %{error: "employee_id_error", message: message}}

      {:tool_box, {:error, message}} ->
        {:error, %{error: "tool_box_id_error", message: message}}
    end
  end

  def verify_tool(%{tool_uuid: tool_uuid}) do
    Tool.get(%{uuid: tool_uuid})
  end

  def employees(_) do
    Employee.get_all()
  end

  def tool_box_status(tool_box_uuid) do
    case ToolBox.get(%{uuid: tool_box_uuid}) do
      {:ok, tool_box} ->
        tool_box = Repo.preload(tool_box, :tools)
        {:ok, tool_box.tools}

      {:error, _} = error ->
        error
    end
  end

  @spec employee_transaction_status(non_neg_integer) :: {:ok, []} | {:error, any}
  def employee_transaction_status(employee_uuid) do
    case Employee.get(%{uuid: employee_uuid}) do
      {:ok, employee} ->
        {:ok, Employee.employee_tool_issue_status(employee.id)}

      {:error, _} = error ->
        error
    end
  end

  ##################################### Private Functions #####################

  defp run_transaction(tool_manifest, status = "issue") do
    %{tool_ids: tool_uuids} = tool_manifest

    case Tool.get_all_by_uuids_and_status(tool_uuids, @in_inventory_status) do
      [] ->
        {:error, "no issuable tools"}

      tool_ids ->
        issue_list =
          tool_manifest |> Map.replace!(:tool_ids, tool_ids) |> tool_insert_manifest(status)

        persist(ToolIssue, issue_list, @issued_status, status)
    end
  end

  defp run_transaction(tool_manifest, status = "return") do
    %{tool_ids: tool_uuids} = tool_manifest

    case Tool.get_all_by_uuids_and_status(tool_uuids, @issued_status) do
      [] ->
        {:error, "no returnable tools"}

      tool_ids ->
        return_list =
          tool_manifest |> Map.replace!(:tool_ids, tool_ids) |> tool_insert_manifest(status)

        persist(ToolReturn, return_list, @in_inventory_status, status)
    end
  end

  defp tool_insert_manifest(tool_manifest, status) do
    %{tool_box_id: tool_box_id, employee_id: employee_id, tool_ids: tool_ids} = tool_manifest
    time = DateTime.truncate(DateTime.utc_now(), :second)

    Enum.map(tool_ids, fn tool_id ->
      data = %{
        tool_id: tool_id,
        tool_box_id: tool_box_id,
        employee_id: employee_id,
        inserted_at: time,
        updated_at: time
      }

      map_with_time_identifier(data, status, time, tool_id)
    end)
  end

  defp map_with_time_identifier(data, "issue", timestamp, _) do
    Map.put(data, :issue_time, timestamp)
  end

  defp map_with_time_identifier(data, "return", timestamp, tool_id) do
    tool_issue_id = get_tool_issue_id(tool_id)

    data
    |> Map.put(:return_time, timestamp)
    |> Map.put(:tool_issue_id, tool_issue_id)
  end

  defp persist(schema, list, status, transaction_type) do
    Multi.new()
    |> Multi.insert_all(:inserts, schema, list, returning: [:tool_id])
    |> Multi.run(:tool_update, fn _, %{inserts: {_, inserts}} ->
      {:ok, update_tool_status(inserts, status)}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, "transaction #{transaction_type} succeded"}

      {:error, _, _, _} ->
        {:error, "transaction #{transaction_type} failed"}
    end
  end

  defp update_tool_status(transaction_data, status) do
    tool_ids = Enum.map(transaction_data, fn data -> data.tool_id end)
    Tool.update_tool_status(tool_ids, status)
  end

  defp get_tool_issue_id(tool_id) do
    Tool.get_tool_latest_issue_id(tool_id)
  end
end
