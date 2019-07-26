1. Drop File System Cache before every experiment by running these commands and check if variance goes away.
echo 3 > /proc/sys/vm/drop_caches
sync

$ echo 3 | sudo tee /proc/sys/vm/drop_caches && sync && time -p git status
real 2,57
$ time -p git status
real 0,40

$ perf stat -r 10 -- git status
 Performance counter stats for 'git status' (10 runs):

        435,163622      task-clock (msec)         #    1,039 CPUs utilized            ( +-  3,62% )
               151      context-switches          #    0,347 K/sec                    ( +-  7,65% )
                10      cpu-migrations            #    0,023 K/sec                    ( +- 25,71% )
             5 171      page-faults               #    0,012 M/sec                    ( +-  0,02% )
   <not supported>      cycles                                                      
   <not supported>      instructions                                                
   <not supported>      branches                                                    
   <not supported>      branch-misses                                               

       0,418973869 seconds time elapsed                                          ( +-  2,93% )

$ perf stat -r 10 -- git status
Performance counter stats for 'git status taskset -c 1' (10 runs):

        420,948182      task-clock (msec)         #    0,985 CPUs utilized            ( +-  2,50% )
               102      context-switches          #    0,243 K/sec                    ( +-  6,00% )
                 0      cpu-migrations            #    0,000 K/sec                    ( +-100,00% )
             5 233      page-faults               #    0,012 M/sec                    ( +-  0,01% )
   <not supported>      cycles                                                      
   <not supported>      instructions                                                
   <not supported>      branches                                                    
   <not supported>      branch-misses                                               

       0,427527231 seconds time elapsed 
	   
 Performance counter stats for 'sudo nice -n -5 taskset -c 1 git status' (10 runs):

          0,003217      task-clock (msec)         #    0,000 CPUs utilized            ( +- 12,13% )
                 0      context-switches          #    0,000 K/sec                  
                 0      cpu-migrations            #    0,000 K/sec                  
                 0      page-faults               #    0,000 K/sec                  
   <not supported>      cycles                                                      
   <not supported>      instructions                                                
   <not supported>      branches                                                    
   <not supported>      branch-misses                                               

       0,441287889 seconds time elapsed                                          ( +-  1,62% )
