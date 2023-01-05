defmodule PmetricsWeb.AlquimiaLive.FormComponent do
  use PmetricsWeb, :live_component

  alias Pmetrics.Alquimia

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Please upload your model and data files.</:subtitle>
      </.header>

      <.simple_form
        for={@changeset}
        id="run-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.label>Model</.label>
        <.live_file_input upload={@uploads.model} />
        <.label>Data</.label>
        <.live_file_input upload={@uploads.data} />
        <:actions>
          <.button phx-disable-with="Saving...">Queue Execution</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{run: run} = assigns, socket) do
    changeset = Alquimia.Schemas.Run.change_run(run)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:model, accept: ~w(.txt), max_entries: 1)
     |> allow_upload(:data, accept: ~w(.csv), max_entries: 1)}
  end

  # @impl true
  # def handle_event("validate", %{"run" => run_params}, socket) do
  #   changeset =
  #     socket.assigns.run
  #     |> Alquimia.Schemas.Run.change_run(run_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign(socket, :changeset, changeset)}
  # end
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do

    [model_txt]=consume_uploaded_entries(socket, :model, fn %{path: path}, _entry ->
      File.read(path)
    end)
    [data_txt]=consume_uploaded_entries(socket, :data, fn %{path: path}, _entry ->
      File.read(path)
    end)
    run_params = %{"model_txt" => model_txt, "data_txt" => data_txt} |> IO.inspect
    GenServer.call(Alquimia.pid(), {:register_execution, run_params})
    {:noreply,
     socket
     |> put_flash(:info, "Execution queued successfully")
     |> push_navigate(to: socket.assigns.navigate)}
  end
end
