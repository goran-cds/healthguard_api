defmodule HealthguardApiWeb.TestUsers do
  use HealthguardApiWeb, :live_view

  alias HealthguardApi.Users

  def mount(_, _, socket) do
    {:ok, users} = Users.get_all_users()
    {:ok, socket |> assign(users: users)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-start space-y-4">
      <div
        :for={user <- @users}
        class="flex flex-col space-y-2 p-2 border-2 border-gray-500 rounded-lg w-full"
      >
        <h1 class="text-xl font-bold px-2">DETAILS</h1>
        <p>Email: <%= user.email %></p>
        <p>First name: <%= user.first_name %></p>
        <p>Last name: <%= user.last_name %></p>
        <p>Phone number: <%= user.phone_number %></p>
        <p :if={user.medic_profile}>Medic badge number: <%= user.medic_profile.badge_number %></p>
        <p :if={user.pacient_profile}>CNP: <%= user.pacient_profile.cnp %></p>
        <p :if={user.pacient_profile}>Age: <%= user.pacient_profile.age %></p>
        <p :if={user.pacient_profile}>Profession: <%= user.pacient_profile.profession %></p>
        <p :if={user.pacient_profile}>Work place: <%= user.pacient_profile.work_place %></p>
        <h1 class="text-xl font-bold px-2">CURRENT ACTIVITY</h1>
        <div :if={not is_nil(user.pacient_profile) and not is_nil(user.pacient_profile.activity_type)}>
          <div class="p-2 flex flex-col space-y-1">
            <p>Current activity: <%= user.pacient_profile.activity_type.type %></p>
          </div>
        </div>
        <h1 class="text-xl font-bold px-2">SENSOR DATA</h1>
        <div :if={user.pacient_profile}>
          <div
            :for={sensor_data <- user.pacient_profile.sensor_data}
            class="p-2 flex flex-col space-y-1"
          >
            <p>Type: <%= sensor_data.type %></p>
            <p>Value:</p>
            <div class="flex space-x-4">
              <p :for={val <- sensor_data.value}><%= val %></p>
            </div>
            <p>Date: <%= sensor_data.date %></p>
          </div>
        </div>
        <h1 class="text-xl font-bold px-2">RECOMMANDATIONS</h1>
        <div :if={user.pacient_profile}>
          <div
            :for={recommandation <- user.pacient_profile.recommandations}
            class="p-2 flex flex-col space-y-1"
          >
            <p>Recommandation: <%= recommandation.recommandation %></p>
            <p>Start date: <%= recommandation.start_date %></p>
            <p>Days duration: <%= recommandation.days_duration %></p>
            <p>Note: <%= recommandation.note %></p>
          </div>
        </div>
        <h1 class="text-xl font-bold px-2">ALERTS</h1>
        <div :if={user.pacient_profile}>
          <div
            :for={alert <- user.pacient_profile.health_warnings}
            class="p-2 flex flex-col space-y-1"
          >
            <p>Message: <%= alert.message %></p>
            <p>Type: <%= alert.type %></p>
            <p>Min value: <%= alert.min_value %></p>
            <p>Max value: <%= alert.max_value %></p>
            <p>Defined at: <%= alert.defined_date %></p>
            <p>Triggered?: <%= alert.triggered %></p>
            <p>Triggered at: <%= alert.triggered_date %></p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
