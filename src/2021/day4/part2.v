import os

struct Square {
mut:
	value  int
	marked bool
}

struct Board {
mut:
	squares [][]Square
}

fn main() {
	test()
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	lines := extract_lines(f)
	first_line := lines.first()
	instructions := extract_instructions(first_line)
	mut boards := get_bingo_boards(lines[1..])
	winning_board, instruction := find_winning_board(instructions, boards)?
	sum := sum_unmarked_squares(winning_board)
	println(sum * instruction)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn sum_unmarked_squares(board Board) int {
	mut sum := 0
	for row in board.squares {
		for col in row {
			if !col.marked {
				sum += col.value
			}
		}
	}
	return sum
}

fn find_winning_board(instructions []int, boards []Board) ?(Board, int) {
	mut new_boards := boards.clone()
	mut winning_board := Board{}
	mut winning_ins := -1
	for instruction in instructions {
		for i in 0 .. new_boards.len {
			new_boards[i] = mark_squares_on_board(new_boards[i], instruction)
		}
		for board in new_boards {
			if is_winner(board) {
				winning_board = board
				winning_ins = instruction
			}
		}
		new_boards = new_boards.filter(!is_winner(it))
	}
	return winning_board, winning_ins
}

fn extract_instructions(line string) []int {
	return line.split(',').map(it.int())
}

fn get_bingo_boards(lines []string) []Board {
	mut row_num := 0
	mut current_board := Board{[[]Square{}, []Square{}, []Square{},
		[]Square{}, []Square{}]}
	mut acc_boards := []Board{}
	for line in lines {
		if line.len == 0 {
			row_num = 0
			current_board = Board{[[]Square{}, []Square{}, []Square{},
				[]Square{}, []Square{}]}
		} else {
			squares := parse_bingo_row(line).map(Square{it, false})
			current_board.squares[row_num] = squares
			row_num++
		}

		if row_num == 5 {
			acc_boards << current_board
		}
	}
	return acc_boards
}

fn parse_bingo_row(line string) []int {
	return line.replace('  ', ' ').split(' ').map(it.int())
}

fn mark_squares_on_board(board Board, value int) Board {
	mut new_board := Board{board.squares}
	for j in 0 .. new_board.squares.len {
		for i in 0 .. new_board.squares[j].len {
			if new_board.squares[j][i].value == value {
				new_board.squares[j][i].marked = true
			}
		}
	}
	return board
}

fn is_winner(board Board) bool {
	// win by row
	for row in board.squares {
		if row.all(it.marked == true) {
			return true
		}
	}
	// win by col
	for i in 0 .. 5 {
		if [board.squares[0][i], board.squares[1][i], board.squares[2][i], board.squares[3][i],
			board.squares[4][i]].all(it.marked == true)
		{
			return true
		}
	}
	return false
}

fn test() {
	assert parse_bingo_row('1 2 3 4 5') == [1, 2, 3, 4, 5]
	assert parse_bingo_row('1  2 3 4 5') == [1, 2, 3, 4, 5]
	assert get_bingo_boards([
		'5 54 87 34  3',
		'96 12 67  6 14',
		'1 43 92 35 49',
		'31 72 65 85  2',
		'75 81 26 28  4',
	]) == [
		Board{[
			[5, 54, 87, 34, 3].map(Square{it, false}),
			[96, 12, 67, 6, 14].map(Square{it, false}),
			[1, 43, 92, 35, 49].map(Square{it, false}),
			[31, 72, 65, 85, 2].map(Square{it, false}),
			[75, 81, 26, 28, 4].map(Square{it, false}),
		]},
	]
	assert mark_squares_on_board(Board{[
		[5, 54, 87, 34, 3].map(Square{it, false}),
		[96, 12, 67, 6, 14].map(Square{it, false}),
		[1, 43, 92, 35, 49].map(Square{it, false}),
		[31, 72, 65, 85, 2].map(Square{it, false}),
		[75, 81, 26, 28, 4].map(Square{it, false}),
	]}, 5) == Board{[
		[5, 54, 87, 34, 3].map(Square{it, it == 5}),
		[96, 12, 67, 6, 14].map(Square{it, false}),
		[1, 43, 92, 35, 49].map(Square{it, false}),
		[31, 72, 65, 85, 2].map(Square{it, false}),
		[75, 81, 26, 28, 4].map(Square{it, false}),
	]}
	assert is_winner(Board{[
		[5, 54, 87, 34, 3].map(Square{it, true}),
		[96, 12, 67, 6, 14].map(Square{it, false}),
		[1, 43, 92, 35, 49].map(Square{it, false}),
		[31, 72, 65, 85, 2].map(Square{it, false}),
		[75, 81, 26, 28, 4].map(Square{it, false}),
	]}) == true
	assert is_winner(Board{[
		[5, 54, 87, 34, 3].map(Square{it, it == 5}),
		[96, 12, 67, 6, 14].map(Square{it, it == 96}),
		[1, 43, 92, 35, 49].map(Square{it, it == 1}),
		[31, 72, 65, 85, 2].map(Square{it, it == 31}),
		[75, 81, 26, 28, 4].map(Square{it, it == 75}),
	]}) == true
	assert is_winner(Board{[
		[5, 54, 87, 34, 3].map(Square{it, it == 5}),
		[96, 12, 67, 6, 14].map(Square{it, false}),
		[1, 43, 92, 35, 49].map(Square{it, it == 1}),
		[31, 72, 65, 85, 2].map(Square{it, it == 31}),
		[75, 81, 26, 28, 4].map(Square{it, it == 75}),
	]}) == false
	assert extract_instructions('1,2,3') == [1, 2, 3]
	assert sum_unmarked_squares(Board{[
		[1, 0, 0, 0, 0].map(Square{it, false}),
		[0, 0, 0, 0, 0].map(Square{it, false}),
		[0, 0, 0, 0, 0].map(Square{it, false}),
		[0, 0, 0, 0, 0].map(Square{it, false}),
		[0, 0, 0, 0, 0].map(Square{it, false}),
	]}) == 1
	assert sum_unmarked_squares(Board{[
		[10, 10, 10, 10, 10].map(Square{it, true}),
		[10, 10, 10, 10, 10].map(Square{it, false}),
		[10, 10, 10, 10, 10].map(Square{it, false}),
		[10, 10, 10, 10, 10].map(Square{it, false}),
		[10, 10, 10, 10, 10].map(Square{it, false}),
	]}) == 10 * 5 * 4
}
