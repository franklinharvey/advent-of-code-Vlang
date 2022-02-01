import os
import strconv

fn main() {
	test()
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	num_array := extract_num_array(f)

	println(extract_num_of_increases(num_array))
}

fn extract_num_array(contents string) []int {
	mut splitted := []string{}
	for space_splitted in contents.to_lower().split(' ') {
		if space_splitted.contains('\n') {
			splitted << space_splitted.split('\n')
		} else {
			splitted << space_splitted
		}
	}
	return splitted.map(strconv.atoi(it) or { panic(err.msg) })
}

fn extract_num_of_increases(a []int) int {
	mut num_of_increases := 0
	mut prev_value := a.first()
	for i in a {
		if i > prev_value {
			num_of_increases++
		}
		prev_value = i
	}
	return num_of_increases
}

fn test() {
	assert extract_num_of_increases([1, 2]) == 1
	assert extract_num_of_increases([2, 1]) == 0
	assert extract_num_of_increases([1, 2, 1]) == 1
}
