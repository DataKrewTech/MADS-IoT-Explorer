defmodule AcqdatCore.Repo.Migrations.AlterFactTablesToMakeColumnsMetadataAsJsonb do
  use Ecto.Migration
  import Ecto.Query
  alias AcqdatCore.Repo

  def change do
    alter table("acqdat_fact_tables") do
      add(:columns_metadata_new, {:array, :map})
    end
    
    flush()
    
    query = from(ft in "acqdat_fact_tables", select: {ft.id, ft.columns_metadata})

    map_id_metadata = 
      query
      |> Repo.all()
      |> Enum.reduce(%{}, fn {id, columns_metadata}, acc ->
        Map.put(acc, id, columns_metadata)
      end)

    map_id_metadata
    |> Enum.each(fn {id, columns_metadata} ->
      query =
        from(ft in "acqdat_fact_tables",
          where: ft.id == ^id,
          update: [set: [columns_metadata_new: ^columns_metadata]]
        )

      Repo.update_all(query, [])
    end)

    alter table(:acqdat_fact_tables) do
      remove :columns_metadata
    end

    flush()

    rename table("acqdat_fact_tables"), :columns_metadata_new, to: :columns_metadata
  end
end
