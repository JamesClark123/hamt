A basic implementation of the HAMT data structure. This code focuses on performance testing of the HAMT structure using Core_bench from Jane Street, so this module is required. To allow pretty printing of the data structure graphviz must be installed along with python.

Compile and run performance tests with:

```
> make

> ./go
```

To compile and run the pretty printer:

```
> make

> ./go -p [size]
```
Where [size] is the number of elements in the structure you want to see.



Although I still wish to put more work into testing and making sure the tests are correct, the current performance results from Core_bench show:
---
![alt text](https://github.com/JamesClark123/hamt/blob/master/imgs/Percent%20Relative%20Performance%20for%20Find.png "Find Performance")
![alt text](https://github.com/JamesClark123/hamt/blob/master/imgs/Percent%20Relative%20Performance%20for%20Insert.png "Insert Performance")
![alt text](https://github.com/JamesClark123/hamt/blob/master/imgs/Percent%20Relative%20Performance%20for%20Make.png "Make Performance")
