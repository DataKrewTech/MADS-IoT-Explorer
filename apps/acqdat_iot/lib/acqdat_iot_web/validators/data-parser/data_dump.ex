defmodule AcqdatApiWeb.Validators.DataParser.DataDump do
  use Params

  defparams(
    verify_dumping_data(%{
      data!: :map,
      gateway_id!: :integer,
      org_id!: :integer,
      project_id!: :integer,
      inserted_timestamp!: :utc_datetime
    })
  )
end
