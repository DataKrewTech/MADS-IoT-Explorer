defmodule AcqdatCore.Factory.Hierarchy do
  defmacro __using__(_opts) do
    quote do
      alias AcqdatCore.Schema.EntityManagement.{Organisation, AssetCategory, Asset, Project}

      def organisation_factory() do
        %Organisation{
          uuid: UUID.uuid1(:hex),
          name: sequence(:organisation_name, &"Asgard#{&1}"),
          metadata: %{},
          description: "port of asgardians"
        }
      end

      def project_factory() do
        %Project{
          name: sequence(:name, &"Project-#{&1}"),
          uuid: UUID.uuid1(:hex),
          slug: sequence(:sensor_name, &"Project#{&1}"),
          creator: build(:user),
          org: build(:organisation)
        }
      end

      def asset_category_factory() do
        %AssetCategory{
          name: sequence(:asset_category_name, &"Realm-#{&1}"),
          metadata: %{},
          description: "realm of king odin",
          uuid: UUID.uuid1(:hex),
          organisation: build(:organisation)
        }
      end

      def asset_factory() do
        %Asset{
          uuid: UUID.uuid1(:hex),
          slug: Slugger.slugify(random_string(12)),
          name: sequence(:asset_name, &"Area-#{&1}"),
          asset_category: build(:asset_category),
          org: build(:organisation),
          project: build(:project),
          mapped_parameters: [
            %{
              name: sequence(:asset_params, &"AssetParams#{&1}")
            },
            %{
              name: sequence(:asset_params, &"AssetParams#{&1}")
            }
          ],
          image_url: "",
          properties: [],
          parent_id: -1,
          lft: -1,
          rgt: -1,
          project: insert(:project)
        }
      end

      defp random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
      end
    end
  end
end
