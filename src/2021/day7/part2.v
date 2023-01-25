import os

fn main() {
	test()
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut positions := extract_positions(f)
	min, max := get_min_and_max_starting_position(positions)

	mut lowest_cost := calculate_move_cost_for_group(positions, min)
	for pos in min .. max + 1 {
		cost_for_group := calculate_move_cost_for_group(positions, pos)
		if cost_for_group < lowest_cost {
			lowest_cost = cost_for_group
		}
	}

	println(lowest_cost)
}

fn extract_positions(contents string) []int {
	return contents.split(',').map(it.int())
}

fn calculate_move_cost_for_position(position int, new_position int) int {
	mut num_of_moves := 0
	if position < new_position {
		num_of_moves = new_position - position
	} else {
		num_of_moves = position - new_position
	}

	mut cost := 0
	for i in 1 .. num_of_moves + 1 {
		cost = cost + i
	}
	return cost
}

fn calculate_move_cost_for_group(positions []int, new_position int) int {
	mut sum := 0
	for pos in positions {
		sum += calculate_move_cost_for_position(pos, new_position)
	}
	return sum
}

fn get_min_and_max_starting_position(positions []int) (int, int) {
	mut min := positions[0]
	mut max := positions[0]
	for pos in positions {
		if pos < min {
			min = pos
		}
		if pos > max {
			max = pos
		}
	}
	return min, max
}

fn test() {
	assert extract_positions('0,2,3') == [0, 2, 3]

	assert calculate_move_cost_for_position(4, 5) == 1
	assert calculate_move_cost_for_position(1, 5) == 10
	assert calculate_move_cost_for_position(16, 5) == 66

	mut min, mut max := get_min_and_max_starting_position([1, 2, 3, 4])
	assert min == 1
	assert max == 4

	min, max = get_min_and_max_starting_position([4, 3, 2, 1])
	assert min == 1
	assert max == 4

	assert calculate_move_cost_for_group([1, 1, 1], 2) == 3
	assert calculate_move_cost_for_group([1, 2, 3], 2) == 2
	assert calculate_move_cost_for_group([16, 1, 2, 0, 4, 2, 7, 1, 2, 14], 5) == 168
}
