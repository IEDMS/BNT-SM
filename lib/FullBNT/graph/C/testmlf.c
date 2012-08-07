
#include <stdlib.h>
#include <stdio.h>

#include "matlab.h"
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
  mxArray * full;

  full = mlfFull((mxArray *) prhs[0]);

  plhs[0] = full;
}
