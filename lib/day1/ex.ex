defmodule Aoc2021.Day1.Ex do
  @moduledoc """
  How many measurements are larger than the previous measurement?
  """
  require Logger

  @path "support/day1/input.txt"
  # result should be 7
  @test_path "support/day1/input_test.txt"

  def start(part \\ 1, path \\ @path) do
    content =
      path |> File.read!() |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

    case part do
      1 -> analyze_part_1(content)
      2 -> analyze_part_2(content)
    end
  end

  def path, do: @path
  def test_path, do: @test_path

  defp analyze_part_1(contents) do
    {_, res} =
      Enum.reduce(
        contents,
        # previous, sum
        {nil, 0},
        fn
          current, {nil, acc} -> {current, acc}
          current, {previous, acc} when current > previous -> {current, acc + 1}
          current, {_previous, acc} -> {current, acc}
        end
      )

    res
  end

  defp analyze_part_2(contents) do
    contents
    # sliding window
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn [x, y, z] -> x + y + z end)
    |> analyze_part_1()
  end

  # Lol, I misread the question. This still remains a nice exercise, reverse engineer it to see that I misunderstood :D
  # defp analyze_part_2(contents) do
  #   {_current, prev_window_sum, curr_window_sum, acc} =
  #     Enum.reduce(
  #       contents,
  #       # previous element, sum of previous window, sum of current window, sum of increased windows
  #       {nil, 0, 0, 0},
  #       fn
  #         # first iteration
  #         current, {nil, 0, 0, 0} ->
  #           {current, 0, current, 0}

  #         # we are building the current window
  #         current, {prev_element, prev_window_sum, curr_window_sum, acc}
  #         when current > prev_element ->
  #           {current, prev_window_sum, curr_window_sum + current, acc}

  #         # a window has closed
  #         current, {_prev_element, prev_window_sum, curr_window_sum, acc} ->
  #           IO.puts("************")
  #           IO.inspect(prev_window_sum)
  #           IO.inspect(curr_window_sum)
  #           IO.inspect(acc)

  #           if curr_window_sum > prev_window_sum do
  #             {current, curr_window_sum, current, acc + 1}
  #           else
  #             {current, curr_window_sum, current, acc}
  #           end
  #       end
  #     )

  #   # is there a more elegant way to express this?
  #   if curr_window_sum > prev_window_sum do
  #     acc + 1
  #   else
  #     acc
  #   end
  # end
end
