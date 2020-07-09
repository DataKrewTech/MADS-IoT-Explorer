defmodule AcqdatIotWeb.DataParser.DataDumpView do
  use AcqdatApiWeb, :view

  def render("command.json", %{command: command}) do
    %{
      command: command,
      data_inserted: true
    }
  end
end
