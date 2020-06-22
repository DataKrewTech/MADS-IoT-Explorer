defmodule AcqdatApiWeb.DataCruncher.TempOutputView do
  use AcqdatApiWeb, :view

  def render("output.json", %{temp_output: output}) do
    %{
      id: output.id,
      format: output.format,
      async: output.async,
      data: output.data
    }
  end
end
