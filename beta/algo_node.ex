defmodule AlgorithmNode do
  require Logger

  def nodeStart do
    IO.puts("process #{Node.self()} created and running.")
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Received command from #{from} to start algorithm."
        IO.puts "Process #{Node.self()}: Received command from #{from} to start algorithm."
        start_(next)
      {:end_algorithm, from} ->
        IO.puts "Process #{Node.self()}: Received command from #{from} to end algorithm."
        Logger.info "Received command from #{from} to end algorithm."
    end
  end

  def start_(next) do
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Algorithm already started."
        IO.puts "Process #{Node.self()}: Algorithm already started."
      {:token, from, number} ->
        Logger.info "Received token from #{from} and the number is #{number}."
        IO.puts "Process #{Node.self()}: Received token from #{from}."
        :timer.sleep(1000)
        Logger.info "Finished processing."
        IO.puts "Process #{Node.self()}: Finished processing"
        send(next,{:token,Node.self(),number+1})
        Logger.info "Sent token to next."
        IO.puts "Process #{Node.self()}: Sent token to next."
        start_(next)
      {:end_algorithm, from} ->
        IO.puts "Process #{Node.self()}: Received command from #{from} to end algorithm."
        Logger.info "Received command from #{from} to end algorithm."
    end
  end

end
