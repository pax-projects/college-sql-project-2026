-----------------------------------------------------------
-- RECOMMENDATION : SIMILAR
-----------------------------------------------------------
-- Top-N upcoming challenges closest to the user's taste vector
prepare recommend_similar(integer, integer) as
with
  u as (
    select category_id, value
    from vectors
    where entity_type = 'user' and entity_id = $1
  ),
  scored as (
    select
      cv.entity_id                   as challenge_id,
      sum(u.value * cv.value)        as dot,
      sqrt(sum(u.value * u.value))   as norm_u,
      sqrt(sum(cv.value * cv.value)) as norm_c
    from u
    join vectors cv
      on cv.entity_type = 'challenge'
     and cv.category_id = u.category_id
    group by cv.entity_id
  )
select
  ch.id,
  ch.title,
  round((dot / nullif(norm_u * norm_c, 0))::numeric, 4) as cosine
from scored s
join challenges ch on ch.id = s.challenge_id
where ch.end_datetime >= current_timestamp
  and ch.deleted_at is null
  and s.norm_u > 0
  and s.norm_c > 0
  and not exists (
    select 1 from challenge_members cm
    where cm.challenge_id = ch.id and cm.user_id = $1
  )
order by cosine desc
limit $2;

-----------------------------------------------------------
-- RECOMMENDATION : DISCOVER
-----------------------------------------------------------
-- Top-N upcoming challenges furthest from the user's taste vector
prepare recommend_discover(integer, integer) as
with
  u as (
    select category_id, value
    from vectors
    where entity_type = 'user' and entity_id = $1
  ),
  scored as (
    select
      cv.entity_id                   as challenge_id,
      sum(u.value * cv.value)        as dot,
      sqrt(sum(u.value * u.value))   as norm_u,
      sqrt(sum(cv.value * cv.value)) as norm_c
    from u
    join vectors cv
      on cv.entity_type = 'challenge'
     and cv.category_id = u.category_id
    group by cv.entity_id
  )
select
  ch.id,
  ch.title,
  round((dot / nullif(norm_u * norm_c, 0))::numeric, 4) as cosine
from scored s
join challenges ch on ch.id = s.challenge_id
where ch.end_datetime >= current_timestamp
  and ch.deleted_at is null
  and s.norm_u > 0
  and s.norm_c > 0
  and not exists (
    select 1 from challenge_members cm
    where cm.challenge_id = ch.id and cm.user_id = $1
  )
order by cosine asc
limit $2;

-- execute recommend_similar(5, 10);
-- execute recommend_discover(5, 10);
