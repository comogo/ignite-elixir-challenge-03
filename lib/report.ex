defmodule Report do
  @moduledoc """
  Report generator
  """
  alias Report.Parser

  @initial_state %{all_hours: %{}, hours_per_month: %{}, hours_per_year: %{}}

  @doc """
  Reads the csv file and generates the report.
  """
  @spec build(String.t()) :: map()
  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(@initial_state, &process_item/2)
  end

  defp process_item(item, report) do
    %{
      report
      | all_hours: sum_all_hours(report, item),
        hours_per_month: sum_month(report, item),
        hours_per_year: sum_year(report, item)
    }
  end

  defp sum_all_hours(%{all_hours: all_hours}, %{name: name, hours: hours}) do
    all_hours
    |> insert_or_sum(name, hours)
  end

  defp sum_month(%{hours_per_month: hours_per_month}, %{name: name, hours: hours, month: month}) do
    hours_per_month
    |> nested_insert_or_sum(name, month, hours)
  end

  defp sum_year(%{hours_per_year: hours_per_year}, %{name: name, hours: hours, year: year}) do
    hours_per_year
    |> nested_insert_or_sum(name, year, hours)
  end

  defp insert_or_sum(map, key, hours) do
    map
    |> Map.update(key, hours, &(&1 + hours))
  end

  defp nested_insert_or_sum(map, outer_key, inner_key, hours) do
    map
    |> Map.update(outer_key, %{inner_key => hours}, &insert_or_sum(&1, inner_key, hours))
  end
end
