defmodule AcqdatCore.Mailer.DashboardReportEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "DataKrew Dashboard Report"
  @from_address "admin@datakrew.com"

  def email(path, to_address) do
    new_email()
    |> from(@from_address)
    |> to(to_address)
    |> subject(@subject)
    |> put_attachment(Bamboo.Attachment.new(path))
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("dashboard_report_email.html")
  end
end
