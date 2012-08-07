/* elim.h
 */

#ifndef _ELIM_H_
#define _ELIM_H_

#include "map.h"

typedef struct elimination * Elimination;
typedef struct node * Node;

Elimination find_elim(int size, float ** adj_mat, int ** order,
    int max_neighbors);

void destroy_Elimination(Elimination elim);

Map get_ordering(Elimination elim);
Map get_cliques(Elimination elim);
int ** get_fill_ins(Elimination elim);

int get_index(Node node);

#endif /* _ELIM_H_ */
