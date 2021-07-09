defmodule AcqdatCore.DataInsights.Domain.DataFilter do
  def filters_query(filters) when length(filters) > 0 do
    query =
      Enum.reduce(filters, "", fn filter, acc ->
        acc <> fetch_filter_action(filter) <> " AND "
      end)

    {query, _} = String.split_at(query, -4)
    "where #{query}"
  end

  def filters_query(_) do
    ""
  end

  defp fetch_filter_action(filter) do
    case filter["action"] do
      "equal" ->
        "\"#{filter["name"]}\" = #{filter["values"]}"

      "not equal" ->
        "\"#{filter["name"]}\" <> #{filter["values"]}"

      "less than" ->
        "\"#{filter["name"]}\" < #{filter["values"]}"

      "greater than" ->
        "\"#{filter["name"]}\" > #{filter["values"]}"

      "between" ->
        [innerbound, outerbound] = filter["values"]

        if filter["type"] == "timestamp without time zone" do
          "\"#{filter["name"]}\" >= CAST ( \'#{innerbound}\' AS timestamptz ) AND \"#{
            filter["name"]
          }\" <= CAST ( \'#{outerbound}\' AS timestamptz )"
        else
          "\"#{filter["name"]}\" >= #{innerbound} AND \"#{filter["name"]}\" <= #{outerbound}"
        end

      "is null" ->
        "\"#{filter["name"]}\" IS NULL"

      "is not null" ->
        "\"#{filter["name"]}\" IS NOT NULL"

      "is" ->
        values = filter["values"] |> Enum.map_join(",", fn k -> "\'#{k}\'" end)
        "\"#{filter["name"]}\" IN (#{values})"

      "is not" ->
        values = filter["values"] |> Enum.map_join(",", fn k -> "\'#{k}\'" end)
        "\"#{filter["name"]}\" NOT IN (#{values})"

      "contains" ->
        "\"#{filter["name"]}\" ILIKE ('%' || CAST ( \'#{filter["values"]}\' AS text ) || '%')"

      "does not contain" ->
        "NOT(\"#{filter["name"]}\" ILIKE ('%' || CAST ( \'#{filter["values"]}\' AS text ) || '%'))"

      "before" ->
        "\"#{filter["name"]}\" < CAST ( \'#{filter["values"]}\' AS timestamptz )"

      "after" ->
        "\"#{filter["name"]}\" > CAST ( \'#{filter["values"]}\' AS timestamptz )"

      "on" ->
        "\"#{filter["name"]}\"::date = CAST ( \'#{filter["values"]}\' AS timestamptz )"

      "last" ->
        interval = "\'#{filter["values_by"]} #{filter["values"]}\'"

        "(DATE_TRUNC ( 'hour', \"#{filter["name"]}\" ) < DATE_TRUNC ( 'hour', CURRENT_TIMESTAMP )) AND
        (DATE_TRUNC ( 'hour', \"#{filter["name"]}\" ) >= DATE_TRUNC ( 'hour', CURRENT_TIMESTAMP - INTERVAL #{
          interval
        } ))"

      "next" ->
        interval = "\'#{filter["values_by"]} #{filter["values"]}\'"

        "(DATE_TRUNC ( 'hour', \"#{filter["name"]}\" ) > DATE_TRUNC ( 'hour', CURRENT_TIMESTAMP )) AND
        (DATE_TRUNC ( 'hour', \"#{filter["name"]}\" ) <= DATE_TRUNC ( 'hour', CURRENT_TIMESTAMP + INTERVAL #{
          interval
        } ))"
    end
  end
end
