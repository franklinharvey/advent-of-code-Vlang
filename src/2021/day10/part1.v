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
	mut sum := 0
	for line in lines {
		mut chars := line.bytes().map(it.ascii_str())
		mut open_chars := []string{}

		for ch in chars {
			if is_opener(ch) {
				open_chars << ch
			} else if is_match(open_chars.last(), ch) {
				open_chars.delete_last()
			} else {
				sum += score_incorrect_char(ch)
				break
			}
		}
	}
	println(sum)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn is_opener(ch string) bool {
	return match ch {
		'(' { true }
		'[' { true }
		'{' { true }
		'<' { true }
		else { false }
	}
}

fn is_match(a string, b string) bool {
	return match a {
		'(' { b == ')' }
		'[' { b == ']' }
		'{' { b == '}' }
		'<' { b == '>' }
		else { false }
	}
}

fn score_incorrect_char(a string) int {
	return match a {
		')' { 3 }
		']' { 57 }
		'}' { 1197 }
		'>' { 25137 }
		else { panic('Char not found') }
	}
}

fn test() {
	assert is_opener('(') == true
	assert is_opener(')') == false

	assert is_match('(', ')') == true
	assert is_match('(', '}') == false
}
