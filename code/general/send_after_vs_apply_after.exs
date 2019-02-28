defmodule Apply.After do
  def call_me(arg) do
    send(self(), {:sent, arg})
  end
end

defmodule SendVsApply do
  @arg {:from, :me}
  @time 1

  def benchmark do
    Benchee.run(
      %{
        "send_after/2" => fn ->
          Process.send_after(self(), @arg, @time)
        end,
        "apply_after/4" => fn ->
          :timer.apply_after(@time, Apply.After, :call_me, [@arg])
        end
      },
      time: 10,
      memory_time: 1,
      print: [fast_warning: false]
    )
  end
end

SendVsApply.benchmark()
