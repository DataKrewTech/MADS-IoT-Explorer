defmodule AcqdatCore.Mailer.DataCruncherEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "DataKew DataCruncherEmail"
  @to_address "bandana@joshsoftware.com"
  @from_address "bandanapandey11@gmail.com"

  def email(current_user, data_set) do
    # {:ok, to_address} = Map.fetch(invitation_details, "email")
    # {:ok, from_address} = Map.fetch(invitation_details, "inviter_email")
    new_email()
    |> from(@from_address)
    |> to(@to_address)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("data_cruncher_email.html", data_set: [1, 2])
  end
end
