Table comments {
  id integer [primary key]
  post_id integer [not null]
  user_id integer [not null]
  text text

  edited_at timestamp
  created_at timestamp

  indexes {
    post_id [type: hash]
    user_id [type: hash]
    created_at [note: 'Help for pagination']
  }
}


