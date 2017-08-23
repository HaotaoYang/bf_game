defmodule MnesiaApi do

  def table_list() do
    [
      %RecordDef{
        record_name: :user_chip,
        attributes: [:user_id, :chip]
      },
      %RecordDef{
        record_name: :auto_increment_id_tab,
        attributes: [:table_type, :current_id],
        load_all: true
      }
    ]
  end

  def insert(table_name, data) do
    MnesiaTab.insert_or_save(table_name, data)
  end

  def save(table_name, data) do
    MnesiaTab.insert_or_save(table_name, data)
  end

  def delete(table_name, key) do
    MnesiaTab.delete(table_name, key)
  end

  def offline_save(table_name, data) do
    MnesiaTab.offline_save(table_name, data)
  end

  def lookup(table_name, key) do
    MnesiaTab.lookup(table_name, key)
  end

  def get_auto_increment_id(table_type) do
    MnesiaTab.get_auto_increment_id(table_type)
  end

end
