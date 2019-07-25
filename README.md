This project is a persistent, functional implementation of the HAMT data structure, currently without sparse arrays or table resizing, that I completed for an independent study at Boston College. The rest of this readme contains a description of the HAMT structure along with some performace testing of my code.

For a more detailed description of HAMT I recommend [Ideal Hash Trees](https://infoscience.epfl.ch/record/64398/files/idealhashtrees.pdf) by Phil Bagwell. The information and technical details of this readme are drawn from that paper. Zach Allaun also has a great talk on [Functional Maps](https://www.infoq.com/presentations/julia-vectors-maps-sets/) on which this project is largely based.

# What is HAMT?

HAMT stands for Hash Array Mapped Trie and the data structure is considered a very performant implementation of a hash tree. The **basic** idea for the structure involves storing key-values in a trie by using bits from the key hash to index a path along said trie. Each node in the trie contains a map that holds both values and pointers to more nodes, allowing simultaneously for the storage of key-value pairs and sub-tries. Fig 1 below shows an example of a trie containing three subtries and a key/value pair.

![Sample Hamt Structure](/imgs/Sample_Hamt_Structure.png "Fig 1")

With good hashing, this structure has an average depth of logN, where N is the number of elements in the structure. Thus, average access time for this basic version of HAMT is on the order of O(logN).

## Insert, Search, and Remove
Insert, Search, and Remove all follow the same general procedure of walking the tree, only differentiating when a terminal node in the trie is found. To walk the tree these procedure must look at consecutive t bits of the hash to determine the next subtrie index to move to. Where t is the power of two that represents the size of the array. So for an array of four t would be 2. A terminal node is determined to be when the alogirithm reaches either a key/value pair or a empty trie bin through this process.

An example of this process with insert is below in Fig 2. Here the objective is to insert a key g into the structure; this key produces a particular hash. Following the bits of that hash (we go by bits of 2 since the array is of size 4) we can trace down the trie. When we reach e (another key/value) we know we've reached a terminal node. To insert we compare the next two bits for both e and g. Finding them to be different we can create a new trie, copy the keys into it, and add that new trie into the previous location of the e key. Were the bits for e and g to be the same we would simply continue this process until we get a pair of bits that differentiate the two keys.

![Sample Insert](/imgs/Insert_Sample.png "Fig 2")

## Functional and Persistent Implementations
To make this structure persistent it's simply a matter of copying all trie nodes on the path to an insert bucket, and returning the modified structure. Notably, this does not involve copying the whole structure, simply the nodes that have been changed. In Fig 3 below the example from insert in Fig 2 is continued to show this notion. If the original HAMT structure is initiated to a variable called x1 after inserting g we get a new structure back, x2. However the only new subtries in x2 are those that were modified to add g to the hash tree. All subties not touched by the insert path remain as buckets for *both* x1 and x2. This means for insert it's only necessary to make and copy an average of log(N) arrays which, for a functional structure, is pretty good.

![Sample Functional](/imgs/Functional_Sample.png "Fig 3")

# My Code
It is the structure described above that my code implements. That is to say, I've implemented a functional, persistent structure that has average access time of O(logN) for all operations and only copies O(logN) structures on insert and remove.

Below, I talk about further improvements on non functional versions of HAMT that further save space and lower the number of accesses.

# Space Improvements and Getting O(1)

## Sparse Arrays
The first improvement that should be mentioned, and one that is applicable to a functional version of HAMT as well, is the use of sparse arrays. This simply means that the tables used in the subtries are only of the size needed, where a integer bitmap is used to indicate which buckets in the table have been taken. For example, if there is a subtrie that has 32 possible buckets but only two elements currently then the array of said subtrie will be an array of length two. To properly index into that array it's necessary to use a count population instruction on the bits of the bitmap. For a better description of using sparse arrays I recommend watching the talk by Zach Allaun mentioned at the beginning of the readme.

## Reusing Subtrie Arrays
These next two improvements are certainly not functional but should still be mentioned. I will also only cover them vaguley since they are not implemented here and instead direct readers to Ideal Hash Trees by Phil Bagwell for a more in depth descriptoin.

This improvement addresses the potential to waste space when inserting (or removing) elements from sparse arrays. When inserting with sparse arrays it becomes necessary to retrieve a new array that is one bucket bigger. Instead of simply returning the old array to the system it is more effecient to store the now unused array in a memory pool and use it prior to requesting more system memory for arrays of that particular size.

## Re-Sizing the Root Hash Table
The impetus for resizing is the same as for Hash Tables, it improves average access time when the load factor becomes high. When resizing it is necessary to migrate elements from old subtries to the new root hash table. This can be done lazily and the major benefit is that average search and insert costs become O(1).
