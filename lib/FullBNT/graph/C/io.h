/* io.h
 */

#ifndef _IO_H_
#define _IO_H_

#include "map.h"

void write_adj_mat(char *filename, int size, float **adj_mat);
int read_adj_mat(char *filename, float ***adj_mat);
void print_ordering(Map ordering);
void print_cliques(Map cliques);

#endif /* _IO_H_ */
