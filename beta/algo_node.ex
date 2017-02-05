defmodule AlgorithmNode do
  require Logger

  def start do
    IO.puts "process created and running."
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Received command from #{from} to start algorithm. My next is #{next}."
        IO.puts "started"
        start_(next)
      {:end_algorithm, from} ->
        IO.puts "finish"
        Logger.info "Received command from #{from} to end algorithm."
    end
  end

  def start_(next) do
    IO.puts "process created and running."
    receive do
      {:start_algorithm, from, next} ->
        Logger.info "Algorithm already started."
        IO.puts "Algorithm already started."
      {:token, from} ->
        Logger.info "Received token from #{from}."
        :timer.sleep(1000)
        Logger.info "Finished processing."
        IO.puts "sending token"
        send(next,{:token})
        Logger.info "Sent token to #{next}."
        start_(next)
      {:end_algorithm, from} ->
        IO.puts "finish"
        Logger.info "Received command from #{from} to end algorithm."
    end
  end

end
