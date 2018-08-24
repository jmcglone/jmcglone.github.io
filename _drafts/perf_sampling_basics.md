$ perf record
The perf tool defaults to the average rate. It is set to 1000Hz, or 1000 samples/sec.
equivalent to:
$ perf record -F 1000
Perf will stop our programm 1000 times per second.
$ time -p perf record -F 1000 ./a_fall
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.110 MB perf.data (2451 samples) ] // 1 sample per millisecond
real 2.67
user 2.48	

$ time -p perf record -F 100 ./a_fall
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.026 MB perf.data (247 samples) ] // 1 sample per 10 milliseconds
real 2.66
user 2.48

$ perf report -D
...
// sample N
// 0x40090b - instruction offset in binary
// period: 32287405 - the number of occurrences of the event between two samples (explained below)
9253562614198937 0x4d18 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 20531/20531: 0x40090b period: 32287405 addr: 0 
 ... thread: a_fall:20531
 ...... dso: /export/users/dbakhval/block_placement/a_fall

0x4d40 [0x28]: event: 9
.
. ... raw event: size 40 bytes
.  0000:  09 00 00 00 02 00 28 00 15 0a 40 00 00 00 00 00  ......(...@.....
.  0010:  33 50 00 00 33 50 00 00 21 99 1e f1 10 e0 20 00  3P..3P..!..... .
.  0020:  3c 65 ee 01 00 00 00 00                          <e......        

// sample N + 1
9253562624153889 0x4d40 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 20531/20531: 0x400a15 period: 32400700 addr: 0
 ... thread: a_fall:20531
 ...... dso: /export/users/dbakhval/block_placement/a_fall

0x4d68 [0x28]: event: 9
.
. ... raw event: size 40 bytes
.  0000:  09 00 00 00 02 00 28 00 06 09 40 00 00 00 00 00  ......(...@.....
.  0010:  33 50 00 00 33 50 00 00 3d 9f bc f1 10 e0 20 00  3P..3P..=..... .
.  0020:  9f d3 e1 01 00 00 00 00                          ........  
...

Remember, by default we were sampling on cycles (equivalent to perf record -e cycles).
We collected 2451 samples. Let's assume average period for all samples is 32300000 events.
247 * 32300000 = 7978100000 cycles.
If we compare it with the number of counted cycles:

$ perf stat -e cycles ./a_fall                                                                                                           

 Performance counter stats for './a_fall':

        7805574851      cycles                                                      

       2,398101184 seconds time elapsed

7978100000 is not that off from 7805574851.


We can do the same with branch-misses:
$ perf record -F 1000 -e branch-misses ./a_fall                                                                                                        
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.109 MB perf.data (2417 samples) ]
$ perfRep -D | grep period
9254712117721275 0x1a758 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 21133/21133: 0x40051c period: 55754 addr: 0
9254712118718533 0x1a780 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 21133/21133: 0x40051c period: 55804 addr: 0

2417 samples * 55804 (period for each sample) = 134757418

$ perf stat -e branch-misses ./a_fall

 Performance counter stats for './a_fall':

         133366825      branch-misses                                               

       2,406486488 seconds time elapsed

Difference is within the noise level.

Same experiment we can do with the period option (-c):

$ perf record -e instructions -c 1000000 ./a_fall
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.436 MB perf.data (13731 samples) ]
$ perf stat -e instructions ./a_fall                                                                                                                      

 Performance counter stats for './a_fall':

       13706955042      instructions                                                

       2,443039456 seconds time elapsed

13731 * 1000000 = 13731000000 
		      vs
		  13706955042

But be carefull with this option, it doesn't always give you good results.


Understanding skid.
ToDo: 
1. Try to force certain event and try to sample on it using perf.
   For SNB it should show samples on IP + 1.
   For HSW it should show samples on IP.
2. Try non-precise events.
3. Try FE and BE event.

