defmodule PmetricsWeb.AlquimiaJSON do

  def run(%{run: run}=params) do
    IO.inspect(params)
    run
  end

  def status(%{status: status}) do
    status
  end

  def outdata(%{outdata_txt: outdata_txt}) do
    %{outdata: outdata_txt}
  end
end
