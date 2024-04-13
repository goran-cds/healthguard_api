alias HealthguardApi.Users

{:ok, user1} =
  Users.create_user(%{
    email: "john.doe@gmail.com",
    password: "Parola1234!@#",
    first_name: "John",
    last_name: "Doe",
    phone_number: "1234567890"
  })

{:ok, medic_profile1} =
  Users.create_medic_profile(user1, %{
    badge_number: "11122222"
  })

{:ok, user2} =
  Users.create_user(%{
    email: "giovanni.romano@gmail.com",
    password: "Parola1234!@#",
    first_name: "Giovanni",
    last_name: "Romano",
    phone_number: "1234567890"
  })

{:ok, medic_profile2} =
  Users.create_medic_profile(user2, %{
    badge_number: "22211111"
  })

{:ok, user3} =
  Users.create_user(%{
    email: "mario.rossi@gmail.com",
    password: "Parola1234!@#",
    first_name: "Mario",
    last_name: "Rossi",
    phone_number: "1234567890"
  })

{:ok, pacient_profile1} =
  Users.create_pacient_profile(user3, %{
    cnp: "1234567890123",
    age: 24
  })

{:ok, user4} =
  Users.create_user(%{
    email: "eli.green@gmail.com",
    password: "Parola1234!@#",
    first_name: "Elizabeth",
    last_name: "Green",
    phone_number: "1234567890"
  })

{:ok, pacient_profile2} =
  Users.create_pacient_profile(user4, %{
    cnp: "9785437658432",
    age: 21
  })

{:ok, user5} =
  Users.create_user(%{
    email: "rebecca.smith@gmail.com",
    password: "Parola1234!@#",
    first_name: "Rebecca",
    last_name: "Smith",
    phone_number: "1234567890"
  })

{:ok, pacient_profile3} =
  Users.create_pacient_profile(user5, %{
    cnp: "3425678345213",
    age: 30
  })

{:ok, _pacient_profile} = Users.associate_pacient_with_medic(pacient_profile1.id, medic_profile1)

{:ok, _pacient_profile} = Users.associate_pacient_with_medic(pacient_profile2.id, medic_profile1)

{:ok, _pacient_profile} = Users.associate_pacient_with_medic(pacient_profile3.id, medic_profile2)
