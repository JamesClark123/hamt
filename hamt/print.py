import os
import sys
from graphviz import Digraph, nohtml

os.chdir(os.getcwd())

file = open("print.txt","r")

str = file.read()
nodesNedges = str.split(".")
nodes = (nodesNedges[0]).split("*")
nodes = list(filter(None, nodes))
edges = (nodesNedges[1]).split("*")
edges = list(filter(None, edges))

g = Digraph('g', filename='btree.gv', node_attr={'shape': 'record', 'height': '.1'})

for i in nodes:
    st = i.split(",")
    g.node(st[0], nohtml(st[1]))

for i in edges:
    st = i.split(",")
    g.edge(st[0], st[1])


if len(sys.argv) > 1:
    name = sys.argv[1]
    g.view(name)
else:
    g.view("temp")
