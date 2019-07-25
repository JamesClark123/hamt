This project is a persistent implementation of the HAMT data structure, currently without sparse arrays or table resizing. The rest of this readme contains a description of the HAMT structure along with some performace testing of my code.

For a more detailed description of HAMT, I recommend [Ideal Hash Trees](https://infoscience.epfl.ch/record/64398/files/idealhashtrees.pdf) by Phil Bagwell.

# What is HAMT?

HAMT stands for Hash Array Mapped Trie and the data structure is considered a very performant implementation of a hash tree. The basic idea for the structure involves storing key-values in a trie by using bits from the key hash to index a path along said trie. Each node in the trie contains a map that holds both values and pointers to more nodes, allowing simultaneously for the storage of key-value pairs and sub-tries. Fig 1 below shows an example of a trie containing three subtries and a key/value pair.

![Sample Hamt Structure](/imgs/Sample_Hamt_Structure.png)


 This code focuses on performance testing of the HAMT structure using Core_bench from Jane Street, so this module is required. To allow pretty printing of the data structure graphviz must be installed along with python.

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
