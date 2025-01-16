CREATE FUNCTION trigger_set_usertimestamp()
RETURNS trigger
AS $$
    BEGIN
        NEW.updated_at := current_timestamp;
        NEW.updated_by := current_user;
        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;
