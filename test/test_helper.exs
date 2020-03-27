Application.load(:rotary_encoder)

for app <- Application.spec(:rotary_encoder, :applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
