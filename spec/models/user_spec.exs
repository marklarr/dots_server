defmodule DotsServer.UserSpec do
  use ESpec

  alias DotsServer.User

  import DotsServer.Factory

  describe "#changeset" do
    context "valid attributes" do
      let :valid_attrs, do: %{email: "some content", encrypted_password: "some content", handle: "some content"}

      it "makes a valid changeset" do
        changeset = User.changeset(%User{}, valid_attrs)
        changeset.valid? |> should(be_true)
      end
    end
  end

  context "changeset with invalid attributes" do
    let :invalid_attrs, do: %{}

    it "makes an invalid changeset" do
      changeset = User.changeset(%User{}, invalid_attrs)
      changeset.valid? |> should(be_false)
    end
  end

  context "encoding with Poison" do
    it "encodes the id, email, and handle" do
      user = create(:user)
      Poison.decode!(Poison.encode!(user)) |> should(eq %{
        "id" => user.id,
        "email" => user.email,
        "handle" => user.handle
      })
    end
  end
end
