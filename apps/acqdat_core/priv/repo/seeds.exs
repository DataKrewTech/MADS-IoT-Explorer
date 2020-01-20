# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Acqdat.Repo.insert!(%Acqdat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias AcqdatCore.Seed.{User, Device, Sensor}

# The order here is important, don't modify it.

User.seed_user!()
Device.see_device!()
Sensor.seed_sensors()
