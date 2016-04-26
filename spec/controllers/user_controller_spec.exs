defmodule DotsServer.UserControllerSpec do
  use ESpec
  use DotsServer.ConnCase

  alias DotsServer.User

  import DotsServer.Factory

  let :valid_attrs, do: %{email: "some content", password: "some content", handle: "some content"}
  let :invalid_attrs, do: %{}

  let :connection do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    conn
  end

  describe "index" do
    it "lists all entries" do
      user = create(:user)
      conn = get connection, user_path(conn, :index)
      Poison.decode!(Poison.encode!(user)) in json_response(conn, 200)["data"] |> should(eq true)
    end
  end

  describe "show" do
    it "shows chosen resource" do
      user = create(:user)
      conn = get connection, user_path(conn, :show, user)
      json_response(conn, 200)["data"] |> should(eq %{
        "id" => user.id,
        "email" => user.email,
        "handle" => user.handle
      })
    end

    it "does not show resource and instead throw error when id is nonexistent" do
      assert_error_sent 404, fn ->
        get connection, user_path(connection, :show, -1)
      end
    end
  end

  describe "create" do
    it "creates and renders resource when data is valid" do
      conn = post connection, user_path(connection, :create), user: valid_attrs
      id = json_response(conn, 201)["data"]["id"]
      Repo.get(User, id) |> should_not(be_nil)
    end

    it "does not create resource and renders errors when data is invalid" do
      conn = post connection, user_path(connection, :create), user: invalid_attrs
      json_response(conn, 422)["errors"] |> should_not(eq %{})
    end

    it "does not render password or encrypted_password" do
      conn = post connection, user_path(connection, :create), user: valid_attrs
      response = json_response(conn, 201)
      response["data"]["password"] |> should(be_nil)
      response["data"]["encrypted_password"] |> should(be_nil)
    end

    it "encrypts the password before storing" do
      conn = post connection, user_path(connection, :create), user: valid_attrs
      id = json_response(conn, 201)["data"]["id"]
      DotsServer.Repo.get(User, id).encrypted_password |> should_not(be_nil)
      DotsServer.Repo.get(User, id).encrypted_password |> should_not(eq valid_attrs[:password])
    end

    it "cannot set the encrypted password via params" do
      valid_attrs = valid_attrs |> Map.put("encrypted_password", "abcdefg")
      conn = post connection, user_path(connection, :create), user: valid_attrs
      id = json_response(conn, 201)["data"]["id"]
      DotsServer.Repo.get(User, id).encrypted_password |> should_not(eq "abcdefg")
    end
  end

  describe "edit" do
    it "updates and renders chosen resource when data is valid" do
      user = Repo.insert! %User{}
      conn = put connection, user_path(connection, :update, user), user: valid_attrs
      id = json_response(conn, 200)["data"]["id"]
      Repo.get(User, id).handle |> should(eq valid_attrs[:handle])
    end

    it "does not update chosen resource and renders errors when data is invalid" do
      user = Repo.insert! %User{}
      conn = put connection, user_path(connection, :update, user), user: invalid_attrs
      json_response(conn, 422)["errors"] |> should_not(eq %{})
    end
  end

  describe "delete" do
    it "deletes chosen resource" do
      user = Repo.insert! %User{}
      conn = delete connection, user_path(connection, :delete, user)
      response(conn, 204) |> should_not(be_nil)
      Repo.get(User, user.id) |> should(be_nil)
    end
  end
end
