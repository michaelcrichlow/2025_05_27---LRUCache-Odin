package test

import "core:fmt"
import p_list "python_list_functions"
print :: fmt.println

main :: proc() {
	lru := init_lru_cache(3)  // Initialize cache with capacity of 3

	assert(get_lru(&lru, 1) == -1)  // Key 1 should not exist yet
	put_lru(&lru, 1, 100)
	assert(get_lru(&lru, 1) == 100)  // Key 1 should return the correct value

	put_lru(&lru, 2, 200)
	put_lru(&lru, 3, 300)
	assert(get_lru(&lru, 2) == 200)  // Key 2 should return 200
	assert(get_lru(&lru, 3) == 300)  // Key 3 should return 300

	put_lru(&lru, 4, 400)  // Should evict key 1 since cache size is 3
	assert(get_lru(&lru, 1) == -1)  // Key 1 should no longer exist

	put_lru(&lru, 5, 500)  // Should evict key 2
	assert(get_lru(&lru, 2) == -1)  // Key 2 should no longer exist
	assert(get_lru(&lru, 5) == 500)  // Key 5 should exist

	put_lru(&lru, 3, 350)  // Update existing key 3's value (move value to end)
	assert(get_lru(&lru, 3) == 350)  // Should return updated value

	put_lru(&lru, 6, 600)  // Should evict least recently used (key 4)
	assert(get_lru(&lru, 4) == -1)  // Key 4 should no longer exist
	assert(get_lru(&lru, 6) == 600)  // Key 6 should exist

	put_lru(&lru, 7, 700)
	put_lru(&lru, 8, 800)

	assert(get_lru(&lru, 3) == -1)
	put_lru(&lru, 9, 900)  // Should evict least recently used (key 5)

	assert(get_lru(&lru, 7) == 700)  // Key 7 should exist
	assert(get_lru(&lru, 8) == 800)  // Key 8 should exist
	assert(get_lru(&lru, 9) == 900)  // Key 9 should exist
	print("All asserts passed!")

	free_all(context.temp_allocator)
}

LRUCache :: struct {
    cache: map[int]int,
    order: [dynamic]int,
    capacity: int,
}

init_lru_cache :: proc(capacity: int) -> LRUCache {
    return LRUCache{make(map[int]int, context.temp_allocator), make([dynamic ]int, context.temp_allocator), capacity}
}

get_lru :: proc(lru: ^LRUCache, key: int) -> int {
    if key in lru.cache {
        // Move the key to the end (mark as "recently used")
	p_list.remove(&lru.order, key)
        append(&lru.order, key)
        
	return lru.cache[key]
    }
    return -1  // Not found
}

put_lru :: proc(lru: ^LRUCache, key: int, value: int) {
	if key in lru.cache {
	    // update value
	    lru.cache[key] = value 
		
	    // mark as recently used	
	    p_list.remove(&lru.order, key)
            append(&lru.order, key)
	}
	
	if key not_in lru.cache {
	    lru.cache[key] = value  // update value
            append(&lru.order, key) // mark as recently used
	}
	
	// remove the first value if the length is greater than the capacity
	if len(lru.order) > lru.capacity {
	    temp_val := lru.order[0]
	    p_list.remove(&lru.order, temp_val)
	    delete_key(&lru.cache, temp_val)
	}
}
