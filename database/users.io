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


Ref user_subscribers: users.id < subscribers.user_id
Ref user_subscriptions: users.id < subscribers.subscriber_id
