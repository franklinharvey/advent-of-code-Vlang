import os

struct Codex {
mut:
	tl []string
	tc []string
	tr []string
	m  []string
	bl []string
	bc []string
	br []string
}

fn (a Codex) intersect(b Codex) Codex {
	return Codex{
		tl: a.tl.filter(it in b.tl)
		tc: a.tc.filter(it in b.tc)
		tr: a.tr.filter(it in b.tr)
		m: a.m.filter(it in b.m)
		bl: a.bl.filter(it in b.bl)
		bc: a.bc.filter(it in b.bc)
		br: a.br.filter(it in b.br)
	}
}

fn (a Codex) get_chars() []string {
	mut chars := []string{}
	chars << a.tl
	chars << a.tc
	chars << a.tr
	chars << a.m
	chars << a.bl
	chars << a.bc
	chars << a.br
	return chars
}

fn main() {
	// test()
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	lines := extract_lines(f)
	inputs_and_outputs := extract_input_output(lines)
	mut sum := 0
	mut count := 1
	for io in inputs_and_outputs {
		input := extract_input_set(io)
		output := extract_output_set(io)
		tmp_one := get_one(input)
		tmp_seven := get_seven(input, tmp_one)
		tmp_four := get_four(input, tmp_one)
		bc := get_bottom_center(input, tmp_four, tmp_seven)
		bl := get_bottom_left(input, tmp_one, tmp_four, bc, tmp_seven)
		tmp_zero := get_zero(input, tmp_one, tmp_four, tmp_seven, bc, bl)
		m := get_middle(input, tmp_zero)
		tl := get_top_left(tmp_zero)
		tmp_two := get_two(input, tmp_zero, m)
		tr := get_top_right(tmp_two)
		tc := get_top_center(tmp_seven)
		br := get_bottom_right(tmp_one, tr)
		lookup := Codex{
			tl: tl.tl
			tc: tc.tc
			tr: tr.tr
			m: m.m
			bl: bl.bl
			bc: bc.bc
			br: br.br
		}
		mut compound_num := 0
		for num in output {
			constructed := construct_char(num, lookup).int()
			tmp := (compound_num * 10)
			compound_num = tmp + constructed
		}
		count++
		sum += compound_num
	}
	println(sum)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn extract_input_output(contents []string) [][]string {
	// [0][0] line 1, input (includes all records in single string)
	// [0][1] line 1, output
	return contents.map(it.split(' | '))
}

fn extract_input_set(io []string) []string {
	return io[0].split(' ')
}

fn extract_output_set(io []string) []string {
	return io[1].split(' ')
}

fn get_one(input []string) Codex {
	one_chars := input.filter(it.len == 2)[0]
	return Codex{
		tr: one_chars.bytes().map(it.ascii_str())
		br: one_chars.bytes().map(it.ascii_str())
	}
}

fn get_seven(input []string, one Codex) Codex {
	seven_chars := input.filter(it.len == 3)[0]
	mut intermediate := Codex{
		tr: seven_chars.bytes().map(it.ascii_str())
		br: seven_chars.bytes().map(it.ascii_str())
		tc: seven_chars.bytes().map(it.ascii_str())
	}
	unique := intermediate.tc.filter(it !in one.tr)[0]
	intermediate = intermediate.intersect(one)
	intermediate.tc = [unique]
	return intermediate
}

fn get_four(input []string, one Codex) Codex {
	four_chars := input.filter(it.len == 4)[0]
	mut intermediate := Codex{
		tr: four_chars.bytes().map(it.ascii_str())
		br: four_chars.bytes().map(it.ascii_str())
		tl: four_chars.bytes().map(it.ascii_str())
		m: four_chars.bytes().map(it.ascii_str())
	}
	intermediate.tr = one.tr
	intermediate.br = one.br
	unique := intermediate.tl.filter(it !in one.tr)
	intermediate.tl = unique
	intermediate.m = unique
	return intermediate
}

fn get_bottom_center(input []string, four Codex, seven Codex) Codex {
	five_lengths := input.filter(it.bytes().len == 5)
	mut found_chars := four.tl
	found_chars << four.tr
	found_chars << seven.tc
	// get 5-len char, filter out chars from seven and four
	mut bc := Codex{}
	for i in five_lengths {
		uniq_char := i.bytes().map(it.ascii_str()).filter(it !in found_chars)
		if uniq_char.len == 1 {
			bc = Codex{
				bc: uniq_char
			}
		}
	}
	return bc
}

fn get_bottom_left(input []string, one Codex, four Codex, bc Codex, seven Codex) Codex {
	six_lengths := input.filter(it.bytes().len == 6)

	mut found_chars := bc.bc
	found_chars << one.tr
	found_chars << one.br
	found_chars << seven.tc
	found_chars << four.tl
	found_chars << four.m
	mut bottom_left := Codex{}
	for i in six_lengths {
		uniq_char := i.bytes().map(it.ascii_str()).filter(it !in found_chars)
		if uniq_char.len > 0 {
			bottom_left = Codex{
				bl: uniq_char
			}
		}
	}
	return bottom_left
}

fn get_zero(input []string, one Codex, four Codex, seven Codex, bc Codex, bl Codex) Codex {
	six_lengths := input.filter(it.bytes().len == 6)
	mut zero := Codex{}
	for i in six_lengths {
		chars := i.bytes().map(it.ascii_str())
		if bl.bl[0] in chars && one.tr[0] in chars && one.tr[1] in chars {
			zero = Codex{
				tl: four.tl.filter(it in chars)
				tc: seven.tc.filter(it in chars)
				tr: one.tr.filter(it in chars)
				m: four.m.filter(it in chars)
				bl: bl.bl.filter(it in chars)
				bc: bc.bc.filter(it in chars)
				br: one.br.filter(it in chars)
			}
		}
	}
	return zero
}

fn get_middle(input []string, zero Codex) Codex {
	seven_length := input.filter(it.bytes().len == 7)[0]

	mut found_chars := zero.bc
	found_chars << zero.br
	found_chars << zero.bl
	found_chars << zero.tr
	found_chars << zero.tc
	found_chars << zero.tl

	mut middle := Codex{}

	uniq_char := seven_length.bytes().map(it.ascii_str()).filter(it !in found_chars)

	if uniq_char.len > 0 {
		middle = Codex{
			m: uniq_char
		}
	}

	return middle
}

fn get_top_left(zero Codex) Codex {
	return Codex{
		tl: zero.tl
	}
}

fn get_two(input []string, zero Codex, m Codex) Codex {
	five_lengths := input.filter(it.bytes().len == 5)
	mut two := Codex{}
	for i in five_lengths {
		chars := i.bytes().map(it.ascii_str())
		if zero.bl[0] in chars {
			two = Codex{
				tc: zero.tc.filter(it in chars)
				tr: zero.tr.filter(it in chars)
				m: m.m.filter(it in chars)
				bl: zero.bl.filter(it in chars)
				bc: zero.bc.filter(it in chars)
			}
		}
	}
	return two
}

fn get_top_right(two Codex) Codex {
	return Codex{
		tr: two.tr
	}
}

fn get_top_center(seven Codex) Codex {
	return Codex{
		tc: seven.tc
	}
}

fn get_bottom_right(one Codex, tr Codex) Codex {
	return Codex{
		br: one.br.filter(it !in tr.tr)
	}
}

fn construct_zero(lookup Codex) Codex {
	return Codex{
		tl: lookup.tl
		tc: lookup.tc
		tr: lookup.tr
		bl: lookup.bl
		bc: lookup.bc
		br: lookup.br
	}
}

fn construct_one(lookup Codex) Codex {
	return Codex{
		tr: lookup.tr
		br: lookup.br
	}
}

fn construct_two(lookup Codex) Codex {
	return Codex{
		tc: lookup.tc
		tr: lookup.tr
		m: lookup.m
		bl: lookup.bl
		bc: lookup.bc
	}
}

fn construct_three(lookup Codex) Codex {
	return Codex{
		tc: lookup.tc
		tr: lookup.tr
		m: lookup.m
		bc: lookup.bc
		br: lookup.br
	}
}

fn construct_four(lookup Codex) Codex {
	return Codex{
		tl: lookup.tl
		tr: lookup.tr
		m: lookup.m
		br: lookup.br
	}
}

fn construct_five(lookup Codex) Codex {
	return Codex{
		tl: lookup.tl
		tc: lookup.tc
		m: lookup.m
		bc: lookup.bc
		br: lookup.br
	}
}

fn construct_six(lookup Codex) Codex {
	return Codex{
		tl: lookup.tl
		tc: lookup.tc
		m: lookup.m
		bl: lookup.bl
		bc: lookup.bc
		br: lookup.br
	}
}

fn construct_seven(lookup Codex) Codex {
	return Codex{
		tc: lookup.tc
		tr: lookup.tr
		br: lookup.br
	}
}

fn construct_nine(lookup Codex) Codex {
	return Codex{
		tl: lookup.tl
		tc: lookup.tc
		tr: lookup.tr
		m: lookup.m
		bc: lookup.bc
		br: lookup.br
	}
}

fn construct_char(to_match string, lookup Codex) string {
	chars := to_match.bytes().map(it.ascii_str())
	zero := construct_zero(lookup)
	one := construct_one(lookup)
	two := construct_two(lookup)
	three := construct_three(lookup)
	four := construct_four(lookup)
	five := construct_five(lookup)
	six := construct_six(lookup)
	seven := construct_seven(lookup)
	eight := lookup
	nine := construct_nine(lookup)
	if chars.all(it in zero.get_chars()) && zero.get_chars().all(it in chars) {
		return '0'
	}
	if chars.all(it in one.get_chars()) && one.get_chars().all(it in chars) {
		return '1'
	}
	if chars.all(it in two.get_chars()) && two.get_chars().all(it in chars) {
		return '2'
	}
	if chars.all(it in three.get_chars()) && three.get_chars().all(it in chars) {
		return '3'
	}
	if chars.all(it in four.get_chars()) && four.get_chars().all(it in chars) {
		return '4'
	}
	if chars.all(it in five.get_chars()) && five.get_chars().all(it in chars) {
		return '5'
	}
	if chars.all(it in six.get_chars()) && six.get_chars().all(it in chars) {
		return '6'
	}
	if chars.all(it in seven.get_chars()) && seven.get_chars().all(it in chars) {
		return '7'
	}
	if chars.all(it in eight.get_chars()) && eight.get_chars().all(it in chars) {
		return '8'
	}
	if chars.all(it in nine.get_chars()) && nine.get_chars().all(it in chars) {
		return '9'
	}
	panic('Char not found')
}

fn test() {
	assert extract_lines('a\nb') == ['a', 'b']

	assert extract_input_output(['a | b', 'c | d']) == [['a', 'b'],
		['c', 'd']]

	assert extract_input_set(['a', 'b']) == ['a']
	assert extract_input_set(['abc', 'def efg']) == ['abc']
	assert extract_output_set(['a', 'b']) == ['b']
	assert extract_output_set(['abc', 'def efg']) == ['def', 'efg']

	assert Codex{}.intersect(Codex{}) == Codex{}
	assert Codex{
		tr: ['a']
	}.intersect(Codex{}) == Codex{}
	assert Codex{
		tr: ['a', 'b', 'c']
	}.intersect(Codex{ tr: ['a', 'b'] }) == Codex{
		tr: ['a', 'b']
	}

	assert get_one(['eb', 'edb']) == Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}

	assert get_seven(['eb', 'edb'], Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}) == Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tc: ['d']
	}

	assert get_four(['cgeb'], Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}) == Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tl: ['c', 'g']
		m: ['c', 'g']
	}

	assert get_bottom_center(['fdcge'], Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tl: ['c', 'g']
		m: ['c', 'g']
	}, Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tc: ['d']
	}) == Codex{
		bc: ['f']
	}

	assert get_bottom_left(['be', 'cfbegad', 'cbdgef', 'fgaecd', 'cgeb', 'fdcge', 'agebfd', 'fecdb',
		'fabcd', 'edb'], Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}, Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tl: ['c', 'g']
		m: ['c', 'g']
	}, Codex{
		bc: ['f']
	}, Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tc: ['d']
	}) == Codex{
		bl: ['a']
	}

	assert get_zero(['be', 'cfbegad', 'cbdgef', 'fgaecd', 'cgeb', 'fdcge', 'agebfd', 'fecdb', 'fabcd',
		'edb'], Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}, Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tl: ['c', 'g']
		m: ['c', 'g']
	}, Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tc: ['d']
	}, Codex{
		bc: ['f']
	}, Codex{
		bl: ['a']
	}) == Codex{
		tl: ['g']
		tc: ['d']
		tr: ['e', 'b']
		bl: ['a']
		bc: ['f']
		br: ['e', 'b']
	}

	assert get_middle(['be', 'cfbegad', 'cbdgef', 'fgaecd', 'cgeb', 'fdcge', 'agebfd', 'fecdb',
		'fabcd', 'edb'], Codex{
		tl: ['g']
		tc: ['d']
		tr: ['e', 'b']
		bl: ['a']
		bc: ['f']
		br: ['e', 'b']
	}) == Codex{
		m: ['c']
	}

	assert get_top_left(Codex{
		tl: ['g']
		tc: ['d']
		tr: ['e', 'b']
		bl: ['a']
		bc: ['f']
		br: ['e', 'b']
	}) == Codex{
		tl: ['g']
	}

	assert get_two(['be', 'cfbegad', 'cbdgef', 'fgaecd', 'cgeb', 'fdcge', 'agebfd', 'fecdb', 'fabcd',
		'edb'], Codex{
		tl: ['g']
		tc: ['d']
		tr: ['e', 'b']
		bl: ['a']
		bc: ['f']
		br: ['e', 'b']
	}, Codex{
		m: ['c']
	}) == Codex{
		tc: ['d']
		tr: ['b']
		m: ['c']
		bl: ['a']
		bc: ['f']
	}

	assert get_top_right(Codex{
		tc: ['d']
		tr: ['b']
		m: ['c']
		bl: ['a']
		bc: ['f']
	}) == Codex{
		tr: ['b']
	}

	assert get_top_center(Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
		tc: ['d']
	}) == Codex{
		tc: ['d']
	}

	assert get_bottom_right(Codex{
		tr: ['e', 'b']
		br: ['e', 'b']
	}, Codex{
		tr: ['b']
	}) == Codex{
		br: ['e']
	}

	assert construct_char('fabcd', Codex{
		tl: ['g']
		tc: ['d']
		tr: ['b']
		m: ['c']
		bl: ['a']
		bc: ['f']
		br: ['e']
	}) == '2'

	assert construct_char('eb', Codex{
		tl: ['g']
		tc: ['d']
		tr: ['b']
		m: ['c']
		bl: ['a']
		bc: ['f']
		br: ['e']
	}) == '1'
}
