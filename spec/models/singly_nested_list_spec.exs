defmodule SinglyNestedListSpec do
  use ESpec
  alias DotsServer.SinglyNestedList

  let(:singly_nested_list) do
    [
      [1,2,3],
      [3,2,9]
    ]
  end

  describe "parse(nested_list_data)" do
    it "converts SinglyNestedList data into a SingleNestedList object" do
      "[[1,2,3],[3,2,1]]"
      |> SinglyNestedList.parse
      |> should(eq [[1,2,3], [3,2,1]])
    end
  end

  describe "data(nested_list)" do
    it "converts SinglyNestedList object into a SingleNestedList data" do
      singly_nested_list
      |> SinglyNestedList.data
      |> should(eq "[[1,2,3],[3,2,9]]")
    end
  end

  describe "at(nested_list, point)" do
    it "returns the value at the point" do
      singly_nested_list
      |> SinglyNestedList.at({2, 1})
      |> should(eq 9)
    end

    it "returns :out_of_bounds if the point is not valid for the singly_nested_list" do
      singly_nested_list
      |> SinglyNestedList.at({3, 1})
      |> should(eq :out_of_bounds)

      singly_nested_list
      |> SinglyNestedList.at({1, 3})
      |> should(eq :out_of_bounds)
    end

  end

  describe "replace_at(nested_list, point, value)" do
    it "replaces the element at point with value" do
      singly_nested_list
      |> SinglyNestedList.replace_at({2, 1}, 100)
      |> SinglyNestedList.at({2, 1})
      |> should(eq 100)
    end

    it "returns :out_of_bounds if the point is not valid for the singly_nested_list" do
      singly_nested_list
      |> SinglyNestedList.replace_at({3, 2}, 100)
      |> should(eq :out_of_bounds)
    end
  end

  describe "deep_map(list, fun)" do
    it "maps over each element and returns a singly_nested_list" do
      expected = [
        [2,4,6],
        [6,4,18]
      ]

      mapped = SinglyNestedList.deep_map singly_nested_list, fn(x) -> x * 2 end
      mapped |> should(eq expected)
    end
  end
end
