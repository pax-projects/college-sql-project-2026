-----------------------------------------------------------
-- RAW VECTOR VALUES
-----------------------------------------------------------
-- User affinity per category: number of joined challenges eligible for it
update vectors v
set value = sub.cnt
from (
  select cm.user_id, cc.sport_category_id, count(*)::float as cnt
  from challenge_members cm
  join challenge_categories cc on cc.challenge_id = cm.challenge_id
  group by cm.user_id, cc.sport_category_id
) sub
where v.entity_type = 'user'
  and v.entity_id = sub.user_id
  and v.category_id = sub.sport_category_id;

-- Challenge eligibility per category
update vectors v
set value = 1
from challenge_categories cc
where v.entity_type = 'challenge'
  and v.entity_id = cc.challenge_id
  and v.category_id = cc.sport_category_id;

-----------------------------------------------------------
-- NORMALIZE EACH NON-EMPTY VECTOR
-----------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select entity_type, entity_id
    from vectors
    group by entity_type, entity_id
    having sum(abs(value)) > 0
  loop
    perform calculate_vector_softmax(r.entity_id, r.entity_type);
  end loop;
end $$;
