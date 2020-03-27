use Mix.Config

import_config "#{Mix.env()}.exs"

if Mix.target() != :host do
  import_config "target.exs"
else
  import_config "host.exs"
end
