defmodule Aoc2021.Day3.Ex do
  @moduledoc """
  How many measurements are larger than the previous measurement?
  """
  require Logger

  @path "support/day3/input.txt"
  # result should be 7
  @test_path "support/day3/input_test.txt"

  def start(part \\ 1, path \\ @path) do
    # parse, returns commands already divided in {direction, value}
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

  # I could avoid a lot of list conversion using graphemes and String.at as in the second part
  # Whatever :) ¯\_(ツ)_/¯
  defp analyze_part_1(contents) do
    gamma_rate_charlist =
      contents
      |> Enum.reduce(
        # frequency of 1s in each position, number of rows
        {%{}, 0},
        fn current, {freq_of_1s, num_rows} ->
          updated_freq =
            current
            |> String.to_charlist()
            |> Enum.with_index()
            |> Enum.reduce(freq_of_1s, &update_freq/2)

          {updated_freq, num_rows + 1}
        end
      )
      |> calculate_gamma_rate_charlist()

    epsilon_rate_charlist = binary_complement(gamma_rate_charlist)

    gamma_rate = gamma_rate_charlist |> List.to_string() |> String.to_integer(2)
    epsilon_rate = epsilon_rate_charlist |> List.to_string() |> String.to_integer(2)

    gamma_rate * epsilon_rate
  end

  defp update_freq({char, position}, %{} = acc) do
    case char do
      49 -> Map.update(acc, position, 1, fn count -> count + 1 end)
      48 -> acc
    end
  end

  defp calculate_gamma_rate_charlist({freq_of_1s, number_of_rows}) do
    freq_of_1s
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn idx ->
      freq = Map.get(freq_of_1s, idx)

      case freq / number_of_rows do
        num when num > 0.5 -> '1'
        _ -> '0'
      end
    end)
  end

  defp binary_complement(num_as_charlist) do
    num_as_charlist
    |> Enum.map(fn char ->
      case char do
        '1' -> '0'
        '0' -> '1'
      end
    end)
  end

  defp analyze_part_2(contents) do
    o2_rating = rate_values(contents, 0, :o2)
    co2_rating = rate_values(contents, 0, :co2)

    String.to_integer(o2_rating, 2) * String.to_integer(co2_rating, 2)
  end

  defp rate_values([content], _, _), do: content

  defp rate_values(contents, bit, flavour) do
    {zeroes, ones} = most_common_value(contents, bit)

    filtered_contents =
      Enum.reject(
        contents,
        fn content -> reject?(content, {zeroes, ones}, bit, flavour) end
      )

    rate_values(filtered_contents, bit + 1, flavour)
  end

  defp reject?(content, {zeroes, ones}, bit, :o2) do
    case String.at(content, bit) do
      "0" when zeroes > ones -> false
      "1" when ones > zeroes -> false
      "1" when ones == zeroes -> false
      _ -> true
    end
  end

  defp reject?(content, {zeroes, ones}, bit, :co2) do
    case String.at(content, bit) do
      "1" when zeroes > ones -> false
      "0" when ones > zeroes -> false
      "0" when ones == zeroes -> false
      _ -> true
    end
  end

  defp most_common_value(contents, bit) do
    Enum.reduce(
      contents,
      # zeroes, ones
      {0, 0},
      fn content, {zeroes, ones} ->
        case String.at(content, bit) do
          "0" -> {zeroes + 1, ones}
          "1" -> {zeroes, ones + 1}
        end
      end
    )
  end
end
