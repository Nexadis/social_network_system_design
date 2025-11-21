Table user_posts {
  id integer [unique]
  user_id integer [not null]
  place_id integer [not null]
  description text
  
  edited_at timestamp
  created_at timestamp

  indexes {
    created_at
    user_id [type: hash]
  }
}


