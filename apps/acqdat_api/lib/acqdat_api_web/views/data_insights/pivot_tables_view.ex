defmodule AcqdatApiWeb.DataInsights.PivotTablesView do
  alias AcqdatApiWeb.DataInsights.PivotTablesView
  use AcqdatApiWeb, :view

  def render("pivot_table_data.json", %{pivot_table: pivot_table}) do
    %{
      pivot_table: pivot_table
    }
  end

  def render("create.json", %{pivot_table: pivot_table}) do
    %{
      id: pivot_table.id,
      name: pivot_table.name,
      fact_table_headers: pivot_table.fact_table_headers
    }
  end

  def render("pivot_table.json", %{pivot_tables: pivot_table}) do
    %{
      id: pivot_table.id,
      name: pivot_table.name,
      project_id: pivot_table.project_id,
      org_id: pivot_table.org_id,
      slug: pivot_table.slug,
      uuid: pivot_table.uuid,
      filters: pivot_table.filters,
      columns: pivot_table.columns,
      rows: pivot_table.rows,
      values: pivot_table.values,
      created_at: pivot_table.inserted_at,
      creator: render_one(pivot_table.creator, PivotTablesView, "creator.json")
    }
  end

  def render("show.json", %{pivot_table: pivot_table}) do
    %{
      id: pivot_table.id,
      name: pivot_table.name,
      project_id: pivot_table.project_id,
      org_id: pivot_table.org_id,
      slug: pivot_table.slug,
      uuid: pivot_table.uuid,
      filters: pivot_table.filters,
      columns: pivot_table.columns,
      rows: pivot_table.rows,
      values: pivot_table.values,
      created_at: pivot_table.inserted_at,
      fact_table_headers: pivot_table.fact_table_headers
    }
  end

  def render("creator.json", %{pivot_tables: creator}) do
    %{
      id: creator.id,
      email: creator.email,
      first_name: creator.first_name,
      last_name: creator.last_name
    }
  end

  def render("show.json", %{pivot_table: pivot_table}) do
    %{
      id: pivot_table.id,
      name: pivot_table.name,
      project_id: pivot_table.project_id,
      org_id: pivot_table.org_id,
      slug: pivot_table.slug,
      uuid: pivot_table.uuid,
      filters: pivot_table.filters,
      columns: pivot_table.columns,
      rows: pivot_table.rows,
      values: pivot_table.values
    }
  end

  def render("index.json", pivot_tables) do
    %{
      pivot_tables: render_many(pivot_tables.entries, PivotTablesView, "pivot_table.json"),
      page_number: pivot_tables.page_number,
      page_size: pivot_tables.page_size,
      total_entries: pivot_tables.total_entries,
      total_pages: pivot_tables.total_pages
    }
  end
end
