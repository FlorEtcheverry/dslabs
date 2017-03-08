defmodule Consensus do
  @moduledoc """
  # Bully Algorithm
  Based on Mateus Craveiro's implementation. https://github.com/mccraveiro
  Run algorithm with `iex --sname <id> Consensus.ex`
  Then call `Consensus.start` to start a single node
  or `Consensus.connect <id>` to start and connect a node
  """

  defp init do
    # Start leader as itself
    # init_leader Node.self()
    Agent.start_link(fn -> Node.self() end, name: :leader)
    # Get nodes status messages
    :global_group.monitor_nodes(true)
    :global.register_name Node.self(), self()
  end

  @doc """
  Call this to start a node by itself
  """
  def start do
    init()
    loop()
  end

  @doc """
  Call this to start a node and connect to an existing node
  """
  def connect(id, hostname \\ host()) do
    init()
    # Connect to other nodes
    Node.connect(String.to_atom(to_string(id) <> "@" <> hostname))
    :global.sync # Synchronizes the global name server with all nodes known to this node.
    loop()
  end

  defp currentLeader do
    Agent.get(:leader, fn leader -> leader end)
    # Agent.get(:leader, &(&1))
  end

  defp updateLeader(new_leader) do
    Agent.update(:leader, fn(_) -> new_leader end)
  end

  defp host do
    # Get localhost name
    :inet.gethostname()
    |> elem(1)
    |> to_string
  end

  defp startElection do
    IO.puts "Starting election."

    if higherNodes() do
      IO.puts "Lost election."
      # wait 5s if no coordinator, start election again
      receive do
        {:coordinator, node} -> updateLeader(node)
      after
        5_000 -> startElection()
      end
    else
      IO.puts "Won election."
      updateLeader Node.self()
      broadcastVictory()
    end
  end

  defp higherNodes do
    Node.list()
    # Get all nodes higher than itself
    |> Enum.filter(fn(node) -> node > Node.self() end)
    # Test if any is alive
    |> Enum.any?(
      fn(node) ->
        :global.send node, {:election, Node.self()}
        receive do
          {:alive, remote} when remote == node ->
            IO.inspect(node)
            true
        after
          5_000 -> false
        end
      end
    )
  end

  defp broadcastVictory do
    # Send a coordinator message for each node
    Enum.each(Node.list, fn(node) ->
      :global.send node, {:coordinator, Node.self}
    end)
  end

  defp loop do
    receive do
      {:nodeup, node} ->
        IO.puts "Node connected: " <> to_string(node)
        :global.sync
        if node > currentLeader() do startElection() end
      {:nodedown, node} ->
        IO.puts "Node disconnected: " <> to_string(node)
        if node == currentLeader() do startElection() end
      {:election, node} ->
        :global.send node, {:alive, Node.self()}
        if Node.self() > node do startElection() end
      {:coordinator, node} ->
        if Node.self() > node do
          startElection()
        else
          updateLeader node
        end
    after
      1500 -> IO.puts("Current leader: " <> to_string(currentLeader()))
    end

    loop()
  end
end
