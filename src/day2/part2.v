import os
import strconv

struct Position {
	horizontal int
	depth      int
	aim        int
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
		// don't change aim
		// change forward by ins.amount
		// change depth by depth + (aim * ins.amount)
		return Position{initial_pos.horizontal + ins.amount, initial_pos.depth +
			(ins.amount * initial_pos.aim), initial_pos.aim}
	} else if ins.direction == 'down' {
		// change aim by amount
		return Position{initial_pos.horizontal, initial_pos.depth, initial_pos.aim + ins.amount}
	} else if ins.direction == 'up' {
		// change aim by amount * -1
		return Position{initial_pos.horizontal, initial_pos.depth, initial_pos.aim - ins.amount}
	}
	return initial_pos
}

fn test() {
	// forward no aim
	assert move_position(Position{}, Instruction{'forward', 10}) == Position{10, 0, 0}
	// change aim
	assert move_position(Position{}, Instruction{'up', 10}) == Position{0, 0, -10}
	// forward with aim
	assert move_position(Position{0, 0, 20}, Instruction{'forward', 10}) == Position{10, 10 * 20, 20}
}
