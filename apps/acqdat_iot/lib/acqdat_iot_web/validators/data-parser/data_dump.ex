defmodule AcqdatIoTWeb.Validators.DataParser.DataDump do
  use Params
  alias AcqdatCore.Schema.IotManager.EctoType.UnixTimestamp

  defparams(
    verify_dumping_data(%{
      data!: :map,
      gateway_id!: :integer,
      org_id!: :integer,
      project_id!: :integer,
      inserted_timestamp!: UnixTimestamp
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      project_id!: :integer
    })
  )
end
