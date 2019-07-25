This project is a persistent implementation of the HAMT data structure, currently without sparse arrays or table resizing, that I completed for an independent study at Boston College. The rest of this readme contains a description of the HAMT structure along with some performace testing of my code.

For a more detailed description of HAMT, I recommend [Ideal Hash Trees](https://infoscience.epfl.ch/record/64398/files/idealhashtrees.pdf) by Phil Bagwell.

# What is HAMT?

HAMT stands for Hash Array Mapped Trie and the data structure is considered a very performant implementation of a hash tree. The **basic** idea for the structure involves storing key-values in a trie by using bits from the key hash to index a path along said trie. Each node in the trie contains a map that holds both values and pointers to more nodes, allowing simultaneously for the storage of key-value pairs and sub-tries. Fig 1 below shows an example of a trie containing three subtries and a key/value pair.

![Sample Hamt Structure](/imgs/Sample_Hamt_Structure.png "Fig 1")

With good hashing, this structure has an average depth of logN, where N is the number of elements in the structure. Thus, average access time for this basic version of HAMT is on the order of O(logN).

## Insert, Search, and Remove
Insert, Search, and Remove all follow the same general procedure of walking the tree, only differentiating when a terminal node in the trie is found. To walk the tree these procedure must look at consecutive t bits of the hash to determine the next subtrie index to move to. Where t is the power of two that represents the size of the array. So for an array of four t would be 2. A terminal node is determined to be when the alogirithm reaches either a key/value pair or a empty trie bin through this process.

An example of this process with insert is below in Fig 2. Here the objective is to insert a key g into the structure; this key produces a particular hash. Following the bits of that hash (we go by bits of 2 since the array is of size 4) we can trace down the trie. When we reach e (another key/value) we know we've reached a terminal node. To insert we compare the next two bits for both e and g. Finding them to be different we can create a new trie, copy the keys into it, and add that new trie into the previous location of the e key. Were the bits for e and g to be the same we would simply continue this process until we get a pair of bits that differentiate the two keys.

![Sample Insert](/imgs/Insert_Sample.png "Fig 2")

## Persistency
To make this structure persistent

## My Code

# Non Persistent Improvements - Getting O(1)

# Working with the Code
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
