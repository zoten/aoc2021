defmodule Aoc2021.Day7.Ex do
  @moduledoc """
  (some cleanup can be done and some self-discount on how the input must be here, e.g.
  I trust the winning number will complete only one board
  )
  """
  require Logger

  @path "support/day7/input.txt"
  @test_path "support/day7/input_test.txt"

  def start(part \\ 1, path \\ @path) do
    # parse, returns commands already divided in {direction, value}
    content =
      path
      |> File.read!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()

    case part do
      1 -> analyze_part_1(content)
      2 -> analyze_part_2(content)
    end
  end

  def path, do: @path
  def test_path, do: @test_path

  defp calculate_median(sorted_contents) do
    Enum.at(sorted_contents, ceil(length(sorted_contents) / 2))
  end

  defp calculate_average(sorted_contents) do
    {sum, len} =
      sorted_contents
      |> Enum.reduce({0, 0}, fn num, {sum, len} -> {num + sum, len + 1} end)

    {
      floor(sum / len),
      ceil(sum / len)
    }
  end

  defp analyze_part_1(contents) do
    median =
      contents
      |> calculate_median()

    calculate_fuel_consumption(contents, median)
  end

  defp calculate_fuel_consumption(contents, value),
    do: Enum.reduce(contents, 0, fn num, acc -> acc + abs(num - value) end)

  defp calculate_fuel_consumption_part_2(contents, value) do
    Enum.reduce(contents, 0, fn num, acc ->
      distance = abs(num - value)
      acc + distance * (distance + 1) / 2
    end)
  end

  defp brute_force_part_2(contents) do
    contents
    |> Enum.reduce(
      {nil, nil},
      fn num, {winner, min_fuel_consumption} ->
        consumption = calculate_fuel_consumption_part_2(contents, num)

        cond do
          consumption < min_fuel_consumption -> {num, consumption}
          min_fuel_consumption -> {winner, min_fuel_consumption}
        end
      end
    )
  end

  defp analyze_part_2(contents) do
    # As comments on reddit shows, average is not the correct answer (it minimizes distance^2 and not distance * (distance + 1)/2)
    # However, it is "close enough" and needs some rounding on some data sets
    {min, max} = calculate_average(contents)

    # Right answer is 95581659. I don't have an explanation.

    {
      {Enum.find(contents, :undefined, fn x -> x == min end),
       calculate_fuel_consumption_part_2(contents, min)},
      {Enum.find(contents, :undefined, fn x -> x == max end),
       calculate_fuel_consumption_part_2(contents, max)},
      {:brute_force, brute_force_part_2(contents)}
    }
  end
end
