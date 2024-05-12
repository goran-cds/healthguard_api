defmodule HealthguardApiWeb.Schema.SessionType do
  use Absinthe.Schema.Notation

  object :session_type do
    field :token, :string
    field :user, :user_type
  end

  object :session_delete_type do
    field :token, :string
  end

  input_object :session_input_type do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :session_delete_input_type do
    field :token, non_null(:string)
  end
end
