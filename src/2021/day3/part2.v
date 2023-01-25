import os

struct CountBits {
	zeroes int
	ones   int
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

	binary_words := extract_lines(f)

	len_of_binary_word := binary_words.first().len
	assert binary_words.all(it.len == len_of_binary_word)

	mut oxygen_candidates := binary_words.clone()
	mut carbon_candidates := binary_words.clone()

	for i in 0 .. len_of_binary_word {
		// get i'th character of word
		oxygen_characters_at_position_i := oxygen_candidates.map(it[i].ascii_str())
		oxygen_most_common_bit := get_most_common_bit(oxygen_characters_at_position_i)

		carbon_characters_at_position_i := carbon_candidates.map(it[i].ascii_str())
		carbon_most_common_bit := get_most_common_bit(carbon_characters_at_position_i)
		if oxygen_most_common_bit == -1 {
			oxygen_candidates = filter_if_possible(oxygen_candidates, 1, i)
		} else {
			oxygen_candidates = filter_if_possible(oxygen_candidates, oxygen_most_common_bit,
				i)
		}
		if carbon_most_common_bit == -1 {
			carbon_candidates = filter_if_possible(carbon_candidates, 0, i)
		} else {
			carbon_candidates = filter_if_possible(carbon_candidates, get_opposite_bit(carbon_most_common_bit),
				i)
		}
	}
	println(oxygen_candidates)
	println(carbon_candidates)
	println(convert_binary_word_to_interger(oxygen_candidates[0]) * convert_binary_word_to_interger(carbon_candidates[0]))
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn convert_binary_word_to_interger(word string) int {
	return ('0b' + word).int()
}

fn get_most_common_bit(bits []string) int {
	mut bit_counter := CountBits{}
	for bit in bits {
		if bit == '0' {
			bit_counter = CountBits{bit_counter.zeroes + 1, bit_counter.ones}
		} else {
			bit_counter = CountBits{bit_counter.zeroes, bit_counter.ones + 1}
		}
	}
	if bit_counter.zeroes == bit_counter.ones {
		return -1
	} else if bit_counter.zeroes > bit_counter.ones {
		return 0
	}
	return 1
}

fn get_opposite_bit(bit int) int {
	if bit == 0 {
		return 1
	}
	return 0
}

fn get_nth_bit_in_word(word string, n int) int {
	return word.bytes().map(it.ascii_str())[n].int()
}

fn filter_if_possible(list []string, filter_by_val int, index int) []string {
	if list.len == 1 {
		return list
	}
	return list.filter(get_nth_bit_in_word(it, index) == filter_by_val)
}

fn test() {
	assert get_most_common_bit(['0']) == 0
	assert get_most_common_bit(['0', '1', '1']) == 1
	assert get_most_common_bit(['0', '1']) == -1
	assert get_most_common_bit([]string{len: 100, init: '1'}) == 1
	assert get_opposite_bit(1) == 0
	assert get_opposite_bit(0) == 1
	assert convert_binary_word_to_interger('0') == 0
	assert convert_binary_word_to_interger('0111') == 7
	assert get_nth_bit_in_word('100', 0) == 1
	assert get_nth_bit_in_word('010', 1) == 1
	assert filter_if_possible(['100', '001'], 1, 0) == ['100']
	assert filter_if_possible(['100', '001'], 0, 1) == ['100', '001']
}
