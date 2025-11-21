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


