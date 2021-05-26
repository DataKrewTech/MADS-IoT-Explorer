defmodule AcqdatCore.Mailer.DashboardReportEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "Dashboard Report"
  @from_address "bandana@stack-avenue.com"

  def email(path, to_address) do
    new_email()
    |> from(@from_address)
    |> to(to_address)
    |> subject(@subject)
    |> put_attachment(Bamboo.Attachment.new(path))
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("data_cruncher_email.html")
  end
end
