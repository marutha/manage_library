defmodule ManageLibrary.Repo do
  use Ecto.Repo,
    otp_app: :manage_library,
    adapter: Ecto.Adapters.Postgres
end
