1. For each node (different windows):
  $ iex --sname xxxxxx algo_node.ex
  iex> import_if_available AlgorithmNode

2. Update @node_names list with the nodes [:"xxxxx",...]

3. In another window:
  $ elixir --sname master -r master.ex -e 'Master.start'

  - "setup" for starting the nodes, then "start", then "end"
