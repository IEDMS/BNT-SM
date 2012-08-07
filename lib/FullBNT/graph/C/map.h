/* map.h
 */

#ifndef _MAP_H_
#define _MAP_H_

#include "cell.h"
#include "misc.h"

typedef struct map * Map;
typedef int (*eq)(word, word);
typedef unsigned long (*hash)(word);
typedef struct map_iter * Iterator;

void print_info(Iterator);
void print_map(Map);

Map create_Map(int size_hint, eq equality, hash hash_function, word empty,
  int factor);
void destroy_Map(Map map);

Map copy_Map(Map map);

int find(Map map, word key);
void put(Map map, word key, word value);
word get(Map map, word key);
word rem(Map map, word key);

int is_empty_word(Map map, word word);

void empty_Map(Map map);
unsigned long get_size_Map(Map map);

int is_subset_of(Map subset, Map superset);

Iterator get_Iterator(Map map);
Iterator create_Iterator(Map map);
void reset_Iterator(Iterator iterator);
void destroy_Iterator(Iterator iterator);

word next_key(Iterator iterator);
word next_value(Iterator iterator);
int is_empty(Iterator iterator);

#endif /* _MAP_H_ */
