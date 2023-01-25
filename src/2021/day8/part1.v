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
	inputs_and_outputs := extract_input_output(lines)

	mut count := 0
	for io in inputs_and_outputs {
		output := extract_output_set(io)
		count += count_instances_of_1478(output)
	}
	println(count)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn extract_input_output(contents []string) [][]string {
	// [0][0] line 1, input (includes all records in single string)
	// [0][1] line 1, output
	return contents.map(it.split(' | '))
}

fn extract_output_set(io []string) []string {
	return io[1].split(' ')
}

fn count_instances_of_1478(output_set []string) int {
	mut count := 0
	for o in output_set {
		count += match o.len {
			2 { 1 }
			3 { 1 }
			4 { 1 }
			7 { 1 }
			else { 0 }
		}
	}
	return count
}

fn test() {
	assert extract_lines('a\nb') == ['a', 'b']

	assert extract_input_output(['a | b', 'c | d']) == [['a', 'b'],
		['c', 'd']]

	assert extract_output_set(['a', 'b']) == ['b']
	assert extract_output_set(['abc', 'def efg']) == ['def', 'efg']

	assert count_instances_of_1478(['fdgacbe', 'cefdb', 'cefbgd', 'gcbe']) == 2
	assert count_instances_of_1478(['fcgedb', 'cgb', 'dgebacf', 'gc']) == 3
}
