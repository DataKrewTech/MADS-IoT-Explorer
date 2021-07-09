defmodule AcqdatCore.Mailer.DataCruncherEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "DataKew DataCruncherEmail"
  @to_address "bandana@stack-avenue.com"
  @from_address "bandanapandey11@gmail.com"

  def email(_, _) do
    # TODO: Correct from and to addresses to general user address
    apps_path = Application.app_dir(:acqdat_core, "priv/repo/mads_apps.csv")

    new_email()
    |> from(@from_address)
    |> to(@to_address)
    |> subject(@subject)
    |> put_attachment(Bamboo.Attachment.new(apps_path))
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("data_cruncher_email.html", data_set: [1, 2])
  end
end
