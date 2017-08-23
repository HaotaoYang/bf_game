defmodule RecordDef do

  require Record

  defstruct [
    record_name: nil,
    attributes: [],
    type: :set,
    load_all: false
  ]

  Record.defrecord :user_chip, [:user_id, :chip]
  Record.defrecord :auto_increment_id_tab, [:table_type, :current_id]

end
