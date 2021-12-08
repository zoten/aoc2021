defmodule Aoc2021.Day5.Ex do
  @moduledoc """
  (I absolutely dislike this solution, but could not find a decently readable geometric one)
  """
  require Logger

  @path "support/day5/input.txt"
  @test_path "support/day5/input_test.txt"

  def start(part \\ 1, path \\ @path) do
    content =
      path
      |> File.read!()
      |> String.split("\n", trim: true)

    case part do
      1 -> analyze_part_1(content)
      2 -> analyze_part_2(content)
    end
  end

  def path, do: @path
  def test_path, do: @test_path

  defp analyze_part_1(contents) do
    contents
    |> parse_file()
    |> take_only_vertical_horizontal()
    |> Enum.flat_map(&generate_segment_points/1)
    |> Enum.frequencies()
    |> Enum.reject(fn {_value, freq} -> freq <= 1 end)
    |> Enum.count()
  end

  defp analyze_part_2(contents) do
    contents
    |> parse_file()
    |> Enum.flat_map(&generate_segment_points/1)
    |> Enum.frequencies()
    |> Enum.reject(fn {_value, freq} -> freq <= 1 end)
    |> Enum.count()
  end

  defp take_only_vertical_horizontal(points) do
    Enum.reject(
      points,
      fn {{x0, y0}, {x1, y1}} ->
        x0 != x1 and y0 != y1
      end
    )
  end

  defp generate_segment_points({{x0, y0}, {x1, y1}}) when x0 == x1,
    do: Enum.map(y0..y1, fn y -> {x0, y} end)

  defp generate_segment_points({{x0, y0}, {x1, y1}}) when y0 == y1,
    do: Enum.map(x0..x1, fn x -> {x, y0} end)

  # diagonal
  defp generate_segment_points({{x0, y0}, {x1, y1}}) do
    Enum.zip([x0..x1, y0..y1])
  end

  defp parse_file(lines) do
    lines
    |> Enum.flat_map(fn line ->
      line |> String.split("->")
    end)
    |> Enum.flat_map(fn chunk ->
      chunk
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.chunk_every(4)
    |> Enum.map(fn [x0, y0, x1, y1] -> {{x0, y0}, {x1, y1}} end)
  end
end
