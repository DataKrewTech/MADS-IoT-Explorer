defmodule AcqdatApiWeb.Validators.Alerts.AlertFilterListing do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer
    })
  )
end
