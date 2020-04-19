defmodule AcqdatApiWeb.TeamView do
  use AcqdatApiWeb, :view

  def render("team_details.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      enable_tracking: team.enable_tracking
    }
  end
end
