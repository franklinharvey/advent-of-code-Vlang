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
	iter_count := 100
	mut flash_count := 0
	for _ in 1 .. iter_count + 1 {
		matrix = increment_matrix(matrix)
		for {
			if !matrix_has_greater_than_nine(matrix) {
				break
			}
			for y in 0 .. matrix.len {
				for x in 0 .. matrix[y].len {
					if matrix[y][x] > 9 {
						matrix = flash(matrix, y, x)
						flash_count++
					}
				}
			}
		}
		matrix = reset_flash_points(matrix)
	}
	println(flash_count)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn increment_matrix(matrix [][]int) [][]int {
	mut matrix_copy := matrix.clone()
	for i in 0 .. matrix_copy.len {
		row := matrix_copy[i]
		for j in 0 .. row.len {
			matrix_copy[i][j]++
		}
	}
	return matrix_copy
}

fn flash(matrix [][]int, y int, x int) [][]int {
	mut matrix_copy := matrix.clone()
	matrix_copy[y][x] = -1
	if x > 0 && matrix_copy[y][x - 1] != -1 {
		// left
		matrix_copy[y][x - 1]++
	}
	if x > 0 && y > 0 && matrix_copy[y - 1][x - 1] != -1 {
		// top left
		matrix_copy[y - 1][x - 1]++
	}
	if y > 0 && matrix_copy[y - 1][x] != -1 {
		// top center
		matrix_copy[y - 1][x]++
	}
	if x < matrix[0].len - 1 && y > 0 && matrix_copy[y - 1][x + 1] != -1 {
		// top right
		matrix_copy[y - 1][x + 1]++
	}
	if x < matrix[0].len - 1 && matrix_copy[y][x + 1] != -1 {
		// right
		matrix_copy[y][x + 1]++
	}
	if x < matrix[0].len - 1 && y < matrix.len - 1 && matrix_copy[y + 1][x + 1] != -1 {
		// bottom right
		matrix_copy[y + 1][x + 1]++
	}
	if y < matrix.len - 1 && matrix_copy[y + 1][x] != -1 {
		// bottom center
		matrix_copy[y + 1][x]++
	}
	if x > 0 && y < matrix.len - 1 && matrix_copy[y + 1][x - 1] != -1 {
		// bottom right
		matrix_copy[y + 1][x - 1]++
	}
	return matrix_copy
}

fn reset_flash_points(matrix [][]int) [][]int {
	mut matrix_copy := matrix.clone()
	for i in 0 .. matrix_copy.len {
		row := matrix_copy[i]
		for j in 0 .. row.len {
			if matrix_copy[i][j] == -1 {
				matrix_copy[i][j] = 0
			}
		}
	}
	return matrix_copy
}

fn matrix_has_greater_than_nine(matrix [][]int) bool {
	for row in matrix {
		for col in row {
			if col > 9 {
				return true
			}
		}
	}
	return false
}

fn test() {
	assert increment_matrix([[0, 1, 2], [0, 1, 2]]) == [[1, 2, 3],
		[1, 2, 3]]

	assert flash([[9, 1, 2], [0, 1, 2]], 0, 0) == [[-1, 2, 2],
		[1, 2, 2]]
	assert flash([[1, 1, 2], [0, 9, 2], [1, 1, 2]], 1, 1) == [
		[2, 2, 3],
		[1, -1, 3],
		[2, 2, 3],
	]

	assert reset_flash_points([
		[2, 2, 3],
		[1, -1, 3],
		[2, 2, 3],
	]) == [
		[2, 2, 3],
		[1, 0, 3],
		[2, 2, 3],
	]
}
