/* elim.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "elim.h"

int set_compare(word w1, word w2){

  Map m1 = (Map) w1.v;
  Map m2 = (Map) w2.v;

  return get_size_Map(m1) == get_size_Map(m2) && is_subset_of(m1, m2);
}

unsigned long hash_set(word w){

  Map map = (Map) w.v;
  Iterator iter = get_Iterator(map);
  unsigned long h = 0;
 
  while(!is_empty(iter)){
    w = next_key(iter);
    h += (1 << w.i);
  }
  return h;
}

int compare(word w1, word w2){

  return w1.i == w2.i;
}

int ptr_compare(word w1, word w2){

  return w1.v == w2.v;
}

unsigned long hash_ptr(word w){

  return (unsigned long) w.v;
}

unsigned long hash_int(word w){

  return w.i;
}

word empty(){

  word w = { -1 };

  return w;
}

struct node {

  int index;
  float weight;
};

struct elimination {

  Map ordering;
  Map cliques;
  int ** fill_ins;
  Map node_map;
};

struct neighborhood {

  Map parents;
  Map children;
};

typedef struct neighborhood * Neighborhood;

Neighborhood create_Neighborhood(int size_hint){

  Neighborhood n = (Neighborhood) malloc(sizeof(struct neighborhood));

  n->parents = create_Map(size_hint, compare, hash_int, empty(), 2);
  n->children = create_Map(size_hint, compare, hash_int, empty(), 2);

  return n;
}

void destroy_Neighborhood(Neighborhood n){

  if(n){
    destroy_Map(n->parents);
    destroy_Map(n->children);
    free(n);
  }
}

void find_roots(Neighborhood * graph, Map remaining, Map roots){

  word w;
  Iterator iter = get_Iterator(remaining);

  while(!is_empty(iter)){
    w = next_key(iter);
    if(get_size_Map(graph[w.i]->parents) == 0){
      put(roots, w, w);
    }
  }
}

void remove_node(Neighborhood * graph, int node){

  word w;
  word key;
  Iterator iter;

  key.i = node;
  iter = get_Iterator(graph[node]->parents);
  while(!is_empty(iter)){
    w = next_key(iter);
    rem(graph[w.i]->children, key);
  }
  iter = get_Iterator(graph[node]->children);
  while(!is_empty(iter)){
    w = next_key(iter);
    rem(graph[w.i]->parents, key);
  }
}

void add_edge(Neighborhood * graph, int parent, int child){

  word w;

  w.i = child;
  put(graph[parent]->children, w, w);
  w.i = parent;
  put(graph[child]->parents, w, w);
}

void remove_edge(Neighborhood * graph, int parent, int child){

  word w;

  w.i = child;
  rem(graph[parent]->children, w);
  w.i = parent;
  rem(graph[child]->parents, w);
}

Elimination create_Elimination(Map ordering, Map cliques, int ** fill_ins,
    Map node_map){

  Elimination elim = (Elimination) malloc(sizeof(struct elimination));

  elim->ordering = ordering;
  elim->cliques = cliques;
  elim->fill_ins = fill_ins;
  elim->node_map = node_map;

  return elim;
}

void destroy_Node(Node node){

  if(node){
    free(node);
  }
}

void destroy_Elimination(Elimination elim){

  word w;
  Iterator iter;

  if(elim){
    destroy_Map(elim->ordering);
    if(elim->cliques){
      iter = get_Iterator(elim->cliques);
      while(!is_empty(iter)){
        w = next_value(iter);
        destroy_Map((Map) w.v);
      }
      destroy_Map(elim->cliques);
    }
    if(elim->fill_ins){
      if(elim->fill_ins[0]){
        free(elim->fill_ins[0]);
      }
      free(elim->fill_ins);
    }
    if(elim->node_map){
      iter = get_Iterator(elim->node_map);
      while(!is_empty(iter)){
        w = next_key(iter);
        if(w.v){
          destroy_Node((Node) w.v);
        }
      }
      destroy_Map(elim->node_map);
    }
    free(elim);
  }
}

Map get_ordering(Elimination elim){

  return elim->ordering;
}

int ** get_fill_ins(Elimination elim){

  return elim->fill_ins;
}

Map get_cliques(Elimination elim){

  return elim->cliques;
}

Node create_Node(int index, float weight){

  Node node = (Node) malloc(sizeof(struct node));

  node->index = index;
  node->weight = weight;

  return node;
}

int get_index(Node node){

  return node->index;
}

Elimination elim(int size, Map * adj_list, Neighborhood * partial_order,
  Map node_map);

Elimination find_elim(int size, float ** adj_mat, int ** order,
    int max_neighbors){
 
  int i, j;
  word w, value;
  Map * adj_list;
  Elimination e;
  Neighborhood * partial_order;
  Map node_map;

  node_map = create_Map(size * size, ptr_compare, hash_ptr, empty(), 2);

  if(size == 0 || adj_mat == (float **) NULL){
    return (Elimination) NULL;
  }
  if(max_neighbors <= 0){
    max_neighbors = size;
  }
  adj_list = (Map *) malloc(sizeof(Map) * size);
  for(i = 0; i < size; i++){
    adj_list[i] = create_Map(max_neighbors, compare, hash_int, empty(), 1);
  }

  for(i = 0; i < size; i++){
    for(j = 0; j < size; j++){
      if(adj_mat[i][j] > 0){
        w.i = j;
        value.v = create_Node(w.i, adj_mat[i][j]);
        put(node_map, value, value);
        put(adj_list[i], w, value);
      }
    }
    w.i = i;
  }
  partial_order = (Neighborhood *) malloc(sizeof(Neighborhood) * size);
  for(i = 0; i < size; i++){
    partial_order[i] = create_Neighborhood(max_neighbors);
  }
  if(order){
    for(i = 0; i < size; i++){
      for(j = 0; j < size; j++){
        if(order[i][j] > 0){
          add_edge(partial_order, i, j);
        }
      }
    }
  }
  e = elim(size, adj_list, partial_order, node_map);

  for(i = 0; i < size; i++){
    destroy_Map(adj_list[i]);
  }
  free(adj_list);
  for(i = 0; i < size; i++){
    destroy_Neighborhood(partial_order[i]);
  }
  free(partial_order);
  return e;
}

int is_clique_heuristic(int node, Map * adj_list){

  word w;
  unsigned long size;
  Iterator iter;

  size = get_size_Map(adj_list[node]);
  iter = get_Iterator(adj_list[node]);

  while(!is_empty(iter)){
    w = next_value(iter);
    if(get_size_Map(adj_list[((Node) w.v)->index]) < size){
      return 0;
    }
  }
  return 1;
}

int is_clique(int node, Map * adj_list, int size){

  word w, w2;
  Map map = create_Map(size, compare, hash_int, empty(), 1);
  Iterator iter = get_Iterator(adj_list[node]);

  while(!is_empty(iter)){
    w = next_value(iter);
    w2.i = ((Node) w.v)->index;
    put(map, w2, w);
  }
  while(get_size_Map(map) > 0){
    iter = get_Iterator(map);
    w = next_key(iter);
    rem(map, w);
    if(!is_subset_of(map, adj_list[w.i])){
      destroy_Map(map);
      return 0;
    }
  }
  destroy_Map(map);
  return 1;
}

/*
    if can find adj_list[i] that is a clique
      remove i, all edges from i;
      ordering[o++] = i;
      cliques[c++] = adj_list[i];
    else find adj_list[i] with smallest clique weight
      remove i, all edges from i;
      ordering[o++] = i;
      make adj_list[i] a clique;
      cliques[c++] = adj_list[i];
*/
Elimination elim(int size, Map * adj_list, Neighborhood * partial_order,
    Map node_map){

  Map ordering, cliques, max_cliques, trashcan;
  int i, j, clique_exists, min_node, subset, index1, index2;
  float min_weight, weight;
  word w, w2, child, child2;
  Iterator iter, iter2;
  Map nodes = create_Map(size, compare, hash_int, empty(), 1);
  Map roots = create_Map(size, compare, hash_int, empty(), 1);
  int ** fill_ins;

  fill_ins = (int **) malloc(sizeof(int *) * size);
  fill_ins[0] = (int *) malloc(sizeof(int) * size * size);

  for(i = 1; i < size; i++){
    fill_ins[i] = fill_ins[i - 1] + size;
  }
  for(i = 0; i < size; i++){
    for(j = 0; j < size; j++){
      fill_ins[i][j] = 0;
    }
  }

  for(i = 0; i < size; i++){
    w.i = i;
    put(nodes, w, w);
  }
  find_roots(partial_order, nodes, roots);

  ordering = create_Map(size + 1, compare, hash_int, empty(), 1);
  cliques = create_Map(size + 1, set_compare, hash_set, empty(), 1);

  while(get_size_Map(nodes) > 0){
    clique_exists = 0;
    iter = get_Iterator(roots);
    while(!is_empty(iter)){
      w = next_key(iter);
      if(is_clique_heuristic(w.i, adj_list) && is_clique(w.i, adj_list, size)){
        clique_exists = 1;
        break;
      }
    }
    if(!clique_exists){
      min_weight = LONG_MAX;
      iter = get_Iterator(roots);
      while(!is_empty(iter)){
        w = next_value(iter);
        weight = 0;
        iter2 = get_Iterator(adj_list[w.i]);
        while(!is_empty(iter2)){
          weight += ((Node) next_value(iter2).v)->weight;
        }
        if(weight < min_weight){
          min_weight = weight;
          min_node = w.i;
        }
      }
      w.i = min_node;
    }
    min_node = w.i;
    rem(nodes, w);
    remove_node(partial_order, w.i);
    empty_Map(roots);
    find_roots(partial_order, nodes, roots);
    put(ordering, w, w);
    child.v = adj_list[w.i];

    if(!find((Map) child.v, w)){
      child2.v = create_Node(w.i, 0);
      put(node_map, child2, child2);
      put((Map) child.v, w, child2);
    }
    child.v = copy_Map((Map) child.v);
    put(cliques, child, child);
    iter = get_Iterator(adj_list[min_node]);
    i = 0;
    while(!is_empty(iter)){
      child = next_value(iter);
      rem(adj_list[((Node) child.v)->index], w);
    }
    iter = create_Iterator(adj_list[min_node]);
    while(!is_empty(iter)){
      child = next_value(iter);
      index1 = ((Node) child.v)->index;
      w.i = index1;
      iter2 = get_Iterator(adj_list[min_node]);
      while(!is_empty(iter2)){
        child2 = next_value(iter2);
	index2 = ((Node) child2.v)->index;
	if(index1 != index2){
          w2.i = index2;
          if(index1 < index2 && !find(adj_list[index1], w2)){
            fill_ins[index1][index2] = 1;
	  }
          put(adj_list[index1], w2, child2);
        }
      }
    }
    destroy_Iterator(iter);
  }
  destroy_Map(nodes);
  destroy_Map(roots);

  max_cliques = create_Map(size, set_compare, hash_set, empty(), 2);
  trashcan = create_Map(size, set_compare, hash_set, empty(), 2);
  while(get_size_Map(cliques) > 0){
    iter = get_Iterator(cliques);
    child = next_key(iter);
    rem(cliques, child);
    subset = 0;
    while(!is_empty(iter)){
      child2 = next_key(iter);
      if(is_subset_of((Map) child2.v, (Map) child.v)){
        rem(cliques, child2);
	put(trashcan, child2, child2);
      } else if(is_subset_of((Map) child.v, (Map) child2.v)){
         subset = 1;
	 break;
      }
    }
    if(!subset){
      put(max_cliques, child, child);
    } else {
      put(trashcan, child, child);
    }
  }

  destroy_Map(cliques);
  iter = get_Iterator(trashcan);
  while(!is_empty(iter)){
    child = next_key(iter);
    destroy_Map((Map) child.v);
  }
  destroy_Map(trashcan);
  return create_Elimination(ordering, max_cliques, fill_ins, node_map);
}
