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

	mut most_common_bits := []int{}
	mut least_common_bits := []int{}
	for i in 0 .. len_of_binary_word {
		// get i'th character of word
		characters_at_position_i := binary_words.map(it[i].ascii_str())
		most_common_bit := get_most_common_bit(characters_at_position_i)
		most_common_bits << most_common_bit
		least_common_bits << get_opposite_bit(most_common_bit)
	}
	gamma := convert_bit_array_to_interger(most_common_bits)
	epsilon := convert_bit_array_to_interger(least_common_bits)
	println(gamma * epsilon)
}

fn extract_lines(contents string) []string {
	return contents.split('\n')
}

fn convert_bit_array_to_interger(bits []int) int {
	mut word := ''
	for bit in bits {
		word += bit.str()
	}
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
	if bit_counter.zeroes > bit_counter.ones {
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

fn test() {
	assert get_most_common_bit(['0']) == 0
	assert get_most_common_bit(['0', '1', '1']) == 1
	assert get_most_common_bit([]string{len: 100, init: '1'}) == 1
	assert get_opposite_bit(1) == 0
	assert get_opposite_bit(0) == 1
	assert convert_bit_array_to_interger([0]) == 0
	assert convert_bit_array_to_interger([1, 1, 1]) == 7
}
