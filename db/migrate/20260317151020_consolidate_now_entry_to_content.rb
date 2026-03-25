class ConsolidateNowEntryToContent < ActiveRecord::Migration[8.1]
  def up
    add_column :now_entries, :content, :text

    NowEntry.reset_column_information
    NowEntry.find_each do |entry|
      parts = [ entry.working_on, entry.reading, entry.learning ]
                .compact.reject(&:empty?)
      entry.update_column(:content, parts.join(" "))
    end

    remove_column :now_entries, :working_on
    remove_column :now_entries, :reading
    remove_column :now_entries, :learning
  end

  def down
    add_column :now_entries, :working_on, :text
    add_column :now_entries, :reading, :string
    add_column :now_entries, :learning, :string

    NowEntry.reset_column_information
    NowEntry.find_each { |e| e.update_column(:working_on, e.content) }

    remove_column :now_entries, :content
  end
end
