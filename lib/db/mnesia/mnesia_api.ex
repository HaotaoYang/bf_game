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

  ## 插入
  def insert(table_name, data) do
    MnesiaTab.insert_or_save(table_name, data)
  end

  ## 保存
  def save(table_name, data) do
    MnesiaTab.insert_or_save(table_name, data)
  end

  ## 删除
  def delete(table_name, key) do
    MnesiaTab.delete(table_name, key)
  end

  ## 玩家离线保存，保存到db并删除缓存
  def offline_save(table_name, data) do
    MnesiaTab.offline_save(table_name, data)
  end

  ## 查找数据并加载到缓存
  def load(table_name, key) do
    MnesiaTab.load(table_name, key)
  end

  ## 查找数据不加载到缓存
  def lookup(table_name, key) do
    MnesiaTab.lookup(table_name, key)
  end

  ## 获取自增id
  def get_auto_increment_id(table_type) do
    MnesiaTab.get_auto_increment_id(table_type)
  end

end
