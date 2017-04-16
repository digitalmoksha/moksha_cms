# Migration for upgrading PaperTrail from V3 to V4
#------------------------------------------------------------------------------
class UpdatePapertrailV4 < ActiveRecord::Migration[4.2]
  # Class names of MySQL adapters.
  # - `MysqlAdapter` - Used by gems: `mysql`, `activerecord-jdbcmysql-adapter`.
  # - `Mysql2Adapter` - Used by `mysql2` gem.
  MYSQL_ADAPTERS = [
    "ActiveRecord::ConnectionAdapters::MysqlAdapter",
    "ActiveRecord::ConnectionAdapters::Mysql2Adapter"
  ]

  # The largest text column available in all supported RDBMS is
  # 1024^3 - 1 bytes, roughly one gibibyte.  We specify a size
  # so that MySQL will use `longtext` instead of `text`.  Otherwise,
  # when serializing very large objects, `text` might not be big enough.
  TEXT_BYTES = 1_073_741_823

  def up
    change_column :versions, :created_at,     :datetime, precision: 6
    change_column :versions, :object,         :text, limit: TEXT_BYTES
    change_column :versions, :object_changes, :text, limit: TEXT_BYTES
    add_column    :versions, :transaction_id, :integer
    add_index     :versions, [:transaction_id]

    create_table :version_associations, versions_table_options do |t|
      t.integer  :version_id
      t.string   :foreign_key_name, :null => false, :limit => 191
      t.integer  :foreign_key_id
    end
    add_index :version_associations, [:version_id]
    add_index :version_associations,
      [:foreign_key_name, :foreign_key_id],
      :name => 'index_version_associations_on_foreign_key'
  end

  def down
    change_column :versions, :created_at,     :datetime
    change_column :versions, :object,         :mediumtext
    change_column :versions, :object_changes, :mediumtext
    remove_index  :versions, [:transaction_id]
    remove_column :versions, :transaction_id

    remove_index :version_associations, [:version_id]
    remove_index :version_associations,
      :name => 'index_version_associations_on_foreign_key'
    drop_table :version_associations
  end

  private

  # Even modern versions of MySQL still use `latin1` as the default character
  # encoding. Many users are not aware of this, and run into trouble when they
  # try to use PaperTrail in apps that otherwise tend to use UTF-8. Postgres, by
  # comparison, uses UTF-8 except in the unusual case where the OS is configured
  # with a custom locale.
  #
  # - https://dev.mysql.com/doc/refman/5.7/en/charset-applications.html
  # - http://www.postgresql.org/docs/9.4/static/multibyte.html
  #
  # Furthermore, MySQL's original implementation of UTF-8 was flawed, and had
  # to be fixed later by introducing a new charset, `utf8mb4`.
  #
  # - https://mathiasbynens.be/notes/mysql-utf8mb4
  # - https://dev.mysql.com/doc/refman/5.5/en/charset-unicode-utf8mb4.html
  #
  def versions_table_options
    if MYSQL_ADAPTERS.include?(connection.class.name)
      { options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' }
    else
      {}
    end
  end
end
