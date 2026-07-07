# Pin npm packages by running ./bin/importmap

pin "application"
pin "lexxy", to: "lexxy.js"
pin "lexxy_config", to: "lexxy_config.js"
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.1.300
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.23
pin "@rails/actiontext", to: "@rails--actiontext.js" # @8.1.300
pin "trix" # @2.1.19
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
