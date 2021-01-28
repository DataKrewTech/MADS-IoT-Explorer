defmodule AcqdatApiWeb.DataInsights.FactTablesView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.FactTablesView

  def render("create.json", %{fact_table: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name
    }
  end

  def render("fact_table_data.json", %{fact_table: fact_table}) do
    %{
      fact_table: fact_table
    }
  end

  def render("fact_table.json", %{fact_tables: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name,
      columns_metadata: fact_table.columns_metadata,
      project_id: fact_table.project_id,
      org_id: fact_table.org_id,
      slug: fact_table.slug,
      uuid: fact_table.uuid,
      pivot_count: fact_table.pivot_count,
      created_at: fact_table.inserted_at,
      creator: render_one(fact_table.creator, FactTablesView, "creator.json")
    }
  end

  def render("fact_table.json", %{fact_table: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name,
      columns_metadata: fact_table.columns_metadata,
      project_id: fact_table.project_id,
      org_id: fact_table.org_id,
      slug: fact_table.slug,
      uuid: fact_table.uuid,
      pivot_count: fact_table.pivot_count,
      created_at: fact_table.inserted_at
    }
  end

  def render("fact_table_details.json", %{fact_table: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name,
      columns_metadata: fact_table.columns_metadata,
      fact_table_headers: fact_table.fact_table_headers,
      project_id: fact_table.project_id,
      org_id: fact_table.org_id,
      slug: fact_table.slug,
      uuid: fact_table.uuid,
      pivot_count: fact_table.pivot_count,
      created_at: fact_table.inserted_at,
      date_range_settings: fact_table.date_range_settings
    }
  end

  def render("creator.json", %{fact_tables: creator}) do
    %{
      id: creator.id,
      email: creator.email,
      first_name: creator.first_name,
      last_name: creator.last_name
    }
  end

  def render("index.json", fact_tables) do
    %{
      fact_tables: render_many(fact_tables.entries, FactTablesView, "fact_table.json"),
      page_number: fact_tables.page_number,
      page_size: fact_tables.page_size,
      total_entries: fact_tables.total_entries,
      total_pages: fact_tables.total_pages,
      total_pivot_tables: fact_tables.total_pivot_tables
    }
  end
end
