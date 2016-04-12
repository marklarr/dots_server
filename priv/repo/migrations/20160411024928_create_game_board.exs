defmodule DotsServer.Repo.Migrations.CreateGameBoard do
  use Ecto.Migration

  def change do
    create table(:game_boards) do
      add :board_lines_data, :binary
      add :board_fills_data, :binary

      timestamps
    end

  end
end
