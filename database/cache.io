// ---------------------------- Cache --------------------------

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

Table user_feeds {
  id integer [unique]
  user_id integer [not null]
  place_id integer [not null]
  description text
  
  edited_at timestamp
  created_at timestamp

  indexes {
    created_at
  }
}

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

Table reactions{
  user_id integer [not null]
  post_id integer [not null]
  
  reaction integer

  indexes {
    (user_id,post_id)
  }
}
