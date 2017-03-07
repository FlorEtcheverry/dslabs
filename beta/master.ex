defmodule Master do
  @node_names [:"one@florencia-VirtualBox",:"two@florencia-VirtualBox"]

  def start do
    nodes = Map.new(@node_names,fn x-> {x,0} end)
    run_loop(nodes)
  end

  defp run_loop(nodes) do
    nodes = case IO.gets("Insert next command (setup, start, end):\n") do
      "setup\n" -> setup_nodes(nodes)
      "start\n" -> start_algo(nodes)
      "end\n" -> end_algo(nodes)
    end
    IO.inspect(nodes)
    run_loop(nodes)
  end

  defp setup_nodes(nodes) do
    names = Map.keys(nodes)
    n_collec = Enum.map(names, fn x ->
        {x ,Node.spawn_link(x,AlgorithmNode,:nodeStart,[])}
      end)
    n_nodes = Map.new(n_collec)
    #Enum.map(n_nodes, fn {k,v} -> :global.register_name(k,v) end)
    IO.inspect(n_nodes)
    #IO.inspect(:global.registered_names())
    #Enum.each(:global.registered_names(), fn x -> IO.inspect(:global.whereis_name(x)) end)
    n_nodes
  end

  defp start_algo(nodes) do
    names = Map.keys(nodes)
    Enum.each(Enum.with_index(names), fn {x,i} -> send(Map.get(nodes,x),{:start_algorithm,Node.self(),Map.get(nodes,Enum.at(names,rem(i+1,length(names))))}) end)
    send( Map.get(nodes,List.first(Map.keys(nodes))), {:token,Node.self(),0} )
    nodes
  end

  defp end_algo(nodes) do
    Enum.each(Map.keys(nodes), fn x ->
      send(Map.get(nodes,x),{:end_algorithm,Node.self()})
    end)
    nodes
  end

end
