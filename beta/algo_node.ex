defmodule AlgorithmNode do
  require Logger

  def nodeStart do
    IO.puts("process #{Node.self()} created and running.")
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Process #{Node.self()}: Received command from #{from} to start algorithm."
        start_(next)
      {:end_algorithm, from} ->
        Logger.info "Process #{Node.self()}: Received command from #{from} to end algorithm."
    end
  end

  def start_(next) do
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Process #{Node.self()}: Algorithm already started."
      {:token, from, number} ->
        Logger.info "Process #{Node.self()}: Received token from #{from} and the number is #{number}."
        file = File.open!("shared.txt", [:append])
        IO.binwrite(file, "Process #{Node.self()}: Writing #{number}.\n")
        :ok = File.close(file)
        :timer.sleep(5000)
        Logger.info "Process #{Node.self()}: Finished processing."
        send(next,{:token,Node.self(),number+1})
        Logger.info "Process #{Node.self()}: Sent token to next."
        start_(next)
      {:end_algorithm, from} ->
        Logger.info "Process #{Node.self()}: Received command from #{from} to end algorithm."
    end
  end

end
