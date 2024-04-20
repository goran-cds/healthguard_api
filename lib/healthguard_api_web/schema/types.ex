defmodule HealthguardApiWeb.Schema.Types do
  use Absinthe.Schema.Notation

  alias HealthguardApiWeb.Schema

  import_types(Schema.UserType)
  import_types(Schema.SessionType)
end
