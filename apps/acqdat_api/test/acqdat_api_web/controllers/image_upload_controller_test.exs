defmodule AcqdatApiWeb.ImageUploadControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "Uploading test", %{conn: conn} do

      image = %Plug.Upload{path: "test/assets/test_image.jpg", filename: "test_image.jpg"}
      params = %{"image" => image}
      image_url = "https://datakrew-image.s3.ap-south-1.amazonaws.com/uploads/dashboard/test_image.jpg"

      conn = post(conn, Routes.image_upload_path(conn, :create), params)
      response = conn |> json_response(200)

      assert response["url"] === image_url

    end
  end
end
