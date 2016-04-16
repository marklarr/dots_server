defmodule DotsServer.SinglyNestedList do
  @out_of_bounds :out_of_bounds

  def parse(nested_list_data), do: Poison.decode!(nested_list_data)
  def data(nested_list), do: Poison.encode!(nested_list)

  def replace_at(nested_list, {x, y}, value) do
    case at(nested_list, {x, y}) do
      @out_of_bounds -> @out_of_bounds
      _value ->
        new_row = nested_list
                  |> Enum.at(y)
                  |> List.replace_at(x, value)

        List.replace_at(nested_list, y, new_row)
    end
  end

  def at(nested_list, {x, y}) do
    case Enum.at(nested_list, y) do
      nil -> @out_of_bounds
      row ->
        case Enum.count(row) do
          count when (count - 1) >= x -> Enum.at(row, x)
          count when (count - 1) < x -> @out_of_bounds
        end
    end
  end
end
