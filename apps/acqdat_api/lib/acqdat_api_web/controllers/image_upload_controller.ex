defmodule AcqdatApiWeb.ImageUploadController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.Image

  def create(conn, %{"image" => image, "path" => path}) do
    with {:ok, image_name} <- Image.store({image, path}) do
      image_url = Image.url({image_name, path})

      conn
      |> put_status(200)
      |> render("show.json", %{url: image_url})
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end
end
