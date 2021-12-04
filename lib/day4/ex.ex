defmodule Aoc2021.Day4.Ex do
  @moduledoc """
  (some cleanup can be done and some self-discount on how the input must be here, e.g.
  I trust the winning number will complete only one board
  )
  """
  require Logger

  @path "support/day4/input.txt"
  @test_path "support/day4/input_test.txt"

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

  defp analyze_part_1(contents) do
    state = parse_file(contents)
    draw_numbers(state.numbers, state.boards)
  end

  defp analyze_part_2(contents) do
    state = parse_file(contents)
    draw_numbers_to_the_end(state.numbers, state.boards, nil, nil)
  end

  # for part 2, let's go to the last winning
  defp draw_numbers_to_the_end([], _boards, _, nil), do: Logger.error("No winner :(")

  defp draw_numbers_to_the_end([], _boards, last_winning_number, last_winning_board),
    do: calculate_result(last_winning_board, last_winning_number)

  defp draw_numbers_to_the_end(
         [number | numbers],
         boards,
         last_winning_number,
         last_winning_board
       ) do
    # set numbers as found
    # here it is assumed no two boards will complete at the same time, so the match will fail later in the case if it is not the case
    {non_winning_boards, winning_boards} =
      boards
      |> Enum.map(fn board ->
        mark_found(number, board)
      end)
      |> Enum.reduce(
        {[], []},
        fn board, {non_winning_boards, winning_boards} ->
          case winning_board?(board) do
            :nope -> {[board | non_winning_boards], winning_boards}
            :winner -> {non_winning_boards, [board | winning_boards]}
          end
        end
      )

    case winning_boards do
      [] ->
        draw_numbers_to_the_end(
          numbers,
          non_winning_boards,
          last_winning_number,
          last_winning_board
        )

      [new_last_winning_board | _] ->
        draw_numbers_to_the_end(numbers, non_winning_boards, number, new_last_winning_board)
    end
  end

  defp draw_numbers([], _boards), do: Logger.error("No winner :(")

  defp draw_numbers([number | numbers], boards) do
    # set numbers as found
    new_boards =
      boards
      |> Enum.map(fn board ->
        mark_found(number, board)
      end)

    case winning_boards?(new_boards) do
      :nope -> draw_numbers(numbers, new_boards)
      {:winner, board} -> calculate_result(board, number)
    end
  end

  defp calculate_result(board, number) do
    res =
      board
      |> Enum.reject(fn {_number, found} -> found end)
      |> Enum.reduce(0, fn {num, _found}, acc -> acc + num end)

    res * number
  end

  defp winning_boards?(boards) do
    Enum.reduce_while(
      boards,
      :nope,
      fn board, _ ->
        case winning_board?(board) do
          :winner -> {:halt, {:winner, board}}
          :nope -> {:cont, :nope}
        end
      end
    )
  end

  defp winning_board?(board) do
    rows = Enum.chunk_every(board, 5)

    columns =
      Enum.map(0..4, fn idx ->
        Enum.map(rows, fn row -> Enum.at(row, idx) end)
      end)

    if winning?(rows) or winning?(columns) do
      :winner
    else
      :nope
    end
  end

  defp winning?(rows) do
    Enum.reduce_while(rows, :nope, fn row, _ ->
      if Enum.all?(row, fn {_, found} -> found end) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  defp mark_found(number, board) do
    Enum.map(
      board,
      fn
        {board_number, _} when board_number == number -> {number, true}
        {board_number, found} -> {board_number, found}
      end
    )
  end

  # mini state machine
  defp parse_file(lines) do
    parse_file(lines, :header)
  end

  defp parse_file([header | lines], :header) do
    numbers = header |> String.split(",") |> Enum.map(&String.to_integer/1)
    boards = parse_file(lines, :boards)

    %{
      numbers: numbers,
      boards: boards
    }
  end

  defp parse_file(lines, :boards) do
    # Each line is 5x5, so we can easily take 5 rows and flatten them
    # we ofoc avoid overcomplicating with streams etc since the memory used is few
    boards =
      lines
      |> Enum.chunk_every(5)
      |> Enum.map(fn rows ->
        rows
        |> Enum.flat_map(fn row ->
          row
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)
          |> Enum.map(fn x -> {x, false} end)
        end)
      end)

    boards
  end
end
