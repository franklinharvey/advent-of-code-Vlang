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

	mut fishes := extract_fish(f)
	for _ in 0 .. 80 {
		fishes = age_fish(fishes)
	}
	println(fishes.len)
}

fn extract_fish(contents string) []int {
	return contents.split(',').map(it.int())
}

fn age_fish(_fishes []int) []int {
	mut new_fishes := []int{}
	mut fishes := _fishes.clone()

	for mut fish in fishes {
		if fish == 0 {
			fish = 6
			new_fishes << 8
		} else {
			fish--
		}
	}

	fishes << new_fishes
	return fishes
}

fn test() {
	assert extract_fish('1,2,3') == [1, 2, 3]

	assert age_fish([1]) == [0]
	assert age_fish([0]) == [6, 8]
	assert age_fish([1, 0, 0]) == [0, 6, 6, 8, 8]
}
