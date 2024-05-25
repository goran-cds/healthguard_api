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

{:ok, user3} = Users.get_user(user3.id)

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

# Pacient Mario Rossi - his default activity is SEDENTARY

{:ok, _updated_pacient_profile} =
  Users.update_pacient_profile(user3.pacient_profile, %{
    activity_type: %{type: :sedentary}
  })

# Pacient Mario Rossi - his doctor (John Doe) adds recommandations for his physical activity

{:ok, _pacient_profile} =
  Users.add_recommandation_to_pacient(user3.pacient_profile.id, %{
    recommandation: "drink at least 3L a day",
    start_date: Date.utc_today(),
    note: "of water, nothing else",
    days_duration: 30
  })

{:ok, _pacient_profile} =
  Users.add_recommandation_to_pacient(user3.pacient_profile.id, %{
    recommandation: "jog each morning",
    start_date: Date.utc_today(),
    note: "from 30 to 60 minutes",
    days_duration: 7
  })

{:ok, _pacient_profile} =
  Users.add_recommandation_to_pacient(user3.pacient_profile.id, %{
    recommandation: "eat at least 3 portions of fruits a day",
    start_date: Date.utc_today(),
    note: "best sources include kiwi, banana, avocados",
    days_duration: 14
  })

# Pacient Mario Rossi - his doctor (John Doe) adds alerts to monitor his bpm and temperature when he is sedentary or running

{:ok, _pacient_profile} =
  Users.add_health_warning_to_pacient(user3.pacient_profile.id, %{
    type: :bpm,
    message: "chill out dude, your heart be jumpin",
    min_value: 50,
    max_value: 80,
    activity_type: %{
      type: :sedentary
    },
    defined_date: Date.utc_today()
  })

{:ok, _pacient_profile} =
  Users.add_health_warning_to_pacient(user3.pacient_profile.id, %{
    type: :temperature,
    message: "din cauza verii",
    min_value: 36,
    max_value: 36.7,
    activity_type: %{
      type: :sedentary
    },
    defined_date: Date.utc_today()
  })

{:ok, _pacient_profile} =
  Users.add_health_warning_to_pacient(user3.pacient_profile.id, %{
    type: :bpm,
    message: "take an aspirin",
    min_value: 70,
    max_value: 150,
    activity_type: %{
      type: :running
    },
    defined_date: Date.utc_today()
  })

{:ok, _pacient_profile} =
  Users.add_health_warning_to_pacient(user3.pacient_profile.id, %{
    type: :temperature,
    message: "ai alergat prea mult frt",
    min_value: 36.1,
    max_value: 37.1,
    activity_type: %{
      type: :running
    },
    defined_date: Date.utc_today()
  })

# Pacient Mario Rossi - device measures sensor data and checks if it will trigger an alarm (he is SEDENTARY)
sensor_data_1 = %{
  bpm: 65,
  temperature: 36.5,
  humidity: 50,
  ecg: [6.1, 8.7, 12.2, 10.2, 9.8, 10, 7.5, 5.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_1)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_1)

sensor_data_2 = %{
  bpm: 70,
  temperature: 36.6,
  humidity: 52,
  ecg: [6.1, 8.7, 12.2, 10.2, 9.8, 10, 7.5, 5.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_2)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_2)

sensor_data_3 = %{
  bpm: 75,
  temperature: 36.8,
  humidity: 58,
  ecg: [8.3, 12.5, 13.2, 15.2, 12.8, 11, 9.5, 8.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_3)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_3)

sensor_data_4 = %{
  bpm: 70,
  temperature: 36.7,
  humidity: 65,
  ecg: [9.5, 10.7, 8.2, 14.2, 10.8, 16.1, 8.5, 10.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_4)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_4)

# At this point he should have a triggered alert for :temperature while :sedentary

# Pacient Mario Rossi - he starts a new activity and is now RUNNING

{:ok, _updated_pacient_profile} =
  Users.update_pacient_profile(user3.pacient_profile, %{
    activity_type: %{type: :running}
  })

# Pacient Mario Rossi - device measures sensor data and checks if it will trigger an alarm (he is RUNNING)

sensor_data_5 = %{
  bpm: 80,
  temperature: 36.5,
  humidity: 50,
  ecg: [6.1, 8.7, 12.2, 10.2, 9.8, 10, 7.5, 5.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_5)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_5)

sensor_data_6 = %{
  bpm: 100,
  temperature: 36.6,
  humidity: 55,
  ecg: [6.1, 8.7, 12.2, 10.2, 9.8, 10, 7.5, 5.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_6)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_6)

sensor_data_7 = %{
  bpm: 120,
  temperature: 36.7,
  humidity: 60,
  ecg: [8.3, 12.5, 13.2, 15.2, 12.8, 11, 9.5, 8.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_7)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_7)

sensor_data_8 = %{
  bpm: 160,
  temperature: 36.8,
  humidity: 60,
  ecg: [9.5, 10.7, 8.2, 14.2, 10.8, 16.1, 8.5, 10.4]
}

{:ok, _updated_pacient_profile} =
  Users.add_sensor_data_to_pacient(user3.id, sensor_data_8)

{:ok, _message} =
  Users.maybe_trigger_alert(user3.pacient_profile, sensor_data_8)

# At this point he should have a triggered alert for :bpm while :running

# Pacient Mario Rossi - goes back to SEDENTARY

{:ok, _updated_pacient_profile} =
  Users.update_pacient_profile(user3.pacient_profile, %{
    activity_type: %{type: :sedentary}
  })
