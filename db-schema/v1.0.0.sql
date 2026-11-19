-- Folio server schema snapshot v1.0.0
-- Target: Supabase PostgreSQL
-- Idempotent: safe to run repeatedly on the same database.
-- UUIDs are the sync identity and relationship keys. `id` is server-only.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  CREATE TYPE public.account_role AS ENUM ('system_administrator', 'administrator', 'moderator', 'contributor');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.listing_status AS ENUM ('available', 'reserved', 'completed', 'withdrawn');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.offer_type AS ENUM ('swap', 'donation', 'swap_or_donation');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.book_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.request_status AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn', 'cancelled', 'completed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.report_status AS ENUM ('open', 'dismissed', 'warning', 'content_hidden', 'listing_removed', 'account_restricted', 'escalated');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.report_target_type AS ENUM ('listing', 'message', 'user');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.account (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  auth_user_uuid     uuid NOT NULL UNIQUE,
  role               public.account_role NOT NULL DEFAULT 'contributor',
  display_name       text NOT NULL,
  avatar_url         text,
  is_restricted      boolean NOT NULL DEFAULT false,
  restricted_until   timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.location_region (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  code               text NOT NULL UNIQUE,
  name               text NOT NULL UNIQUE,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.location_province (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  region_uuid        uuid NOT NULL,
  code               text NOT NULL,
  name               text NOT NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (region_uuid, code)
);

CREATE TABLE IF NOT EXISTS public.location_city_municipality (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  province_uuid      uuid NOT NULL,
  code               text NOT NULL,
  name               text NOT NULL,
  kind               text NOT NULL CHECK (kind IN ('city', 'municipality')),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (province_uuid, code)
);

CREATE TABLE IF NOT EXISTS public.location_area (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  city_municipality_uuid uuid NOT NULL,
  name               text NOT NULL,
  area_type          text NOT NULL CHECK (area_type IN ('campus', 'community_area')),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (city_municipality_uuid, name, area_type)
);

CREATE TABLE IF NOT EXISTS public.book_listing (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  owner_uuid         uuid NOT NULL,
  title              text NOT NULL,
  author             text NOT NULL,
  genre              text NOT NULL,
  condition          public.book_condition NOT NULL,
  description        text NOT NULL,
  image_url          text,
  offer_type         public.offer_type NOT NULL,
  region_uuid        uuid NOT NULL,
  province_uuid      uuid NOT NULL,
  city_municipality_uuid uuid NOT NULL,
  area_uuid          uuid,
  status             public.listing_status NOT NULL DEFAULT 'available',
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  published_at       timestamptz,
  completed_at       timestamptz,
  withdrawn_at       timestamptz,
  -- Retained through cancellation until the owner closes this reservation cycle.
  reservation_request_uuid uuid,
  CHECK ((status = 'reserved') = (reservation_request_uuid IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS public.exchange_request (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  listing_uuid       uuid NOT NULL,
  requester_uuid     uuid NOT NULL,
  offer_type         public.offer_type NOT NULL,
  note               text,
  status             public.request_status NOT NULL DEFAULT 'pending',
  accepted_at        timestamptz,
  cancelled_at       timestamptz,
  completed_at       timestamptz,
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.exchange_conversation (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  request_uuid       uuid NOT NULL UNIQUE,
  owner_uuid         uuid NOT NULL,
  requester_uuid     uuid NOT NULL,
  is_archived        boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.conversation_member (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  conversation_uuid  uuid NOT NULL,
  member_uuid        uuid NOT NULL,
  is_muted           boolean NOT NULL DEFAULT false,
  is_archived        boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (conversation_uuid, member_uuid)
);

CREATE TABLE IF NOT EXISTS public.message (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  conversation_uuid  uuid NOT NULL,
  request_uuid       uuid NOT NULL,
  sender_uuid        uuid NOT NULL,
  body               text NOT NULL CHECK (length(trim(body)) > 0),
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.user_block (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  blocker_uuid       uuid NOT NULL,
  blocked_uuid       uuid NOT NULL,
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  CHECK (blocker_uuid <> blocked_uuid)
);

CREATE TABLE IF NOT EXISTS public.content_report (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  reporter_uuid      uuid NOT NULL,
  target_type        public.report_target_type NOT NULL,
  target_uuid        uuid NOT NULL,
  reason             text NOT NULL,
  details            text,
  status             public.report_status NOT NULL DEFAULT 'open',
  assigned_to_uuid   uuid,
  resolved_by_uuid   uuid,
  resolved_at        timestamptz,
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.moderation_action (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  report_uuid        uuid NOT NULL,
  moderator_uuid     uuid NOT NULL,
  outcome            public.report_status NOT NULL CHECK (outcome <> 'open'),
  note               text,
  created_by         uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.app_setting (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               uuid NOT NULL UNIQUE,
  setting_group      text NOT NULL,
  setting_name       text NOT NULL,
  setting_value      jsonb NOT NULL,
  updated_by_uuid     uuid,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  archived_at        timestamptz,
  UNIQUE (setting_group, setting_name)
);

-- The partial unique index is the database-level concurrency guard.
-- Only one accepted request may exist for a listing at any time.
CREATE UNIQUE INDEX IF NOT EXISTS idx_exchange_request_one_accepted
  ON public.exchange_request (listing_uuid)
  WHERE status = 'accepted' AND archived_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_block_live_pair
  ON public.user_block (blocker_uuid, blocked_uuid)
  WHERE archived_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_listing_owner_live ON public.book_listing (owner_uuid, archived_at);
CREATE INDEX IF NOT EXISTS idx_listing_discovery ON public.book_listing (region_uuid, province_uuid, city_municipality_uuid, area_uuid, status, archived_at);
CREATE INDEX IF NOT EXISTS idx_listing_text ON public.book_listing (title, author, genre);
CREATE INDEX IF NOT EXISTS idx_request_listing_status ON public.exchange_request (listing_uuid, status, archived_at);
CREATE INDEX IF NOT EXISTS idx_request_requester ON public.exchange_request (requester_uuid, status, archived_at);
CREATE INDEX IF NOT EXISTS idx_conversation_member ON public.conversation_member (member_uuid, conversation_uuid, archived_at);
CREATE INDEX IF NOT EXISTS idx_message_conversation ON public.message (conversation_uuid, created_at, archived_at);
CREATE INDEX IF NOT EXISTS idx_report_queue ON public.content_report (status, created_at, archived_at);
CREATE INDEX IF NOT EXISTS idx_report_target ON public.content_report (target_type, target_uuid, archived_at);
CREATE INDEX IF NOT EXISTS idx_moderation_report ON public.moderation_action (report_uuid, created_at, archived_at);
CREATE INDEX IF NOT EXISTS idx_province_region ON public.location_province (region_uuid, archived_at);
CREATE INDEX IF NOT EXISTS idx_city_province ON public.location_city_municipality (province_uuid, archived_at);
CREATE INDEX IF NOT EXISTS idx_area_city ON public.location_area (city_municipality_uuid, archived_at);

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.prevent_reserved_listing_soft_delete()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
BEGIN
  IF OLD.archived_at IS NULL AND NEW.archived_at IS NOT NULL
     AND OLD.status = 'reserved' THEN
    RAISE EXCEPTION 'reserved listings must be cancelled, completed, or withdrawn through an authorized lifecycle operation before archival';
  END IF;
  IF OLD.archived_at IS NULL AND NEW.archived_at IS NOT NULL THEN
    UPDATE public.exchange_request SET status = 'rejected'
    WHERE listing_uuid = OLD.uuid AND status = 'pending' AND archived_at IS NULL;
  END IF;
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[
    'account', 'location_region', 'location_province',
    'location_city_municipality', 'location_area', 'book_listing',
    'exchange_request', 'exchange_conversation', 'conversation_member',
    'message', 'user_block', 'content_report', 'moderation_action', 'app_setting'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', 'trg_' || table_name || '_updated_at', table_name);
    EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()', 'trg_' || table_name || '_updated_at', table_name);
  END LOOP;
END $$;

DROP TRIGGER IF EXISTS trg_book_listing_prevent_reserved_soft_delete ON public.book_listing;
CREATE TRIGGER trg_book_listing_prevent_reserved_soft_delete
  BEFORE UPDATE ON public.book_listing
  FOR EACH ROW EXECUTE FUNCTION public.prevent_reserved_listing_soft_delete();

-- Accepts one pending request and changes all related rows in one transaction.
-- The listing row lock serializes simultaneous attempts; the partial unique index
-- remains the database-level invariant if another write path is introduced.
CREATE OR REPLACE FUNCTION public.accept_exchange_request(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  selected_request public.exchange_request;
  listing_row public.book_listing;
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT bl.* INTO listing_row
  FROM public.book_listing bl
  JOIN public.exchange_request er ON er.listing_uuid = bl.uuid
  WHERE er.uuid = p_request_uuid
  FOR UPDATE OF bl;

  IF listing_row.uuid IS NULL THEN
    RAISE EXCEPTION 'listing or request not found';
  END IF;

  IF actor_uuid IS NOT NULL AND actor_uuid <> listing_row.owner_uuid THEN
    RAISE EXCEPTION 'only the listing owner may accept a request';
  END IF;

  IF listing_row.owner_uuid <> actor_uuid THEN
    RAISE EXCEPTION 'only the listing owner may accept a request';
  END IF;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid
    AND listing_uuid = listing_row.uuid
    AND status = 'pending'
    AND archived_at IS NULL
  FOR UPDATE;

  IF selected_request.uuid IS NULL THEN
    RAISE EXCEPTION 'request is no longer pending';
  END IF;

  IF listing_row.status <> 'available' OR listing_row.archived_at IS NOT NULL THEN
    RAISE EXCEPTION 'listing is no longer available';
  END IF;

  IF selected_request.offer_type = 'swap_or_donation'
     OR (listing_row.offer_type <> 'swap_or_donation'
         AND listing_row.offer_type <> selected_request.offer_type) THEN
    RAISE EXCEPTION 'request offer type is no longer permitted by the listing';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = selected_request.requester_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'requester is restricted or inactive';
  END IF;

  UPDATE public.exchange_request
  SET status = 'rejected', updated_at = now()
  WHERE listing_uuid = listing_row.uuid
    AND status = 'pending'
    AND uuid <> selected_request.uuid
    AND archived_at IS NULL;

  UPDATE public.exchange_request
  SET status = 'accepted', accepted_at = now(), updated_at = now()
  WHERE uuid = selected_request.uuid;

  UPDATE public.book_listing
  SET status = 'reserved', reservation_request_uuid = selected_request.uuid, updated_at = now()
  WHERE uuid = listing_row.uuid;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid;
  RETURN to_jsonb(selected_request) - 'id';
END;
$$;

-- Cancels an accepted exchange before optionally relisting the book.
-- The request is made non-accepted before the listing can become available.
CREATE OR REPLACE FUNCTION public.cancel_exchange_request(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  selected_request public.exchange_request;
  listing_row public.book_listing;
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT bl.* INTO listing_row
  FROM public.book_listing bl
  JOIN public.exchange_request er ON er.listing_uuid = bl.uuid
  WHERE er.uuid = p_request_uuid
  FOR UPDATE OF bl;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid
    AND listing_uuid = listing_row.uuid
    AND status = 'accepted'
    AND archived_at IS NULL
    AND listing_row.status = 'reserved'
    AND listing_row.archived_at IS NULL
    AND listing_row.reservation_request_uuid = p_request_uuid
  FOR UPDATE;

  IF selected_request.uuid IS NULL THEN
    RAISE EXCEPTION 'request is not an active accepted reservation';
  END IF;

  IF actor_uuid IS NOT NULL AND actor_uuid <> listing_row.owner_uuid AND actor_uuid <> selected_request.requester_uuid THEN
    RAISE EXCEPTION 'only exchange participants may cancel';
  END IF;

  UPDATE public.exchange_request
  SET status = 'cancelled', cancelled_at = now(), updated_at = now()
  WHERE uuid = selected_request.uuid;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid;
  RETURN to_jsonb(selected_request) - 'id';
END;
$$;

-- Relisting is a separate owner-authorized operation. Cancellation alone never
-- makes a reserved listing available again.
CREATE OR REPLACE FUNCTION public.relist_cancelled_exchange(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  listing_row public.book_listing;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT bl.* INTO listing_row
  FROM public.book_listing bl
  JOIN public.exchange_request er ON er.listing_uuid = bl.uuid
  WHERE er.uuid = p_request_uuid
    AND er.status = 'cancelled'
    AND er.archived_at IS NULL
    AND bl.reservation_request_uuid = er.uuid
    AND bl.owner_uuid = actor_uuid
    AND bl.status = 'reserved'
    AND bl.archived_at IS NULL
    AND NOT EXISTS (
      SELECT 1
      FROM public.exchange_request active_request
      WHERE active_request.listing_uuid = bl.uuid
        AND active_request.status = 'accepted'
        AND active_request.archived_at IS NULL
    )
  FOR UPDATE OF bl;

  IF listing_row.uuid IS NULL THEN
    RAISE EXCEPTION 'only the owner may relist a reserved listing after cancellation';
  END IF;

  UPDATE public.book_listing
  SET status = 'available', reservation_request_uuid = NULL, updated_at = now()
  WHERE uuid = listing_row.uuid
    AND status = 'reserved';

  SELECT * INTO listing_row FROM public.book_listing WHERE uuid = listing_row.uuid;
  RETURN to_jsonb(listing_row) - 'id';
END;
$$;

-- Withdraws a listing without bypassing an active accepted exchange. Pending
-- requests are rejected because the listing is no longer requestable.
CREATE OR REPLACE FUNCTION public.withdraw_listing(p_listing_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  listing_row public.book_listing;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT * INTO listing_row
  FROM public.book_listing
  WHERE uuid = p_listing_uuid
    AND owner_uuid = actor_uuid
    AND archived_at IS NULL
  FOR UPDATE;

  IF listing_row.uuid IS NULL THEN
    RAISE EXCEPTION 'listing not found or caller is not the owner';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.exchange_request
    WHERE listing_uuid = listing_row.uuid
      AND status = 'accepted'
      AND archived_at IS NULL
  ) THEN
    RAISE EXCEPTION 'active accepted exchange must be cancelled before withdrawal';
  END IF;

  IF listing_row.status IN ('completed', 'withdrawn') THEN
    RAISE EXCEPTION 'listing cannot be withdrawn from its current state';
  END IF;

  UPDATE public.exchange_request
  SET status = 'rejected', updated_at = now()
  WHERE listing_uuid = listing_row.uuid
    AND status = 'pending'
    AND archived_at IS NULL;

  UPDATE public.book_listing
  SET status = 'withdrawn', reservation_request_uuid = NULL, withdrawn_at = now(), updated_at = now()
  WHERE uuid = listing_row.uuid;

  SELECT * INTO listing_row FROM public.book_listing WHERE uuid = p_listing_uuid;
  RETURN to_jsonb(listing_row) - 'id';
END;
$$;

-- Lets only the requester withdraw a pending request. It never changes the
-- listing status, so other contributors may continue requesting an available book.
CREATE OR REPLACE FUNCTION public.withdraw_pending_request(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  result_request public.exchange_request;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  UPDATE public.exchange_request
  SET status = 'withdrawn', updated_at = now()
  WHERE uuid = p_request_uuid
    AND requester_uuid = actor_uuid
    AND status = 'pending'
    AND archived_at IS NULL
  RETURNING * INTO result_request;

  IF result_request.uuid IS NULL THEN
    RAISE EXCEPTION 'request is not pending or caller is not the requester';
  END IF;

  RETURN to_jsonb(result_request) - 'id';
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_exchange(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  selected_request public.exchange_request;
  listing_row public.book_listing;
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT bl.* INTO listing_row
  FROM public.book_listing bl
  JOIN public.exchange_request er ON er.listing_uuid = bl.uuid
  WHERE er.uuid = p_request_uuid
  FOR UPDATE OF bl;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid
    AND listing_uuid = listing_row.uuid
    AND status = 'accepted'
    AND archived_at IS NULL
    AND listing_row.status = 'reserved'
    AND listing_row.archived_at IS NULL
    AND listing_row.reservation_request_uuid = p_request_uuid
  FOR UPDATE;

  IF selected_request.uuid IS NULL THEN
    RAISE EXCEPTION 'request is not an active accepted reservation';
  END IF;

  IF actor_uuid IS NOT NULL AND actor_uuid <> listing_row.owner_uuid AND actor_uuid <> selected_request.requester_uuid THEN
    RAISE EXCEPTION 'only exchange participants may complete';
  END IF;

  UPDATE public.exchange_request
  SET status = 'completed', completed_at = now(), updated_at = now()
  WHERE uuid = selected_request.uuid;

  UPDATE public.book_listing
  SET status = 'completed', reservation_request_uuid = NULL, completed_at = now(), updated_at = now()
  WHERE uuid = listing_row.uuid;

  SELECT * INTO selected_request
  FROM public.exchange_request
  WHERE uuid = p_request_uuid;
  RETURN to_jsonb(selected_request) - 'id';
END;
$$;

-- Request creation is guarded by the listing lock and the status check.
CREATE OR REPLACE FUNCTION public.create_exchange_request(
  p_request_uuid uuid,
  p_listing_uuid uuid,
  p_requester_uuid uuid,
  p_offer_type public.offer_type,
  p_note text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  listing_row public.book_listing;
  result_request public.exchange_request;
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF actor_uuid <> p_requester_uuid THEN
    RAISE EXCEPTION 'requester does not match the authenticated account';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT * INTO listing_row
  FROM public.book_listing
  WHERE uuid = p_listing_uuid
  FOR UPDATE;

  IF listing_row.uuid IS NULL OR listing_row.status <> 'available' OR listing_row.archived_at IS NOT NULL THEN
    RAISE EXCEPTION 'listing is not available for requests';
  END IF;

  IF listing_row.owner_uuid = p_requester_uuid THEN
    RAISE EXCEPTION 'listing owners cannot request their own books';
  END IF;

  IF p_offer_type = 'swap_or_donation'
     OR (listing_row.offer_type <> 'swap_or_donation' AND listing_row.offer_type <> p_offer_type) THEN
    RAISE EXCEPTION 'request offer type is not permitted by the listing';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.user_block
    WHERE archived_at IS NULL
      AND ((blocker_uuid = listing_row.owner_uuid AND blocked_uuid = p_requester_uuid)
        OR (blocker_uuid = p_requester_uuid AND blocked_uuid = listing_row.owner_uuid))
  ) THEN
    RAISE EXCEPTION 'request is blocked';
  END IF;

  INSERT INTO public.exchange_request (uuid, listing_uuid, requester_uuid, offer_type, note, created_by)
  VALUES (p_request_uuid, p_listing_uuid, p_requester_uuid, p_offer_type, p_note, p_requester_uuid)
  RETURNING * INTO result_request;

  INSERT INTO public.exchange_conversation (uuid, request_uuid, owner_uuid, requester_uuid)
  VALUES (gen_random_uuid(), result_request.uuid, listing_row.owner_uuid, p_requester_uuid)
  ON CONFLICT (request_uuid) DO NOTHING;

  INSERT INTO public.conversation_member (uuid, conversation_uuid, member_uuid)
  SELECT gen_random_uuid(), ec.uuid, member_uuid
  FROM public.exchange_conversation ec
  CROSS JOIN LATERAL unnest(ARRAY[listing_row.owner_uuid, p_requester_uuid]) AS members(member_uuid)
  WHERE ec.request_uuid = result_request.uuid
  ON CONFLICT (conversation_uuid, member_uuid) DO NOTHING;

  RETURN to_jsonb(result_request) - 'id';
END;
$$;

-- Creates or returns the contributor account for the authenticated Supabase user.
-- The caller cannot choose role, restriction, or another auth identity.
CREATE OR REPLACE FUNCTION public.provision_account(
  p_display_name text,
  p_avatar_url text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  auth_uuid uuid := auth.uid();
  result_account public.account;
BEGIN
  IF auth_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Supabase user is required';
  END IF;

  IF p_display_name IS NULL OR length(trim(p_display_name)) = 0 THEN
    RAISE EXCEPTION 'display name is required';
  END IF;

  INSERT INTO public.account (uuid, auth_user_uuid, role, display_name, avatar_url)
  VALUES (gen_random_uuid(), auth_uuid, 'contributor', trim(p_display_name), p_avatar_url)
  ON CONFLICT (auth_user_uuid) DO NOTHING;

  SELECT * INTO result_account
  FROM public.account
  WHERE auth_user_uuid = auth_uuid
  FOR UPDATE;

  IF result_account.archived_at IS NOT NULL OR result_account.is_restricted
     OR (result_account.restricted_until IS NOT NULL AND result_account.restricted_until > now()) THEN
    RAISE EXCEPTION 'archived or restricted account cannot be provisioned';
  END IF;

  UPDATE public.account
  SET display_name = trim(p_display_name), avatar_url = p_avatar_url, updated_at = now()
  WHERE uuid = result_account.uuid;

  SELECT * INTO result_account FROM public.account WHERE auth_user_uuid = auth_uuid;

  RETURN to_jsonb(result_account) - 'id';
END;
$$;

CREATE OR REPLACE FUNCTION public.send_exchange_message(
  p_message_uuid uuid,
  p_conversation_uuid uuid,
  p_request_uuid uuid,
  p_body text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  conversation_row public.exchange_conversation;
  result_message public.message;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  SELECT * INTO conversation_row
  FROM public.exchange_conversation
  WHERE uuid = p_conversation_uuid
    AND request_uuid = p_request_uuid
    AND archived_at IS NULL
    AND (owner_uuid = actor_uuid OR requester_uuid = actor_uuid)
  FOR UPDATE;

  IF conversation_row.uuid IS NULL THEN
    RAISE EXCEPTION 'caller is not an exchange participant';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.user_block
    WHERE archived_at IS NULL
      AND ((blocker_uuid = conversation_row.owner_uuid AND blocked_uuid = conversation_row.requester_uuid)
        OR (blocker_uuid = conversation_row.requester_uuid AND blocked_uuid = conversation_row.owner_uuid))
  ) THEN
    RAISE EXCEPTION 'messaging is blocked';
  END IF;

  INSERT INTO public.message (uuid, conversation_uuid, request_uuid, sender_uuid, body, created_by)
  VALUES (p_message_uuid, p_conversation_uuid, p_request_uuid, actor_uuid, p_body, actor_uuid)
  RETURNING * INTO result_message;
  RETURN to_jsonb(result_message) - 'id';
END;
$$;

CREATE OR REPLACE FUNCTION public.resolve_content_report(
  p_report_uuid uuid,
  p_outcome public.report_status,
  p_note text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  actor_role public.account_role;
  report_row public.content_report;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  SELECT role INTO actor_role
  FROM public.account
  WHERE uuid = actor_uuid
    AND archived_at IS NULL
    AND NOT is_restricted
    AND (restricted_until IS NULL OR restricted_until <= now());

  IF actor_role IS NULL OR actor_role NOT IN ('system_administrator', 'administrator', 'moderator') THEN
    RAISE EXCEPTION 'moderator authorization is required';
  END IF;

  IF p_outcome = 'open' THEN
    RAISE EXCEPTION 'a report resolution cannot be open';
  END IF;

  SELECT * INTO report_row
  FROM public.content_report
  WHERE uuid = p_report_uuid
    AND archived_at IS NULL
  FOR UPDATE;

  IF report_row.uuid IS NULL THEN
    RAISE EXCEPTION 'report not found';
  END IF;

  INSERT INTO public.moderation_action (uuid, report_uuid, moderator_uuid, outcome, note, created_by)
  VALUES (gen_random_uuid(), report_row.uuid, actor_uuid, p_outcome, p_note, actor_uuid);

  UPDATE public.content_report
  SET status = p_outcome, resolved_by_uuid = actor_uuid, resolved_at = now(), updated_at = now()
  WHERE uuid = report_row.uuid;

  SELECT * INTO report_row FROM public.content_report WHERE uuid = p_report_uuid;
  RETURN to_jsonb(report_row) - 'id';
END;
$$;

CREATE OR REPLACE FUNCTION public.reject_pending_request(p_request_uuid uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
  actor_uuid uuid := (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid());
  result_request public.exchange_request;
BEGIN
  IF actor_uuid IS NULL THEN
    RAISE EXCEPTION 'authenticated Folio account is required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.account
    WHERE uuid = actor_uuid
      AND (archived_at IS NOT NULL OR is_restricted OR (restricted_until IS NOT NULL AND restricted_until > now()))
  ) THEN
    RAISE EXCEPTION 'account is restricted or inactive';
  END IF;

  UPDATE public.exchange_request AS request
  SET status = 'rejected', updated_at = now()
  WHERE uuid = p_request_uuid
    AND EXISTS (
      SELECT 1 FROM public.book_listing AS listing
      WHERE listing.uuid = request.listing_uuid AND listing.owner_uuid = actor_uuid
    )
    AND status = 'pending'
    AND archived_at IS NULL
  RETURNING * INTO result_request;

  IF result_request.uuid IS NULL THEN
    RAISE EXCEPTION 'request is not pending or caller is not the listing owner';
  END IF;

  RETURN to_jsonb(result_request) - 'id';
END;
$$;

-- Supabase RLS: clients can see public listings and their own/participating data.
ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_listing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_request ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_conversation ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_member ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_block ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_report ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_action ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_region ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_province ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_city_municipality ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_area ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_setting ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS listing_public_read ON public.book_listing;
CREATE POLICY listing_public_read ON public.book_listing
  FOR SELECT USING (archived_at IS NULL AND status = 'available');

DROP POLICY IF EXISTS listing_owner_read ON public.book_listing;
CREATE POLICY listing_owner_read ON public.book_listing
  FOR SELECT TO authenticated USING (
    owner_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())
  );

DROP POLICY IF EXISTS conversation_preferences_read ON public.conversation_member;
CREATE POLICY conversation_preferences_read ON public.conversation_member
  FOR SELECT TO authenticated USING (
    archived_at IS NULL AND
    member_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())
  );

DROP POLICY IF EXISTS conversation_preferences_update ON public.conversation_member;
CREATE POLICY conversation_preferences_update ON public.conversation_member
  FOR UPDATE TO authenticated USING (
    archived_at IS NULL AND member_uuid IN (
      SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid()
        AND a.archived_at IS NULL AND NOT a.is_restricted
        AND (a.restricted_until IS NULL OR a.restricted_until <= now())
    )
  );

DROP POLICY IF EXISTS listing_owner_insert ON public.book_listing;
CREATE POLICY listing_owner_insert ON public.book_listing
  FOR INSERT WITH CHECK (
    archived_at IS NULL AND status = 'available' AND
    owner_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now()))
  );

DROP POLICY IF EXISTS listing_owner_update ON public.book_listing;
CREATE POLICY listing_owner_update ON public.book_listing
  FOR UPDATE USING (
    archived_at IS NULL AND
    owner_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now()))
  ) WITH CHECK (
    owner_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now()))
  );

DROP POLICY IF EXISTS account_self_read ON public.account;
CREATE POLICY account_self_read ON public.account
  FOR SELECT USING (auth.uid() = auth_user_uuid AND archived_at IS NULL);

DROP POLICY IF EXISTS request_participant_read ON public.exchange_request;
CREATE POLICY request_participant_read ON public.exchange_request
  FOR SELECT USING (
    archived_at IS NULL AND
    (requester_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())
     OR listing_uuid IN (SELECT bl.uuid FROM public.book_listing bl WHERE bl.owner_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())))
  );

DROP POLICY IF EXISTS request_no_direct_insert ON public.exchange_request;
DROP POLICY IF EXISTS request_no_direct_update ON public.exchange_request;
DROP POLICY IF EXISTS request_no_direct_delete ON public.exchange_request;

DROP POLICY IF EXISTS conversation_member_read ON public.exchange_conversation;
CREATE POLICY conversation_member_read ON public.exchange_conversation
  FOR SELECT USING (
    archived_at IS NULL AND
    (owner_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())
     OR requester_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid()))
  );

DROP POLICY IF EXISTS message_participant_read ON public.message;
CREATE POLICY message_participant_read ON public.message
  FOR SELECT USING (
    archived_at IS NULL AND
    conversation_uuid IN (SELECT ec.uuid FROM public.exchange_conversation ec
      WHERE ec.owner_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid())
         OR ec.requester_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid()))
  );

DROP POLICY IF EXISTS message_no_direct_insert ON public.message;
DROP POLICY IF EXISTS message_no_direct_update ON public.message;
DROP POLICY IF EXISTS message_no_direct_delete ON public.message;

DROP POLICY IF EXISTS block_owner_insert ON public.user_block;
CREATE POLICY block_owner_insert ON public.user_block
  FOR INSERT WITH CHECK (
    archived_at IS NULL AND
    blocker_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now()))
  );

DROP POLICY IF EXISTS block_owner_update ON public.user_block;
CREATE POLICY block_owner_update ON public.user_block
  FOR UPDATE USING (blocker_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now())))
  WITH CHECK (blocker_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now())));

DROP POLICY IF EXISTS report_owner_insert ON public.content_report;
CREATE POLICY report_owner_insert ON public.content_report
  FOR INSERT WITH CHECK (
    archived_at IS NULL AND
    reporter_uuid = (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid() AND a.archived_at IS NULL AND NOT a.is_restricted AND (a.restricted_until IS NULL OR a.restricted_until <= now()))
  );

DROP POLICY IF EXISTS own_block_read ON public.user_block;
CREATE POLICY own_block_read ON public.user_block
  FOR SELECT USING (archived_at IS NULL AND blocker_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid()));

DROP POLICY IF EXISTS own_report_read ON public.content_report;
CREATE POLICY own_report_read ON public.content_report
  FOR SELECT USING (archived_at IS NULL AND reporter_uuid IN (SELECT a.uuid FROM public.account a WHERE a.auth_user_uuid = auth.uid()));

DROP POLICY IF EXISTS moderator_report_read ON public.content_report;
CREATE POLICY moderator_report_read ON public.content_report
  FOR SELECT USING (
    archived_at IS NULL AND
    EXISTS (
      SELECT 1 FROM public.account a
      WHERE a.auth_user_uuid = auth.uid()
        AND a.archived_at IS NULL
        AND NOT a.is_restricted
        AND (a.restricted_until IS NULL OR a.restricted_until <= now())
        AND a.role IN ('system_administrator', 'administrator', 'moderator')
    )
  );

DROP POLICY IF EXISTS moderator_action_read ON public.moderation_action;
CREATE POLICY moderator_action_read ON public.moderation_action
  FOR SELECT USING (
    archived_at IS NULL AND
    EXISTS (
      SELECT 1 FROM public.account a
      WHERE a.auth_user_uuid = auth.uid()
        AND a.archived_at IS NULL
        AND NOT a.is_restricted
        AND (a.restricted_until IS NULL OR a.restricted_until <= now())
        AND a.role IN ('system_administrator', 'administrator', 'moderator')
    )
  );

DROP POLICY IF EXISTS location_public_read ON public.location_region;
CREATE POLICY location_public_read ON public.location_region
  FOR SELECT USING (archived_at IS NULL);

DROP POLICY IF EXISTS province_public_read ON public.location_province;
CREATE POLICY province_public_read ON public.location_province
  FOR SELECT USING (archived_at IS NULL);

DROP POLICY IF EXISTS city_public_read ON public.location_city_municipality;
CREATE POLICY city_public_read ON public.location_city_municipality
  FOR SELECT USING (archived_at IS NULL);

DROP POLICY IF EXISTS area_public_read ON public.location_area;
CREATE POLICY area_public_read ON public.location_area
  FOR SELECT USING (archived_at IS NULL);

-- Account roles and restriction flags are server/admin controlled. No client write
-- policy is created for account, moderation_action, or app_setting.

REVOKE ALL ON FUNCTION public.set_updated_at() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.prevent_reserved_listing_soft_delete() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.reject_pending_request(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.reject_pending_request(uuid) TO authenticated;
REVOKE ALL ON FUNCTION public.accept_exchange_request(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.cancel_exchange_request(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.relist_cancelled_exchange(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.withdraw_listing(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.withdraw_pending_request(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.complete_exchange(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.create_exchange_request(uuid, uuid, uuid, public.offer_type, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.send_exchange_message(uuid, uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.resolve_content_report(uuid, public.report_status, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.provision_account(text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.accept_exchange_request(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_exchange_request(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.relist_cancelled_exchange(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.withdraw_listing(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.withdraw_pending_request(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_exchange(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_exchange_request(uuid, uuid, uuid, public.offer_type, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_exchange_message(uuid, uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_content_report(uuid, public.report_status, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.provision_account(text, text) TO authenticated;

-- Ordinary authenticated/offline-sync clients may edit listing content and the
-- soft-delete marker, but cannot write server-authoritative lifecycle, ownership,
-- attribution, or timestamp fields. Lifecycle RPCs run as the function owner and
-- retain the required column privileges. The request table has no client write
-- policy at all; requests are created and transitioned only through RPCs.
REVOKE ALL ON TABLE public.account, public.book_listing, public.exchange_request,
  public.exchange_conversation, public.conversation_member, public.message,
  public.user_block, public.content_report, public.moderation_action,
  public.location_region, public.location_province, public.location_city_municipality,
  public.location_area, public.app_setting FROM PUBLIC, anon, authenticated;

GRANT SELECT (uuid, auth_user_uuid, role, display_name, avatar_url, is_restricted, restricted_until, created_at, updated_at, archived_at)
  ON public.account TO authenticated;
GRANT SELECT (uuid, code, name, created_at, updated_at, archived_at)
  ON public.location_region TO anon, authenticated;
GRANT SELECT (uuid, region_uuid, code, name, created_at, updated_at, archived_at)
  ON public.location_province TO anon, authenticated;
GRANT SELECT (uuid, province_uuid, code, name, kind, created_at, updated_at, archived_at)
  ON public.location_city_municipality TO anon, authenticated;
GRANT SELECT (uuid, city_municipality_uuid, name, area_type, created_at, updated_at, archived_at)
  ON public.location_area TO anon, authenticated;
GRANT SELECT (uuid, owner_uuid, title, author, genre, condition, description, image_url, offer_type, region_uuid, province_uuid, city_municipality_uuid, area_uuid, status, created_by, created_at, updated_at, archived_at, published_at, completed_at, withdrawn_at, reservation_request_uuid)
  ON public.book_listing TO anon, authenticated;
GRANT SELECT (uuid, listing_uuid, requester_uuid, offer_type, note, status, accepted_at, cancelled_at, completed_at, created_by, created_at, updated_at, archived_at)
  ON public.exchange_request TO authenticated;
GRANT SELECT (uuid, request_uuid, owner_uuid, requester_uuid, is_archived, created_at, updated_at, archived_at)
  ON public.exchange_conversation TO authenticated;
GRANT SELECT (uuid, conversation_uuid, member_uuid, is_muted, is_archived, created_at, updated_at, archived_at)
  ON public.conversation_member TO authenticated;
GRANT SELECT (uuid, conversation_uuid, request_uuid, sender_uuid, body, created_by, created_at, updated_at, archived_at)
  ON public.message TO authenticated;
GRANT SELECT (uuid, blocker_uuid, blocked_uuid, created_by, created_at, updated_at, archived_at)
  ON public.user_block TO authenticated;
GRANT SELECT (uuid, reporter_uuid, target_type, target_uuid, reason, details, status, assigned_to_uuid, resolved_by_uuid, resolved_at, created_by, created_at, updated_at, archived_at)
  ON public.content_report TO authenticated;
GRANT SELECT (uuid, report_uuid, moderator_uuid, outcome, note, created_by, created_at, updated_at, archived_at)
  ON public.moderation_action TO authenticated;

GRANT INSERT (
  uuid, owner_uuid, title, author, genre, condition, description, image_url,
  offer_type, region_uuid, province_uuid, city_municipality_uuid, area_uuid
) ON public.book_listing TO authenticated;
GRANT UPDATE (
  title, author, genre, condition, description, image_url, offer_type,
  region_uuid, province_uuid, city_municipality_uuid, area_uuid, archived_at
) ON public.book_listing TO authenticated;
GRANT INSERT (uuid, blocker_uuid, blocked_uuid) ON public.user_block TO authenticated;
GRANT UPDATE (archived_at) ON public.user_block TO authenticated;
GRANT UPDATE (is_muted, is_archived) ON public.conversation_member TO authenticated;
GRANT INSERT (uuid, reporter_uuid, target_type, target_uuid, reason, details)
  ON public.content_report TO authenticated;

-- Defense in depth: these remain explicit even though table privileges above are
-- already narrowed to the permitted columns.
REVOKE UPDATE (
  uuid, owner_uuid, status, created_by, created_at, updated_at,
  published_at, completed_at, withdrawn_at, reservation_request_uuid
) ON public.book_listing FROM PUBLIC, anon, authenticated;
REVOKE UPDATE (
  uuid, listing_uuid, requester_uuid, offer_type, status, accepted_at,
  cancelled_at, completed_at, created_by, created_at, updated_at
) ON public.exchange_request FROM PUBLIC, anon, authenticated;

-- Verification checklist for Supabase SQL editor / CI integration tests:
-- 1. Anonymous and authenticated callers without a public.account row must receive
--    "authenticated Folio account is required" from every RPC.
-- 2. A restricted account must fail request, accept, cancel, complete, and message RPCs.
-- 3. Two concurrent accept_exchange_request calls for different pending requests on
--    one listing must produce exactly one success, one accepted request, one reserved
--    listing, and rejected status for the other request.
-- 4. cancel_exchange_request(request) must leave the listing reserved. A requester
--    cannot relist it; relist_cancelled_exchange(request) succeeds only for the owner.
--    A stale cancelled request must fail if another request is currently accepted.
-- 5. complete_exchange must fail for non-participants and must leave the listing and
--    request completed after a successful call.
-- 6. RLS isolation tests must prove guests can read only public listings and locations,
--    participants can read only their conversation/messages, and unrelated users cannot.
-- 7. Direct INSERT/UPDATE on exchange_request/message and direct lifecycle status changes
--    on book_listing must fail; authorized RPCs must remain functional. Also verify
--    an authenticated client cannot UPDATE the revoked lifecycle columns directly.
-- 8. Attempted client changes to account.role or account.is_restricted must fail.
-- 9. Non-moderators must fail resolve_content_report; moderator/admin calls must
--    create one moderation_action and update the report status atomically.
-- 10. provision_account must always create contributor role, reject anonymous calls,
--     and reject archived/restricted accounts without modifying them.
-- 11. withdraw_listing must reject active accepted exchanges, reject pending requests,
--     and set the listing withdrawn only for its owner.
-- 12. withdraw_pending_request must be requester-only and must not alter listing status.
-- 13. Direct archival of a reserved listing must fail; archival of an available or
--     completed listing may proceed through the normal soft-delete sync path.

COMMIT;
