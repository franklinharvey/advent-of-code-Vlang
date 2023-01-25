import os

/*
Needs int64 throughout otherwise will overflow
*/

fn main() {
	test()
	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut school := extract_school(f)
	for _ in 0 .. 256 {
		school = age_school(school)
	}
	println(sum_school(school))
}

fn extract_school(contents string) []i64 {
	fishes := contents.split(',').map(it.int())
	mut school := []i64{len: 9}
	for fish in fishes {
		school[fish]++
	}
	return school
}

fn age_school(school []i64) []i64 {
	mut newborns := i64(0)
	mut new_school := []i64{len: 9, init: 0}

	for i in 0 .. school.len {
		if i == 0 {
			new_school[6] += school[i]
			newborns = school[i]
		} else {
			new_school[i - 1] += school[i]
		}
	}

	// newborn fish
	new_school[8] = newborns
	return new_school
}

fn sum_school(school []i64) i64 {
	mut sum := i64(0)
	for age in school {
		sum += age
	}
	return sum
}

fn test() {
	assert extract_school('1,2,3') == [i64(0), i64(1), i64(1), i64(1), i64(0), i64(0), i64(0),
		i64(0), i64(0)]
	assert extract_school('0,8') == [i64(1), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0),
		i64(1)]
	assert extract_school('0,0,8') == [i64(2), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0),
		i64(0), i64(1)]

	assert age_school([i64(2), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0), i64(1)]) == [
		i64(0),
		i64(0),
		i64(0),
		i64(0),
		i64(0),
		i64(0),
		i64(2),
		i64(1),
		i64(2),
	]
	assert age_school([i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1)]) == [
		i64(1),
		i64(1),
		i64(1),
		i64(1),
		i64(1),
		i64(1),
		i64(2),
		i64(1),
		i64(1),
	]

	assert sum_school([i64(2), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0), i64(0), i64(1)]) == 3
	assert sum_school([i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1), i64(1)]) == 9
}
