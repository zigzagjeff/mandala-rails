# The Litestream replication sidecar (Kamal accessory litestream/litestream,
# configured in config/litestream.yml) creates these bookkeeping tables inside
# the SQLite database at runtime. They are replication internals, not
# application schema, so keep them out of db/schema.rb — otherwise every
# db:schema:dump against a replicated database re-pulls them and misleads the
# next migration author.
ActiveRecord::SchemaDumper.ignore_tables += %w[ _litestream_lock _litestream_seq ]
