/* misc.h
 */

#ifndef _MISC_H_
#define _MISC_H_

union u_word {

  int i;
  float r;
  void *v;
};

typedef union u_word word;

void randomize();

#endif /* _MISC_H_ */
