defmodule AcqdatApiWeb.DataCruncher.TempOutputView do
  use AcqdatApiWeb, :view

  def render("output.json", %{temp_output: output}) do
    %{
      id: output.id,
      format: output.format,
      source_id: output.source_id,
      async: output.async,
      data: output.data
    }
  end
end
