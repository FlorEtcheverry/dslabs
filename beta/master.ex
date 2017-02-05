defmodule Master do

  @list [:"foo@florencia-VirtualBox", :"dos@florencia-VirtualBox", :"tres@florencia-VirtualBox"]
  def setup do
    Enum.with_index(@list)
    |> Enum.each(fn {x,i} ->
      IO.puts "sending start/1"
        pid = Node.spawn_link(x,AlgorithmNode,:start,[Enum.at(@list,rem(i+1,length(@list)))])
        IO.puts(inspect(pid))
      end)
  end

  def start_algo do
    Enum.each(@list, fn x -> send(x,{:start_algorithm,Node.self()}) end)
    send(:"foo@florencia-VirtualBox",{:token,Node.self()})
  end

  def end_algo do
    Enum.each(@list, fn x ->
      send(x,{:end_algorithm,self()})
    end)
  end
end
