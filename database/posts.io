Table posts{
  id integer [primary key]
  user_id integer [not null]
  place_id integer [not null]
  description text
  
  edited_at timestamp
  created_at timestamp

  indexes {
    user_id [type: hash]
    place_id [type: hash]
    created_at [note: 'Help for pagination']
  }
}
