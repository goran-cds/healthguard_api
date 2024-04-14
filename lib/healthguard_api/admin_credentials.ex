defmodule HealthguardApi.AdminCredentials do
  @spec get_credentials() :: %{
          admin_username: String.t(),
          admin_password: String.t()
        }
  def get_credentials() do
    config = Application.fetch_env!(:healthguard_api, __MODULE__)

    %{
      admin_username: Keyword.fetch!(config, :admin_username),
      admin_password: Keyword.fetch!(config, :admin_password)
    }
  end
end
