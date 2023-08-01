defmodule ManageLibrary.LibraryTest do
  use ManageLibrary.DataCase

  alias ManageLibrary.Library

  import ManageLibrary.LibraryFixtures
  alias ManageLibrary.Library.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Library.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Library.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Library.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Library.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Library.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Library.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Library.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Library.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Library.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Library.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Library.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Library.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Library.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Library.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Library.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Library.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Library.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Library.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Library.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()
      password = valid_user_password()

      {:error, changeset} = Library.apply_user_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Library.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Library.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Library.get_user!(user.id).email != email
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Library.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Library.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Library.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Library.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Library.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Library.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Library.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Library.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Library.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Library.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Library.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Library.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Library.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Library.generate_user_session_token(user)

      {:ok, _} =
        Library.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Library.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Library.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Library.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Library.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Library.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Library.generate_user_session_token(user)
      assert Library.delete_user_session_token(token) == :ok
      refute Library.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Library.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Library.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Library.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Library.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Library.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Library.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Library.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Library.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Library.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Library.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Library.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Library.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Library.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Library.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Library.generate_user_session_token(user)
      {:ok, _} = Library.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "books" do
    alias ManageLibrary.Library.Book

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{nil, description: nil, dop: nil, isbn: nil, name: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Library.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Library.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{description: "some description", dop: ~D[2023-05-06], isbn: 42, name: "some name"}

      assert {:ok, %Book{} = book} = Library.create_book(valid_attrs)
      assert book.description == "some description"
      assert book.dop == ~D[2023-05-06]
      assert book.isbn == 42
      assert book.name == "some name"
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{description: "some updated description", dop: ~D[2023-05-07], isbn: 43, name: "some updated name"}

      assert {:ok, %Book{} = book} = Library.update_book(book, update_attrs)
      assert book.description == "some updated description"
      assert book.dop == ~D[2023-05-07]
      assert book.isbn == 43
      assert book.name == "some updated name"
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_book(book, @invalid_attrs)
      assert book == Library.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Library.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Library.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Library.change_book(book)
    end
  end

  describe "authors" do
    alias ManageLibrary.Library.Author

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{name: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Library.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Library.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Author{} = author} = Library.create_author(valid_attrs)
      assert author.name == "some name"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Author{} = author} = Library.update_author(author, update_attrs)
      assert author.name == "some updated name"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_author(author, @invalid_attrs)
      assert author == Library.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Library.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Library.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Library.change_author(author)
    end
  end

  describe "isbns" do
    alias ManageLibrary.Library.ISBN

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{isbn: nil}

    test "list_isbns/0 returns all isbns" do
      isbn = isbn_fixture()
      assert Library.list_isbns() == [isbn]
    end

    test "get_isbn!/1 returns the isbn with given id" do
      isbn = isbn_fixture()
      assert Library.get_isbn!(isbn.id) == isbn
    end

    test "create_isbn/1 with valid data creates a isbn" do
      valid_attrs = %{isbn: "some isbn"}

      assert {:ok, %ISBN{} = isbn} = Library.create_isbn(valid_attrs)
      assert isbn.isbn == "some isbn"
    end

    test "create_isbn/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_isbn(@invalid_attrs)
    end

    test "update_isbn/2 with valid data updates the isbn" do
      isbn = isbn_fixture()
      update_attrs = %{isbn: "some updated isbn"}

      assert {:ok, %ISBN{} = isbn} = Library.update_isbn(isbn, update_attrs)
      assert isbn.isbn == "some updated isbn"
    end

    test "update_isbn/2 with invalid data returns error changeset" do
      isbn = isbn_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_isbn(isbn, @invalid_attrs)
      assert isbn == Library.get_isbn!(isbn.id)
    end

    test "delete_isbn/1 deletes the isbn" do
      isbn = isbn_fixture()
      assert {:ok, %ISBN{}} = Library.delete_isbn(isbn)
      assert_raise Ecto.NoResultsError, fn -> Library.get_isbn!(isbn.id) end
    end

    test "change_isbn/1 returns a isbn changeset" do
      isbn = isbn_fixture()
      assert %Ecto.Changeset{} = Library.change_isbn(isbn)
    end
  end

  describe "tags" do
    alias ManageLibrary.Library.Tag

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{title: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Library.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Library.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Tag{} = tag} = Library.create_tag(valid_attrs)
      assert tag.title == "some title"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Tag{} = tag} = Library.update_tag(tag, update_attrs)
      assert tag.title == "some updated title"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_tag(tag, @invalid_attrs)
      assert tag == Library.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Library.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Library.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Library.change_tag(tag)
    end
  end

  describe "book_authors" do
    alias ManageLibrary.Library.BookAuthor

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{author_id: nil, book_id: nil}

    test "list_book_authors/0 returns all book_authors" do
      book_author = book_author_fixture()
      assert Library.list_book_authors() == [book_author]
    end

    test "get_book_author!/1 returns the book_author with given id" do
      book_author = book_author_fixture()
      assert Library.get_book_author!(book_author.id) == book_author
    end

    test "create_book_author/1 with valid data creates a book_author" do
      valid_attrs = %{author_id: 42, book_id: 42}

      assert {:ok, %BookAuthor{} = book_author} = Library.create_book_author(valid_attrs)
      assert book_author.author_id == 42
      assert book_author.book_id == 42
    end

    test "create_book_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_book_author(@invalid_attrs)
    end

    test "update_book_author/2 with valid data updates the book_author" do
      book_author = book_author_fixture()
      update_attrs = %{author_id: 43, book_id: 43}

      assert {:ok, %BookAuthor{} = book_author} = Library.update_book_author(book_author, update_attrs)
      assert book_author.author_id == 43
      assert book_author.book_id == 43
    end

    test "update_book_author/2 with invalid data returns error changeset" do
      book_author = book_author_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_book_author(book_author, @invalid_attrs)
      assert book_author == Library.get_book_author!(book_author.id)
    end

    test "delete_book_author/1 deletes the book_author" do
      book_author = book_author_fixture()
      assert {:ok, %BookAuthor{}} = Library.delete_book_author(book_author)
      assert_raise Ecto.NoResultsError, fn -> Library.get_book_author!(book_author.id) end
    end

    test "change_book_author/1 returns a book_author changeset" do
      book_author = book_author_fixture()
      assert %Ecto.Changeset{} = Library.change_book_author(book_author)
    end
  end

  describe "book_tags" do
    alias ManageLibrary.Library.BookTag

    import ManageLibrary.LibraryFixtures

    @invalid_attrs %{book_id: nil, tag_id: nil}

    test "list_book_tags/0 returns all book_tags" do
      book_tag = book_tag_fixture()
      assert Library.list_book_tags() == [book_tag]
    end

    test "get_book_tag!/1 returns the book_tag with given id" do
      book_tag = book_tag_fixture()
      assert Library.get_book_tag!(book_tag.id) == book_tag
    end

    test "create_book_tag/1 with valid data creates a book_tag" do
      valid_attrs = %{book_id: 42, tag_id: 42}

      assert {:ok, %BookTag{} = book_tag} = Library.create_book_tag(valid_attrs)
      assert book_tag.book_id == 42
      assert book_tag.tag_id == 42
    end

    test "create_book_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_book_tag(@invalid_attrs)
    end

    test "update_book_tag/2 with valid data updates the book_tag" do
      book_tag = book_tag_fixture()
      update_attrs = %{book_id: 43, tag_id: 43}

      assert {:ok, %BookTag{} = book_tag} = Library.update_book_tag(book_tag, update_attrs)
      assert book_tag.book_id == 43
      assert book_tag.tag_id == 43
    end

    test "update_book_tag/2 with invalid data returns error changeset" do
      book_tag = book_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_book_tag(book_tag, @invalid_attrs)
      assert book_tag == Library.get_book_tag!(book_tag.id)
    end

    test "delete_book_tag/1 deletes the book_tag" do
      book_tag = book_tag_fixture()
      assert {:ok, %BookTag{}} = Library.delete_book_tag(book_tag)
      assert_raise Ecto.NoResultsError, fn -> Library.get_book_tag!(book_tag.id) end
    end

    test "change_book_tag/1 returns a book_tag changeset" do
      book_tag = book_tag_fixture()
      assert %Ecto.Changeset{} = Library.change_book_tag(book_tag)
    end
  end
end
