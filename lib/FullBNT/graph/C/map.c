/* map.c
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "map.h"
#include "cell.h"

const char EMPTY = 0;
const char USED = 1;
const char FREE = 2;

struct map_entry {

  word key;
  Cell cell;
  word value;
  char flag;
};

typedef struct map_entry * Entry;
typedef struct map_entry * Entries;

struct map {

  eq equality;
  hash hasher;
  word empty;
  int factor;

  unsigned long size;
  unsigned long max_size;

  Entries entries;
  Cell order;

  Iterator iter;
};

struct map_iter {

  word empty;
  Cell order;
  Cell origin;
};

Map create_Map(int size_hint, eq equality, hash hasher, word empty, int factor){

  int i = 1;
  Map map = (Map) malloc(sizeof(struct map));

  if(size_hint < 4){
    size_hint = 4;
  } else {
    while((i = i << 1) < size_hint);
    size_hint = i;
  }

  map->size = 0;
  map->max_size = size_hint * factor + 1;
  map->entries = (Entries) malloc(sizeof(struct map_entry) * map->max_size);
  map->order = create_Cell(empty);
  map->empty = empty;
  map->equality = equality;
  map->hasher = hasher;
  map->factor = factor;
  map->iter = (Iterator) NULL;

  for(i = 0; i < map->max_size; i++){
    map->entries[i].flag = EMPTY;
    map->entries[i].key = empty;
  }
  return map;
}

Map copy_Map(Map map){

  Map m;
  Iterator iter;
  word w;

  if(!map){
    return (Map) NULL;
  }
  m = create_Map(map->max_size / map->factor, map->equality, map->hasher,
    map->empty, map->factor);
  iter = get_Iterator(map);
  while(!is_empty(iter)){
    w = next_key(iter);
    put(m, w, get(map, w));
  }

  return m;
}

void destroy_Map(Map map){

  if(map){
    if(map->entries){
      free(map->entries);
    }
    destroy_Iterator(map->iter);
    destroy_all_next(map->order);
    free(map);
  }
}

int is_subset_of(Map subset, Map superset){

  word w;
  Iterator iter = get_Iterator(subset);

  while(!is_empty(iter)){
    w = next_key(iter);
    if(is_empty_word(superset, get(superset, w))){
      return 0;
    }
  }
  return 1;
}

void empty_Map(Map map){

  int i;

  for(i = 0; i < map->max_size; i++){
    map->entries[i].flag = EMPTY;
  }
  map->size = 0;
  destroy_all_next(map->order);
  destroy_Iterator(map->iter);
  map->iter = (Iterator) NULL;
  map->order = create_Cell(map->empty);
}

unsigned long get_size_Map(Map map){

  return map->size;
}

Iterator create_Iterator(Map map){

  Iterator iterator = (Iterator) malloc(sizeof(struct map_iter));

  iterator->empty = map->empty;
  iterator->origin = map->order;
  iterator->order = next_Cell(iterator->origin);

  return iterator;
}

Iterator get_Iterator(Map map){

  if(!map->iter){
    map->iter = create_Iterator(map);
  }
  reset_Iterator(map->iter);

  return map->iter;
}

void reset_Iterator(Iterator iterator){

  iterator->order = next_Cell(iterator->origin);
}

void destroy_Iterator(Iterator iterator){

  if(iterator){
    free(iterator);
  }
}

word next_key(Iterator iterator){

  word w = iterator->empty;

  if(!is_empty(iterator)){
    w = get_data(iterator->order);
    iterator->order = next_Cell(iterator->order);
    return ((Entry) w.v)->key;
  }
  return w;
}

int is_empty(Iterator iterator){

  return !iterator->order;
}

void print_map(Map map){

  Cell cell = map->order;

  printf("%p\n", map);
  while(cell){
    print_Cell(cell);
    cell = next_Cell(cell);
  }
}

void print_info(Iterator iterator){

  printf("origin = ");
  print_Cell(iterator->origin);
  printf("order = ");
  print_Cell(iterator->order);
}

word next_value(Iterator iterator){

  word w = iterator->empty;

  if(!is_empty(iterator)){
    w = get_data(iterator->order);
    iterator->order = next_Cell(iterator->order);
    return ((Entry) w.v)->value;
  }
  return w;
}

int is_empty_word(Map m, word w){

  return 0 == memcmp(&w, &(m->empty), sizeof(word));
}

void rehash(Map map){

  word w;
  int i, h;
  int old_size = map->max_size;
  Entries entries;

  if(map->max_size > (2 << 31) - 1){
    fprintf(stderr, "Hashtable at maximum capacity, cannot insert.  Exiting\n");
    abort();
  }

  map->max_size *= 2;
  entries = (Entries) malloc(sizeof(struct map_entry) * map->max_size);
  for(i = 0; i < map->max_size; i++){
    entries[i].flag = EMPTY;
  }

  for(i = 0; i < old_size; i++){
    if(map->entries[i].flag == USED){
      for(h = map->hasher(map->entries[i].key) % map->max_size;
	entries[h].flag != EMPTY; (h == 0 ? h = map->max_size - 1 : h--));
      entries[h] = map->entries[i];
      entries[h].flag = USED;
      w.v = &entries[h];
      set_data(entries[h].cell, w);
    }
  }
  if(map->entries){
    free(map->entries);
  }
  map->entries = entries;
}

int find(Map map, word key){

  return !is_empty_word(map, get(map, key));
}

void put(Map map, word key, word value){

  long h;
  char flag;
  word w;

  rem(map, key);
  while(map->size * map->factor >= map->max_size){
    rehash(map);
  }
  h = map->hasher(key) % map->max_size;
  while(1){
    flag = map->entries[h].flag;
    if(flag == EMPTY || flag == FREE){
      map->size++;
      break;
    } else if(map->equality(map->entries[h].key, key)){
/*
      remove_Cell(map->entries[h].cell);
      destroy_Cell(map->entries[h].cell);
      map->entries[h].cell = (Cell) NULL;*/
      /*printf("WARNING: Assertion violated in map\n");*/
      break;
    }
    (h == 0 ? h = map->max_size - 1 : h--);
  }
  w.v = &map->entries[h];
  map->entries[h].cell = insert_after(map->order, w);
  map->entries[h].flag = USED;
  map->entries[h].key = key;
  map->entries[h].value = value;
}

word get(Map map, word key){

  long h;
  word w = map->empty;

  for(h = map->hasher(key) % map->max_size; map->entries[h].flag != EMPTY;
      (h == 0 ? h = map->max_size - 1 : h--)){
    if(map->equality(key, map->entries[h].key)){
      if(map->entries[h].flag == FREE){
        return w;
      }
      return map->entries[h].value;
    }
  }
  return w;
}

word rem(Map map, word key){

  long h;
  word w = map->empty;

  for(h = map->hasher(key) % map->max_size; map->entries[h].flag != EMPTY;
      (h == 0 ? h = map->max_size - 1 : h--)){
    if(map->equality(key, map->entries[h].key)){
      if(map->entries[h].flag == FREE){
        return w;
      }
      map->size--;
      w = map->entries[h].value;
      remove_Cell(map->entries[h].cell);
      destroy_Cell(map->entries[h].cell);
      map->entries[h].cell = (Cell) NULL;
      map->entries[h].flag = FREE;
      return w;
    }
  }
  return w;
}
