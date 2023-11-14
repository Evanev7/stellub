extends Object
class_name Pool

var unique_elements: Array = []
var pool: Array = []
var original_pool: Array = []
var multiplier: int = 1

#The input should be formatted as [[item1, quantity1], [item2, quantity2]]. can change if needed.
func populate(array_pairs: Array, multi: int = 1) -> void:
	for pair in array_pairs:
		var item = pair[0]
		var quantity = pair[1]
		if !unique_elements.has(item):
			unique_elements.append(item)
		pool.append_array(multiply_array([item], quantity))
	multiply(multi)
	
	original_pool = pool.duplicate()


func pop():
	var item = sample(1)
	remove(item)
	return item


func sample(n: int = 1, unique_draw: bool = true):
	if n == 1:
		var index = randi_range(0,len(pool)-1)
		return pool[index]
	
	var output = []
	if not unique_draw:
		var items = []
		while len(items) < n:
			var index = randi_range(0,len(pool)-1)
			if not items.has(index):
				items.append(index)
		
		
		for index in items:
			output.append(pool[index])
	else:
		while len(output) < n:
			var index = randi_range(0,len(pool)-1)
			if not output.has(pool[index]):
				output.append(pool[index])
	
	return output
	
	

func remove(item):
	pool.erase(item)


func multiply(multi: int) -> void:
	multiplier *= multi
	pool = multiply_array(pool, multi)


func multiply_array(array: Array, integer: int) -> Array:
	var new_array: Array = []
	for i in range(integer):
		new_array.append_array(array)
	return new_array


func reset():
	pool = original_pool
