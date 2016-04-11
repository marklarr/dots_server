defmodule DotsServer.Repo.Migrations.CreateGameBoard do
  use Ecto.Migration

  def change do
    create table(:game_boards) do
      add :board_lines, :binary
      add :board_fills, :binary

      timestamps
    end

  end
end
