<h1>Paging Scheduler</h1>
<h2>About</h2>
'pseudoScheduler' is a command-line program that simulates how an operating system caches pages in memory. Its purpose is to showcase various page-replacement algorithms. Ideally, you want to access the hard drive just once per page, but with a limited number of frames in which to place the pages, we have to determine where to put that page in memory. It takes command-line input for an input file and algorithm selection; currently available algorithms in this software are First-In-First-Out, Least-Recently Used, and Optimal.

<h2>Expected Usage</h2>
	Expected usage of this program is
	"sched input.l FIFO|LRU|OPT"
	For example,
	"sched input.l OPT"
	will run the pseudo-scheduler with the numbers in input.l using the "OPTIMAL" algorithm, least-needed page gets thrown. 

	To recompile, run:
	"gcc sched.c -o sched"
	
	Input.l is a multi-part file. The first line dictates the number of pages, frames, and requests.
	The number of requests must be the same as the number of lines beyond the first!
	Lines 2 and beyond are page requests, i.e. '3' represents a request for page 3.

<h2>Files Included</h2>

	sched.c: Main executable code.
	sched.h: Header file. Contains other "include" declarations, function prototypes, and struct definition and alias.
	input.l: Sample input file.

<h2>Brief Description of Algorithms</h2>
	There are 3 algorithms available, which take advantage of the pages' metadata. 
	Metadata includes when the frame was assigned, when it was last used, and when it will next be used.

	FIFO will place a page in the frame with the oldest data.
	LRU will place a page in the frame whose data was accessed longest-ago.
	OPT will place a page in the frame whose data won't be needed for the longest time. Frames that will not be accessed again are prioritised.

	All algorithms prioritise filling empty frames.
