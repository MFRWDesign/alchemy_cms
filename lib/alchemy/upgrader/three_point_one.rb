require 'thor'

class Alchemy::Upgrader::ThreePointOneTask < Thor
  include Thor::Actions

  no_tasks do

    def patch_acts_as_taggable_on_migrations
      sentinel = /def self.up/

      aato_file = Dir.glob('db/migrate/*_acts_as_taggable_on_migration.*.rb').first
      if aato_file
        inject_into_file aato_file,
          "\n  return if table_exists?('tags')\n",
          { after: sentinel, verbose: true }
      end

      aato_file = Dir.glob('db/migrate/*_add_missing_unique_indices.*.rb').first
      if aato_file
        inject_into_file aato_file,
          "\n  index_exists?(:tags, :name)\n",
          { after: sentinel, verbose: true }
      end
    end
  end
end

module Alchemy
  module Upgrader::ThreePointOne
    private

    def upgrade_acts_as_taggable_on_migrations
      Rake::Task["acts_as_taggable_on_engine:install:migrations"].invoke
      Alchemy::Upgrader::ThreePointOneTask.new.patch_acts_as_taggable_on_migrations
    end

    def alchemy_3_1_todos
      notice = <<-NOTE

JSON API moved into '/api' namespace
------------------------------------

The JSON API now lives under /api and not as additional format to default controllers.
Also the serialization changed into more useful payload.

Please upgrade your API calls to use the new /api namespace.


TinyMCE default paste behavior changed
--------------------------------------

Text is now always pasted in as plain text. To change this, the user has to
disable it with the toolbar button, as they had to before to enable it.

If you have a custom TinyMCE configuration you have to enable this by adding

  paste_as_text: true

into you custom TinyMCE configuration.


TinyMCE toolbar config has changed
----------------------------------

The 'toolbar' configuration now takes an array of toolbar rows, instead of
using 'toolbarN' syntax. Please update your TinyMCE configuration.

Visit http://www.tinymce.com/wiki.php/Configuration:toolbar for more information.


ApplicationController patch removed
-----------------------------------

If you have controllers that loads Alchemy content or uses Alchemy helpers in
the views (i.e. `render_navigation` or `render_elements`) you should

  include Alchemy::ControllerActions

in these controllers.


NOTE
      todo notice, 'Alchemy v3.1 changes'
    end
  end
end
