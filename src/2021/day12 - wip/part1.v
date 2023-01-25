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
	mut starts := [][]string{}
	for node in lines {
		if 'start' in node {
			starts << node
		}
	}
	println(starts)
}

fn extract_lines(contents string) [][]string {
	return contents.split('\n').map(it.split('-'))
}

fn test() {
}
