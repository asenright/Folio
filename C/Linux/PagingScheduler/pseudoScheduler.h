#include "limits.h"
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

typedef struct pageFrame {
	int pageNumber, timeEnteredQueue, lastAccessedTime, nextAccessTime;
} pageFrame_t;

int FIFO(int * requests, int numRequests, int numFrames);
int LRU(int * requests, int numRequests, int numFrames);
int OPT(int * requests, int numRequests, int numFrames);