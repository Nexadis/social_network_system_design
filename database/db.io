// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

// ---------------------------- DB -----------------------------
Table users {
  id integer [primary key]
  name varchar
  surname varchar
  lastname varchar
  description text
}

Table subscribers{
  id integer [primary key]
  user_id integer [not null]
  subscriber_id integer [not null]

  indexes {
    (user_id,subscriber_id) [unique]
    user_id [type: hash]
    subscriber_id [type: hash]
  }
}

Table places{
  id integer [primary key]
  name varchar
  description text

  lat integer
  lon integer
}

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

Table reactions{
  user_id integer [not null]
  post_id integer [not null]
  
  reaction integer

  indexes {
    (user_id,post_id)
  }
}

// Отдельная таблица, чтоб быстро считать рейтинг
// но так увеличиваем нагрузку на запись
Table rating {
  post_id integer [unique, not null]

  total_score integer [default: 0]
  count_users integer [default: 0]

  indexes {
    post_id [type: hash]
  }
}

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

Ref user_subscribers: users.id < subscribers.user_id
Ref user_subscriptions: users.id < subscribers.subscriber_id

Ref user_posts: users.id < posts.user_id
Ref post_media: posts.id < post_media.post_id

Ref user_reactions: users.id < reactions.user_id
Ref post_reactions: posts.id < reactions.post_id
Ref rating_post: posts.id < rating.post_id

Ref place_posts: places.id < posts.place_id

Ref post_comments: posts.id < comments.post_id
Ref user_comments: users.id < comments.user_id
