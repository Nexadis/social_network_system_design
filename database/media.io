Table post_media {
  id integer [primary key]
  post_id integer [not null]
  url varchar

  indexes {
    post_id [type: hash]
  }
}

Table media_tmp_blob {
  id integer [primary key]
  user_id integer [not null]
  url varchar [unique]

  created_at timestamp

  indexes {
    created_at
    url [type: hash]
    user_id [type: hash]
  }
}


