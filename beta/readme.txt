1. For each node (different windows):
  $ iex --name xxx@ip --cookie cookie algo_node.ex

1.1 If needed:
  iex> import_if_available AlgorithmNode

2. Update @node_names list with the nodes [:"xxxxx",...]

3. In another window:
  $ iex --name master@ip --cookie cookie -r master.ex -e 'Master.start'

  - "setup" for starting the nodes, then "start", then "end"
