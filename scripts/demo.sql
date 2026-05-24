-----------------------------------------------------------
-- INTERACTIVE DEMO
-----------------------------------------------------------

prepare challenges_by_category(varchar) as
  with recursive descendants as (
    select id, name from sports_categories_tags where name = $1
    union all
    select c.id, c.name
    from sports_categories_tags c
    join descendants d on c.parent_id = d.id
  )
  select distinct c.id, c.title, c.start_datetime, c.end_datetime
  from challenges c
  join challenge_categories cc on cc.challenge_id = c.id
  join descendants d on d.id = cc.sport_category_id
  where c.end_datetime >= current_timestamp
    and c.deleted_at is null
  order by c.start_datetime;

\prompt 'Sport category (e.g. cyclisme, vtt, marathon): ' v_cat
execute challenges_by_category(:'v_cat');

prepare user_recent_sessions(integer, integer) as
  select id, start_datetime, distance, height_diff, avg_speed
  from sessions
  where user_id = $1
    and deleted_at is null
  order by start_datetime desc
  limit $2;

\prompt 'User id: ' v_uid
\prompt 'How many recent sessions: ' v_n
execute user_recent_sessions(:v_uid, :v_n);

prepare challenges_by_hashtag(varchar) as
  select c.id, c.title, c.is_collective, c.start_datetime, c.end_datetime
  from challenges c
  join challenge_hashtags ch on ch.challenge_id = c.id
  join hashtags_tags h on h.id = ch.hashtag_id
  where h.name = $1
    and c.deleted_at is null
  order by c.start_datetime desc;

\prompt 'Hashtag (e.g. lac, trail, ecochallenge): ' v_tag
execute challenges_by_hashtag(:'v_tag');
