import os

struct Coordinate {
	x int
	y int
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
	coord_pairs := lines.map(extract_and_sort_coords(it))
	_, _, max_x, max_y := find_coordinate_plane(coord_pairs)

	straight_coord_pairs := coord_pairs.filter(is_straight_line(it))
	diag_coord_pairs := coord_pairs.filter(!is_straight_line(it))

	// create coordinate matrix
	mut plane := generate_coord_plane(max_x, max_y)
	// fill in with coverred points
	plane = fill_plane_from_straight_pairs(plane, straight_coord_pairs)
	plane = fill_plane_from_diag_pairs(plane, diag_coord_pairs)
	// count points >= 2
	println(count_points_on_plane_gte_n(plane, 2))
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn extract_and_sort_coords(line string) []Coordinate {
	// "419,207 -> 419,109"
	first_coord_unparsed := line.split(' -> ')[0]
	second_coord_unparsed := line.split(' -> ')[1]

	first_coord := Coordinate{first_coord_unparsed.split(',')[0].int(), first_coord_unparsed.split(',')[1].int()}
	second_coord := Coordinate{second_coord_unparsed.split(',')[0].int(), second_coord_unparsed.split(',')[1].int()}

	if first_coord.x > second_coord.x {
		return [second_coord, first_coord]
	} else if first_coord.y > second_coord.y {
		return [second_coord, first_coord]
	}

	return [first_coord, second_coord]
}

fn is_straight_line(coords []Coordinate) bool {
	first_coord := coords[0]
	second_coord := coords[1]
	return first_coord.x == second_coord.x || first_coord.y == second_coord.y
}

fn find_coordinate_plane(coord_pairs [][]Coordinate) (int, int, int, int) {
	mut min_x := 0
	mut min_y := 0
	mut max_x := 0
	mut max_y := 0
	for pair in coord_pairs {
		// min
		if pair[0].x < min_x {
			min_x = pair[0].x
		}
		if pair[0].y < min_y {
			min_y = pair[0].y
		}
		if pair[1].x < min_x {
			min_x = pair[1].x
		}
		if pair[1].y < min_y {
			min_y = pair[1].y
		}
		// max
		if pair[0].x > max_x {
			max_x = pair[0].x
		}
		if pair[0].y > max_y {
			max_y = pair[0].y
		}
		if pair[1].x > max_x {
			max_x = pair[1].x
		}
		if pair[1].y > max_y {
			max_y = pair[1].y
		}
	}
	return min_x, min_y, max_x, max_y
}

fn generate_coord_plane(max_x int, max_y int) [][]int {
	// ignores min intentionally
	// we want to generate 0,0 to keep things simple
	// e.g if we had min_x = 100, min_y = 100, max_x = 1000, max_y == 1000
	// we dont want to start our grid at 100
	return [][]int{len: max_x + 1, init: []int{len: max_y + 1}}
}

fn fill_plane_from_straight_line(plane [][]int, coord_pair []Coordinate) [][]int {
	mut new_plane := plane.clone()
	for x in coord_pair[0].x .. coord_pair[1].x + 1 {
		for y in coord_pair[0].y .. coord_pair[1].y + 1 {
			new_plane[x][y] += 1
		}
	}
	return new_plane
}

fn fill_plane_from_diag_line(plane [][]int, pair []Coordinate) [][]int {
	mut new_plane := plane.clone()
	if pair[0].x < pair[1].x && pair[0].y < pair[1].y {
		// positive angle
		mut x := pair[0].x
		mut y := pair[0].y
		for {
			if x > pair[1].x || y > pair[1].y {
				break
			}
			new_plane[x][y] += 1
			x++
			y++
		}
	} else if pair[0].x < pair[1].x && pair[0].y > pair[1].y {
		// negative angle
		mut x := pair[0].x
		mut y := pair[0].y
		for {
			if x > pair[1].x || y < pair[1].y {
				break
			}
			new_plane[x][y] += 1
			x++
			y--
		}
	} else {
		return fill_plane_from_diag_line(plane, [pair[1], pair[0]])
	}

	return new_plane
}

fn fill_plane_from_straight_pairs(plane [][]int, coord_pairs [][]Coordinate) [][]int {
	mut new_plane := plane.clone()
	for pair in coord_pairs {
		new_plane = fill_plane_from_straight_line(new_plane, pair)
	}
	return new_plane
}

fn fill_plane_from_diag_pairs(plane [][]int, coord_pairs [][]Coordinate) [][]int {
	mut new_plane := plane.clone()
	for pair in coord_pairs {
		new_plane = fill_plane_from_diag_line(new_plane, pair)
	}
	return new_plane
}

fn count_points_on_plane_gte_n(plane [][]int, n int) int {
	mut count := 0
	for col in plane {
		for row in col {
			if row >= n {
				count++
			}
		}
	}
	return count
}

fn test() {
	assert extract_and_sort_coords('419,207 -> 419,109') == [
		Coordinate{419, 109},
		Coordinate{419, 207},
	]
	assert extract_and_sort_coords('100,0 -> 0,100') == [
		Coordinate{0, 100},
		Coordinate{100, 0},
	] // xand y change in diag, so lower x comes first
	assert extract_and_sort_coords('0,-207 -> 0,0') == [Coordinate{0, -207},
		Coordinate{0, 0}]
	assert extract_and_sort_coords('0,200 -> 0,0') == [Coordinate{0, 0},
		Coordinate{0, 200}]

	assert is_straight_line([Coordinate{0, 0}, Coordinate{0, 1}]) == true // vertical
	assert is_straight_line([Coordinate{0, 0}, Coordinate{1, 0}]) == true // horizontal
	assert is_straight_line([Coordinate{0, 1}, Coordinate{1, 0}]) == false // diag

	mut min_x, mut min_y, mut max_x, mut max_y := find_coordinate_plane([
		[Coordinate{0, 0}, Coordinate{-100, 50}],
		[Coordinate{100, 50}, Coordinate{50, 102}],
	])
	assert min_x == -100
	assert min_y == 0
	assert max_x == 100
	assert max_y == 102
	min_x, min_y, max_x, max_y = find_coordinate_plane([
		[Coordinate{0, 0}, Coordinate{1, 1}],
	])
	assert min_x == 0
	assert min_y == 0
	assert max_x == 1
	assert max_y == 1

	assert generate_coord_plane(1, 2) == [[0, 0, 0], [0, 0, 0]]
	assert generate_coord_plane(2, 2) == [[0, 0, 0], [0, 0, 0],
		[0, 0, 0]]

	assert fill_plane_from_straight_line([[0, 0, 0], [0, 0, 0]], [
		Coordinate{0, 0},
		Coordinate{0, 1},
	]) == [[1, 1, 0], [0, 0, 0]]

	assert fill_plane_from_straight_pairs([[0, 0, 0], [0, 0, 0]], [
		[Coordinate{0, 0}, Coordinate{0, 2}],
	]) == [[1, 1, 1], [0, 0, 0]]

	assert count_points_on_plane_gte_n([[2, 1, 1], [0, 0, 0]], 2) == 1

	assert fill_plane_from_diag_line([[0, 0, 0], [0, 0, 0]], [
		Coordinate{0, 0},
		Coordinate{1, 1},
	]) == [[1, 0, 0], [0, 1, 0]]
}
