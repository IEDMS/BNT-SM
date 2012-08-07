/* cell.h
 */

#ifndef _CELL_H_
#define _CELL_H_

#include "misc.h"

typedef struct cell * Cell;

Cell create_Cell(word data);

void print_Cell(Cell cell);

void destroy_Cell(Cell cell);
void destroy_all_next(Cell cell);
void destroy_all_prev(Cell cell);

Cell copy_Cell(Cell cell);
Cell copy_all_next(Cell cell);
Cell copy_all_prev(Cell cell);

Cell insert_before(Cell cell, word data);
Cell insert_after(Cell cell, word data);

Cell insert_Cell_before(Cell cell, Cell new);
Cell insert_Cell_after(Cell cell, Cell new);

void set_data(Cell cell, word data);
word get_data(Cell cell);

Cell remove_Cell(Cell cell);

int first_Cell(Cell cell);
int last_Cell(Cell cell);
Cell next_Cell(Cell cell);
Cell prev_Cell(Cell cell);

#endif /* _CELL_H_ */
