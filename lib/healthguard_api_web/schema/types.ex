defmodule HealthguardApiWeb.Schema.Types do
  use Absinthe.Schema.Notation

  alias HealthguardApiWeb.Schema

  import_types(Schema.UserType)
end
