/* strong_elim_order.c
 */

#include <stdlib.h>

#include "matlab.h"
#include "mex.h"

#include "elim.h"
#include "map.h"
#include "misc.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){

  mxArray * full;
  int i, j, m, n;
  long index;
  double * G_pr;
  double * node_sizes_pr;
  double * order_pr;
  double * stage_pr;
  Elimination e;
  float ** adj_mat;
  int ** order = (int **) NULL;
  Iterator iter;
  word w;
  mxArray * fullG;

  fullG = mlfFull((mxArray *) prhs[0]);

  m = mxGetM(fullG);
  n = mxGetN(fullG);
  G_pr = mxGetPr(fullG);

  /* Obtain graph matrix information. */
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
  mxDestroyArray(fullG);

  /* If the partial_order argument exists, convert it to a partial
     order DAG, otherwise set it to NULL. */
  if(nrhs > 2){
    order = (int **) malloc(sizeof(int *) * m);
    order[0] = (int *) malloc(sizeof(int) * m * n);
    for(i = 1; i < m; i++){
      order[i] = order[i - 1] + n;
    }
    full = mlfFull((mxArray *) prhs[2]);
    stage_pr = mxGetPr(full);
    for(i = 0; i < m; i++){
      for(j = 0; j < n; j++){
        order[j][i] = stage_pr[j * m + i];
      }
    }
    mxDestroyArray(full);
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
