defmodule HealthguardApiWeb.UserRegistrationLive do
  use HealthguardApiWeb, :live_view

  alias HealthguardApi.Users
  alias HealthguardApi.Users.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <div class="flex space-x-2">
          <.input field={@form[:first_name]} type="text" label="First name" />
          <.input field={@form[:last_name]} type="text" label="Last name" />
        </div>
        <.input field={@form[:phone_number]} type="text" label="Phone number" />
        <.input field={@form[:badge_number]} type="text" label="Badge number" />
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Users.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_attrs = %{
      email: user_params["email"],
      password: user_params["password"],
      first_name: user_params["first_name"],
      last_name: user_params["last_name"],
      phone_number: user_params["phone_number"]
    }

    medic_attrs = %{
      badge_number: user_params["badge_number"]
    }

    case Users.create_user(user_attrs) do
      {:ok, user} ->
        {:ok, _medic_profile} = Users.create_medic_profile(user, medic_attrs)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
