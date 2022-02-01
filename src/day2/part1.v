import os
import strconv

struct Position {
	horizontal int
	depth      int
}

struct Instruction {
	direction string // forward, down, up
	amount    int
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

	mut position := Position{}
	directions := extract_lines(f)
	for dir in directions {
		position = move_position(position, dir)
	}
	println(position.depth * position.horizontal)
}

fn extract_lines(contents string) []Instruction {
	mut lines := []Instruction{}
	for one_line_of_file in contents.split('\n') {
		line_split_by_space := one_line_of_file.split(' ')
		direction := line_split_by_space[0]
		amount := strconv.atoi(line_split_by_space[1]) or { panic('cannot parse number') }
		lines << Instruction{direction, amount}
	}
	return lines
}

fn move_position(initial_pos Position, ins Instruction) Position {
	if ins.direction == 'forward' {
		return Position{initial_pos.horizontal + ins.amount, initial_pos.depth}
	} else if ins.direction == 'down' {
		return Position{initial_pos.horizontal, initial_pos.depth + ins.amount}
	} else if ins.direction == 'up' {
		if initial_pos.depth <= 0 {
			return initial_pos
		}
		return Position{initial_pos.horizontal, initial_pos.depth - ins.amount}
	}
	return initial_pos
}

fn test() {
	assert move_position(Position{}, Instruction{'forward', 10}) == Position{10, 0}
	assert move_position(Position{10, 10}, Instruction{'down', 10}) == Position{10, 20}
	assert move_position(Position{}, Instruction{'up', 10}) == Position{0, 0}
}
