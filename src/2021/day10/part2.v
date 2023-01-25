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
	mut sums := []i64{}
	for line in lines {
		mut chars := line.bytes().map(it.ascii_str())
		mut open_chars := []string{}
		mut corrupted := false

		for i in 0 .. chars.len {
			if is_opener(chars[i]) {
				open_chars << chars[i]
			} else if is_match(open_chars.last(), chars[i]) {
				open_chars.delete_last()
			} else {
				// corrupted
				corrupted = true
				break
			}
		}

		if !corrupted {
			mut sum := i64(0)
			for ch in open_chars.reverse() {
				closer := find_pair(ch)
				score := score_closer(closer)
				sum = (sum * 5)
				sum += score
			}
			sums << sum
		}
	}
	sums.sort()
	median := sums[sums.len / 2]
	println(median)
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

fn find_pair(a string) string {
	return match a {
		'(' { ')' }
		'[' { ']' }
		'{' { '}' }
		'<' { '>' }
		else { panic('Char not found') }
	}
}

fn score_closer(a string) int {
	return match a {
		')' { 1 }
		']' { 2 }
		'}' { 3 }
		'>' { 4 }
		else { panic('Char not found') }
	}
}

fn test() {
	assert is_opener('(') == true
	assert is_opener(')') == false

	assert is_match('(', ')') == true
	assert is_match('(', '}') == false
}
