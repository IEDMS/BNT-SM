/* best_first_elim_order.c written by Ilya Shpitser  */

#include <stdlib.h>
#include <stdio.h>

#include "matlab.h"

#include "mex.h"

#include "elim.h"
#include "map.h"
#include "misc.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){

  int i, j, k, l, m, n, o;
  long index;
  double * G_pr;
  double * node_sizes_pr;
  double * order_pr;
  double * stage_pr;
  double * t_pr, * t_next_pr;
  mxArray * slice_t;
  mxArray * slice_t_next;
  Elimination e;
  float ** adj_mat;
  int ** order = NULL;
  Iterator iter;
  word w;
  mxArray * full;

  full = mlfFull((mxArray *) prhs[0]);
  /* Obtain graph matrix information. */
  m = mxGetM(full);
  n = mxGetN(full);
  G_pr = mxGetPr(full);
  node_sizes_pr = mxGetPr(prhs[1]);

  if(n < 1 || m < 1){
    return;
  }
  /* Allocate and populate the log weight adjacency matrix corresponding
     to the input graph. */
  adj_mat = (float **) malloc(sizeof(float *) * m);
  adj_mat[0] = (float *) malloc(sizeof(float) * m * n);
  for(i = 1; i < m; i++){
    adj_mat[i] = adj_mat[i - 1] + n;
  }
  /* Make sure adj_mat contains log weights. */
  for(i = 0; i < m; i++){
    for(j = 0; j < n; j++){
      index = j * m + i;
      if(G_pr[index] > 0){
        adj_mat[i][j] = node_sizes_pr[j];
      } else {
        adj_mat[i][j] = 0;
      }
    }
  }
  mxDestroyArray(full);
  /* If the stages argument exists, convert it to a partial
     order DAG, otherwise set it to NULL. */
  if(nrhs > 2){
    order = (int **) malloc(sizeof(int *) * m);
    order[0] = (int *) malloc(sizeof(int) * m * n);
    for(i = 1; i < m; i++){
      order[i] = order[i - 1] + n;
    }
    for(i = 0; i < m; i++){
      for(j = 0; j < n; j++){
        order[i][j] = 0;
      }
    }
    for(i = 0; i < mxGetN(prhs[2]) - 1; i++){
      slice_t = mxGetCell(prhs[2], i);
      slice_t_next = mxGetCell(prhs[2], i + 1);
      t_pr = mxGetPr(slice_t);
      j = mxGetM(slice_t);
      o = mxGetN(slice_t);
      if(j > o){
        o = j;
      }
      j = mxGetM(slice_t_next);
      l = mxGetN(slice_t_next);
      if(j > l){
        l = j;
      }
      t_next_pr = mxGetPr(slice_t_next);
      for(j = 0; j < o; j++){
        for(k = 0; k < l; k++){
          order[(int) t_pr[j] - 1][(int) t_next_pr[k] - 1] = 1;
        }
      }
    }
  }
  /* Find the elimination ordering. */
  e = find_elim(n, adj_mat, order, -1);
  /* Allocate memory for the answer vector. */
  plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);
  order_pr = mxGetPr(plhs[0]);

  /* Populate the answer vector with the elimination ordering.
     Note that find_elim returns elimination ordering in reverse
     order, which is why they are added from the end. */
  i = n - 1;
  iter = get_Iterator(get_ordering(e));
  while(!is_empty(iter)){
    w = next_key(iter);
    order_pr[i--] = w.i + 1;
  }

  /* Finally, free the allocated memory. */
  destroy_Elimination(e);
  if(adj_mat){
    if(adj_mat[0]){
      free(adj_mat[0]);
    }
    free(adj_mat);
  }
  if(order){
    if(order[0]){
      free(order[0]);
    }
    free(order);
  }
}
