extends Node

func mask(chosenmaskarray : Array[int]):
	var sum := 0
	for masknum in chosenmaskarray:
		@warning_ignore("narrowing_conversion")
		sum += pow(2, masknum-1)
	return sum
