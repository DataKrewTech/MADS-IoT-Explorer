defmodule AcqdatCore.Schema do
  @moduledoc """
  Interface for DB related rules.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      @timestamps_opts [type: :utc_datetime]
      alias AcqdatCore.Repo

      @spec permalink(integer) :: binary
      def permalink(bytes_count) do
        bytes_count
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)
      end

      defp add_uuid(changeset) do
        changeset
        |> put_change(:uuid, UUID.uuid1(:hex))
      end

      defp add_slug(changeset) do
        changeset
        |> put_change(:slug, Slugger.slugify(random_string(12)))
      end

      defp random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
      end
    end
  end
end
