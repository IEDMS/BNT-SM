/* cell.c
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "cell.h"

struct cell {

  word data;
  Cell prev;
  Cell next;
};

void print_Cell(Cell cell){

  printf("(%p, %p, %p)\n", (cell ? cell->prev : cell), cell,
    (cell ? cell->next : cell));
}

Cell create_Cell(word data){

  Cell cell = (Cell) malloc(sizeof(struct cell));

  cell->data = data;
  cell->prev = (Cell) NULL;
  cell->next = (Cell) NULL;

  return cell;
}

Cell copy_Cell(Cell cell){

  Cell c;

  if(!cell){
    return (Cell) NULL;
  } else {
    c = create_Cell(cell->data);
    c->next = copy_all_next(cell->next);
    if(c->next){
      c->next->prev = c;
    }
    c->prev = copy_all_prev(cell->prev);
    if(c->prev){
      c->prev->next = c;
    }
    return c;
  }
}

Cell copy_all_next(Cell cell){

  Cell c;

  if(!cell){
    return (Cell) NULL;
  } else {
    c = create_Cell(cell->data);
    c->next = copy_all_next(cell->next);
    if(c->next){
      c->next->prev = c;
    }
    return c;
  }
}

Cell copy_all_prev(Cell cell){

  Cell c;

  if(!cell){
    return (Cell) NULL;
  } else {
    c = create_Cell(cell->data);
    c->prev = copy_all_prev(cell->prev);
    if(c->prev){
      c->prev->next = c;
    }
    return c;
  }
}

void destroy_Cell(Cell cell){

  if(cell){
    free(cell);
  }
}

void destroy_all_next(Cell cell){

  if(cell){
    destroy_all_next(cell->next);
    free(cell);
  }
}

void destroy_all_prev(Cell cell){

  if(cell){
    destroy_all_prev(cell->prev);
    free(cell);
  }
}

Cell insert_before(Cell cell, word data){

  return insert_Cell_before(cell, create_Cell(data));
}

Cell insert_after(Cell cell, word data){

  return insert_Cell_after(cell, create_Cell(data));
}

Cell insert_Cell_before(Cell cell, Cell new){

  if(cell){
    new->next = cell;
    new->prev = cell->prev;
    if(cell->prev){
      cell->prev->next = new;
    }
    cell->prev = new;
  }
  return new;
}

Cell insert_Cell_after(Cell cell, Cell new){

  if(cell){
    new->prev = cell;
    new->next = cell->next;
    if(cell->next){
      cell->next->prev = new;
    }
    cell->next = new;
  }
  return new;
}

Cell remove_Cell(Cell cell){

  if(cell->next){
    cell->next->prev = cell->prev;
  }
  if(cell->prev){
    cell->prev->next = cell->next;
  }
  return cell;
}

void set_data(Cell cell, word data){

  cell->data = data;
}

word get_data(Cell cell){

  return cell->data;
}

int first_Cell(Cell cell){

  return cell->prev == (Cell) NULL;
}

int last_Cell(Cell cell){

  return cell->next == (Cell) NULL;
}

Cell next_Cell(Cell cell){

  if(cell){
    return cell->next;
  }
  return (Cell) NULL;
}

Cell prev_Cell(Cell cell){

  if(cell){
    return cell->prev;
  }
  return (Cell) NULL;
}

