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

	lines := extract_lines(f)
	x_len := lines[0].len
	y_len := lines.len
	mut matrix := [][]int{len: y_len, init: []int{len: x_len}}
	for i in 0 .. y_len {
		line := lines[i]
		for j in 0 .. line.len {
			matrix[i][j] = line[j].ascii_str().int()
		}
	}
	mut sum := 0
	for i in 0 .. matrix.len {
		row := matrix[i]
		for j in 0 .. row.len {
			col := row[j]
			if is_low_point(matrix, j, i) {
				sum += col + 1
			}
		}
	}
	println(sum)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn is_low_point(matrix [][]int, x int, y int) bool {
	point := matrix[y][x]
	mut left := point + 1
	mut up := point + 1
	mut right := point + 1
	mut down := point + 1
	if x > 0 {
		left = matrix[y][x - 1]
	}
	if y > 0 {
		up = matrix[y - 1][x]
	}
	if x < matrix[0].len - 1 {
		right = matrix[y][x + 1]
	}
	if y < matrix.len - 1 {
		down = matrix[y + 1][x]
	}
	return point < left && point < up && point < right && point < down
}

fn test() {
	test_matrix := [[2, 1, 9], [3, 9, 8], [9, 8, 5]]
	assert is_low_point(test_matrix, 0, 0) == false
	assert is_low_point(test_matrix, 0, 1) == false
	assert is_low_point(test_matrix, 1, 0) == true
	assert is_low_point(test_matrix, 2, 2) == true
}
