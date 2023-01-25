2 seg - 1
3 seg - 7
4 seg - 4
5 seg - 2, 3,5
6 seg - 0, 6, 9
7 seg - 8

# directions

get 1 from 2 char
1 gives us top right, bottom right (swappable)
get 7 from 3 char
7 gives us top center (solid)
get 4 from 4 char
4 gives us top left, middle (swappable)

get bottom-middle segment (solid from unique, new segment found in all 5-len characters) 

get bottom left segment (solid form unique, new segment found in some 6-len characters, and last unknown character)
get 0 from has bottom-left + top right from one
get 6 from has bottom-left + not have top right from one
get 9 from not have bottom-left

get 8 from 7 char (only missing letter from 0)
0 gives us middle (solid, 8-0 == middle)
- gives us top left (solid, was swappable with middle)

get 5 from has tr but not bl
5 gives us bottom center (solid after 1, 4, 7 subtract)
5 gives us top right (solid after 1 subtract)
5 gives us bottom right (solid, leftover swappable 1 segments)