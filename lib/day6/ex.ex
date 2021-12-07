defmodule Aoc2021.Day6.Ex do
  @moduledoc """
  (some cleanup can be done and some self-discount on how the input must be here, e.g.
  I trust the winning number will complete only one board
  )
  """
  require Logger

  @path "support/day6/input.txt"
  @test_path "support/day6/input_test.txt"
  @days_part_1 80
  @days_part_2 256

  def start(part \\ 1, path \\ @path, opts \\ []) do
    # parse, returns commands already divided in {direction, value}
    content =
      path
      |> File.read!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    days =
      case Keyword.fetch(opts, :days) do
        :error ->
          case part do
            1 -> @days_part_1
            2 -> @days_part_2
          end

        {:ok, value} ->
          value
      end

    analyze(content, days)
  end

  def path, do: @path
  def test_path, do: @test_path

  defp empty_freqs, do: 0..8 |> Enum.reduce(%{}, fn idx, acc -> Map.put(acc, idx, 0) end)

  defp analyze(contents, days) do
    freqs =
      empty_freqs()
      |> Map.merge(Enum.frequencies(contents))

    # IO.inspect(freqs)

    res =
      0..(days - 1)
      |> Enum.reduce(freqs, fn _, current_freqs -> advance_day(current_freqs) end)
      |> Enum.reduce(0, fn {_, num_fishes}, acc -> acc + num_fishes end)

    Logger.info("Got [#{res}] fishes after [#{days}] days")
  end

  defp advance_day(freqs) do
    freqs
    |> Enum.flat_map(fn
      {days, num_fishes} when num_fishes > 0 ->
        case days do
          0 ->
            [{:+, 8, num_fishes}, {:+, 6, num_fishes}, {:-, 0, num_fishes}]

          num ->
            [{:+, num - 1, num_fishes}, {:-, num, num_fishes}]
        end

      {_days, _num_fishes} ->
        []
    end)
    # |> IO.inspect()
    |> Enum.reduce(
      freqs,
      fn {operation, days, num}, acc ->
        case operation do
          :+ -> Map.update!(acc, days, fn x -> x + num end)
          :- -> Map.update!(acc, days, fn x -> x - num end)
        end
      end
    )

    # |> IO.inspect()
  end
end
