class CreateActsAsWallMigration < ActiveRecord::Migration
  def self.up
    create_table :walls do |t|
      t.belongs_to :wallable, :polymorphic => true
      t.boolean :private, :default=>false
      t.timestamps
    end
    add_index :walls, [:wallable_id, :wallable_type]

    create_table :feeds do |t|
      t.belongs_to :actor, :polymorphic => true
      t.timestamps
    end
    add_index :feeds, [:actor_id, :actor_type]

    create_table :trays do |t|
      t.belongs_to :actor, :polymorphic => true
      t.timestamps
    end
    add_index :trays, [:actor_id, :actor_type]

    create_table :events do |t|
      t.string :controller
      t.string :action
      t.string :creator_type
      t.belongs_to :actor, :polymorphic=>true
      t.belongs_to :object, :polymorphic=>true
      t.belongs_to :subobject, :polymorphic=>true
      t.boolean :public, :default=>false
      t.datetime :start_at
      t.timestamps
    end
    add_index :events, [:actor_id, :actor_type]
    add_index :events, [:object_id, :object_type]
    add_index :events, [:subobject_id, :subobject_type]

    create_table :listeners do |t|
      t.belongs_to :creator, :polymorphic=>true
      t.belongs_to :feed
      t.belongs_to :wall
      t.timestamps
    end
    add_index :listeners, [:creator_id, :creator_type]
    add_index :listeners, :feed_id
    add_index :listeners, :wall_id

    create_table :announcements do |t|
      t.belongs_to :event
      t.belongs_to :wall
      t.timestamps
    end
    add_index :announcements, :event_id
    add_index :announcements, :wall_id

    create_table :notifications do |t|
      t.belongs_to :event
      t.belongs_to :tray
      t.timestamps
    end
    add_index :notifications, :event_id
    add_index :notifications, :tray_id
  end

  def self.down
    drop_table :walls
    drop_table :feeds
    drop_table :trays
    drop_table :events
    drop_table :listeners
    drop_table :announcements
    drop_table :notifications
  end
end
