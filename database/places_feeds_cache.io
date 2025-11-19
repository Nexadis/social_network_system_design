Table places_feeds {
  id integer [unique]
  user_id integer [not null]
  place_id integer [not null]
  description text
  
  edited_at timestamp
  created_at timestamp

  indexes {
    created_at
    place_id [type: hash]
  }
}
