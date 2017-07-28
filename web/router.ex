defmodule BfGame.Router do
  use BfGame.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BfGame do
    pipe_through :api
  end
end
