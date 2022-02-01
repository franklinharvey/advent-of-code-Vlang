import os
import strconv

struct Window {
	a int
	b int
	c int
}

fn window_has_room(w Window) bool {
	return w.a == 0 || w.b == 0 || w.c == 0
}

fn add_to_window(w Window, value int) ?Window {
	if w.a == 0 {
		return Window{value, 0, 0}
	}
	if w.b == 0 {
		return Window{w.a, value, 0}
	}
	if w.c == 0 {
		return Window{w.a, w.b, value}
	}
	return error('could not add to window')
}

fn sum_window(w Window) int {
	return w.a + w.b + w.c
}

fn main() {
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	num_array := extract_num_array(f)
	mut windows := []Window{}
	for num in num_array {
		for i in 1 .. 4 {
			// for the last 3 windows
			index := windows.len - i
			window := windows[index] or {
				new_window := add_to_window(Window{}, num) or { panic('Cannot add to window') }
				windows << new_window
				break
			}
			if window_has_room(window) {
				// if current has room, add to window
				windows[index] = add_to_window(window, num) or { panic('Cannot add to window') }
			} else {
				new_window := add_to_window(Window{}, num) or { panic('Cannot add to window') }
				windows << new_window
			}
		}
	}
	windows = windows.filter(fn (window Window) bool {
		return !window_has_room(window)
	})
	sums := windows.map(sum_window(it))
	println(extract_num_of_increases(sums))
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
