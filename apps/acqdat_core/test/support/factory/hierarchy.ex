defmodule AcqdatCore.Factory.Hierarchy do
  defmacro __using__(_) do
    quote do
      alias AcqdatCore.Schema.EntityManagement.{Organisation, Asset, Project}

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

      def asset_factory() do
        %Asset{
          uuid: UUID.uuid1(:hex),
          slug: Slugger.slugify(random_string(12)),
          name: sequence(:asset_name, &"Area-#{&1}"),
          org: build(:organisation),
          project: build(:project),
          asset_type: build(:asset_type),
          creator: build(:user),
          mapped_parameters: [
            %{
              name: sequence(:asset_params, &"AssetParams#{&1}")
            },
            %{
              name: sequence(:asset_params, &"AssetParams#{&1}")
            }
          ],
          metadata: [
            %{
              name: sequence(:asset_metadata, &"Asset Metadata#{&1}"),
              uuid: UUID.uuid1(:hex),
              data_type: sequence(:asset_metadata, &"Data Type#{&1}"),
              unit: sequence(:asset_metadata, &"Unit #{&1}")
            },
            %{
              name: sequence(:asset_metadata, &"Asset Metadata#{&1}"),
              data_type: sequence(:asset_metadata, &"Data Type#{&1}"),
              uuid: UUID.uuid1(:hex),
              unit: sequence(:asset_metadata, &"Unit #{&1}")
            }
          ],
          image_url: "",
          properties: [],
          parent_id: -1,
          lft: -1,
          rgt: -1
        }
      end

      defp random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
      end
    end
  end
end
