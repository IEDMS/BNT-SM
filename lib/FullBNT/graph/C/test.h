/* test.h
 */

#ifndef _TEST_H_
#define _TEST_H_

void test_elim_from_adj_mat();

void gen_adj_mat(int size, float edge_prob, float min_log_weight,
  float max_log_weight, float ***adj_mat);

void free_adj_mat(float **adj_mat);

#endif /* _TEST_H_ */
