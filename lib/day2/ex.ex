defmodule Aoc2021.Day2.Ex do
  @moduledoc """
  How many measurements are larger than the previous measurement?
  """
  require Logger

  @path "support/day2/input.txt"
  # result should be 7
  @test_path "support/day2/input_test.txt"

  def start(part \\ 1, path \\ @path) do
    # parse, returns commands already divided in {direction, value}
    content =
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        [direction, value] = String.split(row, " ")
        {direction, String.to_integer(value)}
      end)

    case part do
      1 -> analyze_part_1(content)
      2 -> analyze_part_2(content)
    end
  end

  def path, do: @path
  def test_path, do: @test_path

  defp analyze_part_1(contents) do
    {final_horizontal_position, final_depth} =
      contents
      |> Enum.reduce(
        {0, 0},
        fn {direction, value}, {horizontal_position, depth} ->
          case direction do
            "forward" -> {horizontal_position + value, depth}
            "down" -> {horizontal_position, depth + value}
            "up" -> {horizontal_position, depth - value}
          end
        end
      )

    final_horizontal_position * final_depth
  end

  defp analyze_part_2(contents) do
    {final_horizontal_position, final_depth, _final_aim} =
      contents
      |> Enum.reduce(
        {0, 0, 0},
        fn {direction, value}, {horizontal_position, depth, aim} ->
          case direction do
            "down" -> {horizontal_position, depth, aim + value}
            "up" -> {horizontal_position, depth, aim - value}
            "forward" -> {horizontal_position + value, depth + aim * value, aim}
          end
        end
      )

    final_horizontal_position * final_depth
  end
end
