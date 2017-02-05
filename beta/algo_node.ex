defmodule AlgorithmNode do
  require Logger

  def start(next) do
    receive do
      {:start_algorithm, from} ->
        Logger.info "Received command from #{from} to start algorithm. My next is #{next}."
        IO.puts "started"
        start(next)
      {:token, from} ->
        Logger.info "Received token from #{from}."
        :timer.sleep(1000)
        Logger.info "Finished processing."
        IO.puts "sending token"
        send(next,{:token})
        Logger.info "Sent token to #{next}."
        start(next)
      {:end_algorithm, from} ->
        IO.puts "finish"
        Logger.info "Received command from #{from} to end algorithm."
    end
  end
end
