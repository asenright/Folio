#include "pseudoScheduler.h"

/////////////////////////Main///////////////
int main(int argc, char *argv[]) {
///Get  and Check Command Arguments
	if (argc < 3 ) {
		fprintf(stderr, "ERROR: Usage: pseudoScheduler input-file LRU|FIFO|OPT \n");
		exit(0);
	}
    FILE *fp;
	fp = fopen(argv[1], "r");
	if (fp == NULL) {
		fprintf(stderr, "ERROR: Could not open file %s\n", argv[1]);
		exit(0);
	}

	int numPages, numFrames, numRequests, result, cur;
	
	////Read first line of file to get runtime parameters
	if ((result = fscanf(fp, "%d %d %d", &numPages, &numFrames, &numRequests)) == EOF) {
		fprintf(stderr, "ERROR: Could not parse line 1 of file\n");
		exit(0);
	}
	printf("Initializing with %d pages, %d frames, %d requests\n", numPages, numFrames, numRequests);
	
	//////Verify input//////////////////////////////////////////////
	if (!numPages || numPages < 1 || numPages > INT_MAX	) {
		fprintf(stderr, "ERROR: Argument 1, number of pages, shall be a positive integer between 1 and %d\nIt was either out of bounds or not found.\n", INT_MAX);
		exit(0);
	}
	if (!numFrames || numFrames < 1 || numFrames > INT_MAX	) {
		fprintf(stderr, "ERROR: Argument 2, number of frames, shall be a positive integer between 1 and %d\nIt was either out of bounds or not found.\n", INT_MAX);
		exit(0);
	}
	if (!numRequests || numRequests < 1 || numRequests > INT_MAX	) {
		fprintf(stderr, "ERROR: Argument 3, number of requests, shall be a positive integer between 1 and %d\nIt was either out of bounds or not found.\n", INT_MAX);
		exit(0);
	}
	//////Establish data structures for pages and for requests
	int requests[numRequests];
	
	////////Fill data structures by reading from input file
	int index = 0;
    while ((result = fscanf(fp, "%d", &cur)) != EOF) {
		if (index >= numRequests) {
			fprintf(stderr, "ERROR: too many lines in file\n");
			exit(0);
		}
		if (!cur || cur < 1 || cur > INT_MAX) {
			fprintf(stderr, "ERROR: could not parse request on line %d\n", index + 1);
			exit(0);
		}
		requests[index] = cur;
		index++;
    }

	//Verify array fill
	if (index < numRequests ) {
		fprintf(stderr, "ERROR: too many lines in file.\nNumber of requests should equal argument 3 of the first line.\n");
		exit(0);
	}
	int numFaults;
	if (strcmp(argv[2], "FIFO") == 0) {
		numFaults = FIFO(requests, numRequests, numFrames);
		printf("Number of faults: %d\n", numFaults);
	} else if (strcmp(argv[2], "LRU") == 0) {
		numFaults = LRU(requests, numRequests, numFrames);
		printf("Number of faults: %d\n", numFaults);
	} else if (strcmp(argv[2], "OPT") == 0) {
		numFaults = OPT(requests, numRequests, numFrames);
		printf("Number of faults: %d\n", numFaults);
	} else {
		printf("Scheduler archetype not recognized: \"%s\"\nPlease specfy \"LRU\", \"FIFO\", or \"OPT\".\n", argv[2]);
	}
	
	printf("Exiting main...\n");
	exit(0);	
}

int FIFO(int * requests, int numRequests, int numFrames) {
	printf("Using FIFO Algorithm:\n");
	pageFrame_t frames[numFrames];

	int index, numFaults = 0;
	
	for (index = 0; index < numFrames; index++) {
		frames[index].timeEnteredQueue = -1;
		frames[index].pageNumber = -1;
		frames[index].lastAccessedTime = -1;
	}
	
	for (index = 0; index < numRequests; index++) {
		//This should execute per-every-request
		int currentRequestedPageNumber = requests[index];
		//printf("Current request: %d\n", currentRequestedPageNumber);
		int found = 0, innerIndex, indexOfPageToReplace = -1, timeEnteredQ_ofPageToReplace = numRequests + 1; //We want this to get replaced the first time
		//For FIFO, the page to replace will be the one with the greatest age
		
		for (innerIndex = numFrames - 1; innerIndex >= 0; innerIndex--) {
			//Check each frame; if frame holds our page we're good
			//printf("	Searching for page %d, frame %d: Page %d | Birthday %d | LastAccess %d\n", currentRequestedPageNumber, innerIndex, frames[innerIndex].pageNumber, frames[innerIndex].timeEnteredQueue, frames[innerIndex].lastAccessedTime);
			
			if ((frames[innerIndex].pageNumber) == currentRequestedPageNumber) {
				printf("	Page %d already in frame %d.\n", currentRequestedPageNumber, innerIndex);
				frames[innerIndex].lastAccessedTime = index; //Update last accessed time to current index.
				found++;
				
				break; //Sends you to next request.
			}
			
			//While we're iterating through frames, we're going to keep in mind we may have to replace one.
			//Since we don't want to iterate through multiple times (we don't know how many pages there may be), we'll 
			//keep an eye open for the frame we want to replace.
			
			if ((frames[innerIndex].timeEnteredQueue) < timeEnteredQ_ofPageToReplace) {
				//FIFO ONLY: If we're looking at the oldest page, then we want to replace it.
				indexOfPageToReplace = innerIndex;
				timeEnteredQ_ofPageToReplace = (frames[innerIndex].timeEnteredQueue);
			}
		}
		if (found == 0) {
			//Reaching this stage means page not found!
			if (frames[indexOfPageToReplace].pageNumber >= 0) {
				printf("	Page %d unloaded from frame %d. Page %d loaded into frame %d. \n", 
				frames[indexOfPageToReplace].pageNumber, indexOfPageToReplace, currentRequestedPageNumber,indexOfPageToReplace,frames[indexOfPageToReplace].pageNumber);
			} else {
				printf("	Page %d loaded into frame %d.\n", currentRequestedPageNumber,indexOfPageToReplace);	
			}
			
			frames[indexOfPageToReplace].timeEnteredQueue = index;
			frames[indexOfPageToReplace].pageNumber = currentRequestedPageNumber;
			frames[indexOfPageToReplace].lastAccessedTime = index;
			numFaults++;
		}
	}
	return numFaults;
}

int LRU(int * requests, int numRequests, int numFrames) {
	printf("Using LRU Algorithm:\n");
	pageFrame_t frames[numFrames];

	int index, numFaults = 0;
	
	for (index = 0; index < numFrames; index++) {
		frames[index].timeEnteredQueue = -1;
		frames[index].pageNumber = -1;
		frames[index].lastAccessedTime = -1;
	}
	
	for (index = 0; index < numRequests; index++) {
		//This should execute per-every-request
		int currentRequestedPageNumber = requests[index];
		//printf("Current request: %d\n", currentRequestedPageNumber);
		int found = 0, innerIndex, indexOfPageToReplace = -1, lastAccessTime_pageToReplace = numRequests + 1; //We want this to get replaced the first time

		for (innerIndex = numFrames - 1; innerIndex >= 0; innerIndex--) {
			//printf("	Searching for page %d, frame %d: Page %d | Birthday %d | LastAccess %d\n", currentRequestedPageNumber, innerIndex, frames[innerIndex].pageNumber, frames[innerIndex].timeEnteredQueue, frames[innerIndex].lastAccessedTime);
			
			if ((frames[innerIndex].pageNumber) == currentRequestedPageNumber) {
				printf("	Page %d already in frame %d.\n", currentRequestedPageNumber, innerIndex);
				frames[innerIndex].lastAccessedTime = index; //Update last accessed time to current index.
				found++;
				
				break; //Sends you to next request.
			}
			
			//While we're iterating through frames, we're going to keep in mind we may have to replace one.
			//Since we don't want to iterate through multiple times (we don't know how many pages there may be), we'll 
			//keep an eye open for the frame we want to replace.
			
			if ((frames[innerIndex].lastAccessedTime) < lastAccessTime_pageToReplace) {
				
				indexOfPageToReplace = innerIndex;
				lastAccessTime_pageToReplace = (frames[innerIndex].lastAccessedTime);
			}
		}
		if (found == 0) {
			//Reaching this stage means page not found!
			if (frames[indexOfPageToReplace].pageNumber >= 0) {
				printf("	Page %d unloaded from frame %d. Page %d loaded into frame %d. \n", 
				frames[indexOfPageToReplace].pageNumber, indexOfPageToReplace, currentRequestedPageNumber,indexOfPageToReplace,frames[indexOfPageToReplace].pageNumber);
			} else {
			printf("	Page %d loaded into frame %d.\n", currentRequestedPageNumber,indexOfPageToReplace);	
			}
			frames[indexOfPageToReplace].timeEnteredQueue = index;
			frames[indexOfPageToReplace].pageNumber = currentRequestedPageNumber;
			frames[indexOfPageToReplace].lastAccessedTime = index;
			numFaults++;
		}
	}
	return numFaults;
}

int OPT(int * requests, int numRequests, int numFrames) {
	printf("Using OPT Algorithm:\n");
	pageFrame_t frames[numFrames];

	int index, numFaults = 0;
	for (index = 0; index < numFrames; index++) {
		frames[index].timeEnteredQueue = -1;
		frames[index].pageNumber = -1;
		frames[index].lastAccessedTime = -1;
		frames[index].nextAccessTime = -1;
	}
	for (index = 0; index < numRequests; index++) {
		//This should execute per-every-request
		int currentRequestedPageNumber = requests[index];
		//printf("Current request: %d\n", currentRequestedPageNumber);
		int found = 0, innerIndex, indexOfPageToReplace = -1, nextAccessTime_pageToReplace = numRequests + 1; //We want this to get replaced the first time

		//No lookahead needed if no more requests are coming.
		if (innerIndex + 1 < numRequests) {
			//First, sweep through remaining queue. We want to know if we have a page thats going to be needed.
			for (innerIndex = numRequests ; innerIndex  > index; innerIndex--) {
			//for (innerIndex = index ; innerIndex  < numRequests; innerIndex++) {
				int currentlyRequestedPage = requests[innerIndex];
				int frameCursor = 0;
				for (frameCursor = numFrames -1; frameCursor > 0 ; frameCursor--) {
					if (frames[frameCursor].pageNumber >= 0 && frames[frameCursor].pageNumber == currentlyRequestedPage) {
						//printf("Lookahad sees page %d from frame %d will be needed at time %d\n",frames[frameCursor].pageNumber, frameCursor, innerIndex);
						
						frames[frameCursor].nextAccessTime = innerIndex;
						//frameCursor = numFrames + 1; //Break from FOR loop.
						//innerIndex = numRequests;
						//break;
					}
				}
				
			
			}
		}
		///SEEK: Searches for candidate for page replacement
		for (innerIndex = 0; innerIndex < numFrames ; innerIndex++) {
			//printf("	Searching for page %d, frame %d: Page %d | Birthday %d | LastAccess %d\n", currentRequestedPageNumber, innerIndex, frames[innerIndex].pageNumber, frames[innerIndex].timeEnteredQueue, frames[innerIndex].lastAccessedTime);
			
			if ((frames[innerIndex].pageNumber) == currentRequestedPageNumber) {
				printf("	Page %d already in frame %d.\n", currentRequestedPageNumber, innerIndex);
				frames[innerIndex].lastAccessedTime = index; //Update last accessed time to current index.
				found++;
				
				break; //Sends you to next request.
			}
			
			//While we're iterating through frames, we're going to keep in mind we may have to replace one.
			//Since we don't want to iterate through multiple times (we don't know how many pages there may be), we'll 
			//keep an eye open for the frame we want to replace.
			
			if (//(frames[innerIndex].nextAccessTime) == -1 || //Page hasn't been assigned to yet. Should be first candidate
				(frames[innerIndex].nextAccessTime) < index || //This case means it won't be needed again. Next best candidate.
				((frames[innerIndex].nextAccessTime) >= index &&  // Page will be needed again, and
				(frames[innerIndex].nextAccessTime) < nextAccessTime_pageToReplace)) { //will be needed further in the future than the current candidate
				indexOfPageToReplace = innerIndex;
				nextAccessTime_pageToReplace = (frames[innerIndex].nextAccessTime);
				//printf("Got better candidate for page replacement: Frame %d with Page %d, NAT %d\n", indexOfPageToReplace, frames[innerIndex].pageNumber, nextAccessTime_pageToReplace);
			}
		}
		if (found == 0) {
			//Reaching this stage means page not found!
			if (frames[indexOfPageToReplace].pageNumber >= 0) {
				printf("	Page %d unloaded from frame %d. Page %d loaded into frame %d. \n", 
				frames[indexOfPageToReplace].pageNumber, indexOfPageToReplace, currentRequestedPageNumber,indexOfPageToReplace,frames[indexOfPageToReplace].pageNumber);
			} else {
				printf("	Page %d loaded into frame %d.\n", currentRequestedPageNumber,indexOfPageToReplace);	
			}
			frames[indexOfPageToReplace].timeEnteredQueue = index;
			frames[indexOfPageToReplace].pageNumber = currentRequestedPageNumber;
			frames[indexOfPageToReplace].lastAccessedTime = index;
			frames[indexOfPageToReplace].nextAccessTime = index;
			numFaults++;
		}
	}
	return numFaults;
}

