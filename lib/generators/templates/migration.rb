class CreateActsAsWallMigration < ActiveRecord::Migration
  def self.up
    create_table :walls do |t|
      t.belongs_to :wallable, :polymorphic => true
      t.boolean :private, :default=>false
      t.timestamps
    end

    create_table :events do |t|
      t.string :controller
      t.string :action
      t.string :text
      t.string :subtext
      t.belongs_to :actor, :polymorphic=>true
      t.belongs_to :object, :polymorphic=>true
      t.belongs_to :subobject, :polymorphic=>true
      t.boolean :public, :default=>false
      t.datetime :start_at
      t.timestamps
    end

    create_table :listeners do |t|
      t.belongs_to :creator, :polymorphic=>true
      t.belongs_to :actor, :polymorphic=>true
      t.belongs_to :wall
      t.timestamps
    end

    create_table :announcements do |t|
      t.belongs_to :event
      t.belongs_to :wall
      t.timestamps
    end

    create_table :notifications do |t|
      t.belongs_to :event
      t.belongs_to :notifee, :polymorphic=>true
      t.timestamps
    end
  end

  def self.down
    drop_table :walls
    drop_table :events
    drop_table :listeners
    drop_table :announcements
    drop_table :notifications
  end
end
