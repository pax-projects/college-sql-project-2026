create or replace trigger check_challenge_completion 
  after insert on session
  for each row
  execute function check_challenge_completion();
