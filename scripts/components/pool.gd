extends Object
class_name Pool

var unique_elements: Array = []
var pool: Array = []
var original_pool: Array = []
var multiplier: int = 1

#The input should be formatted as [[item1, quantity1], [item2, quantity2]]. can change if needed.
func populate(array_pairs: Array[Array], multi: int = 1) -> void:
	for pair in array_pairs:
		var item = pair[0]
		var quantity = pair[1]
		if !unique_elements.has(item):
			unique_elements.append(item)
		pool.append_array(multiply_array([item], quantity))
	multiply(multi)
	
	original_pool = pool.duplicate()


func pop():
	var item = sample()
	pool.erase(item)
	return item


func sample():
	var index = randi_range(0,len(pool)-1)
	return pool[index]


func multiply(multi: int) -> void:
	multiplier *= multi
	pool = multiply_array(pool, multi)


func multiply_array(array: Array, integer: int) -> Array:
	var new_array: Array = []
	for i in range(integer):
		new_array.append(array)
	return new_array


func reset():
	pool = original_pool
