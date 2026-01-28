drop extension if exists "pg_net";

create schema if not exists "api";

create sequence "api"."aisignal_id_seq";

create sequence "api"."audit_log_id_seq";


  create table "api"."ai_calls" (
    "id" uuid not null default gen_random_uuid(),
    "endpoint" text not null,
    "model" text default 'sonar-pro'::text,
    "prompt" text,
    "response" text,
    "tokens_in" integer,
    "tokens_out" integer,
    "cost_usd" numeric,
    "status" integer default 200,
    "created_at" timestamp without time zone default now()
      );


alter table "api"."ai_calls" enable row level security;


  create table "api"."aisignal" (
    "id" bigint not null default nextval('api.aisignal_id_seq'::regclass),
    "symbol" text not null,
    "direction" text not null,
    "entry_price" numeric(20,8) not null,
    "stop_loss" numeric(20,8) not null,
    "take_profit" numeric(20,8) not null,
    "confidence" numeric(3,2),
    "status" text default 'pending'::text,
    "approved_by" text,
    "approved_at" timestamp with time zone,
    "rejected_by" text,
    "rejected_at" timestamp with time zone,
    "reject_reason" text,
    "reasoning" text,
    "executed_at" timestamp with time zone,
    "closed_at" timestamp with time zone,
    "profit" numeric(20,8),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "api"."aisignal" enable row level security;


  create table "api"."audit_log" (
    "id" bigint not null default nextval('api.audit_log_id_seq'::regclass),
    "event_type" text not null,
    "signal_id" bigint,
    "agent" text,
    "reasoning" text,
    "metadata" jsonb,
    "timestamp" timestamp with time zone default now()
      );


alter table "api"."audit_log" enable row level security;


  create table "api"."daily_risk_meter" (
    "id" uuid not null default gen_random_uuid(),
    "date" date default CURRENT_DATE,
    "total_risk_usd" numeric default 0,
    "max_risk_allowed" numeric default 5000,
    "active_positions_count" integer default 0,
    "created_at" timestamp without time zone default now()
      );


alter table "api"."daily_risk_meter" enable row level security;


  create table "api"."positions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" text not null,
    "symbol" text not null,
    "entry_price" numeric not null,
    "quantity" numeric not null,
    "current_price" numeric,
    "pnl_percent" numeric,
    "pnl_usd" numeric,
    "status" text default 'open'::text,
    "entry_time" timestamp without time zone default now(),
    "exit_time" timestamp without time zone,
    "signal_id" uuid,
    "created_at" timestamp without time zone default now()
      );


alter table "api"."positions" enable row level security;


  create table "api"."signals" (
    "id" uuid not null default gen_random_uuid(),
    "symbol" text not null,
    "direction" text not null,
    "confidence" numeric default 0.5,
    "reason" text,
    "ai_model" text default 'perplexity-sonar'::text,
    "status" text default 'pending'::text,
    "created_at" timestamp without time zone default now()
      );


alter table "api"."signals" enable row level security;


  create table "api"."system_status" (
    "id" integer not null default 1,
    "trading_enabled" boolean default true,
    "emergency" boolean default false,
    "emergency_reason" text,
    "triggered_at" timestamp with time zone,
    "updated_at" timestamp with time zone default now()
      );


alter table "api"."system_status" enable row level security;


  create table "public"."ai_call_log" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "prompt_tokens" integer,
    "completion_tokens" integer,
    "cost_usd" numeric(10,6),
    "timestamp" timestamp with time zone default now()
      );



  create table "public"."aisignal" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "symbol" text,
    "pair" text,
    "direction" text,
    "signal_type" text,
    "entry_price" numeric,
    "stop_loss" numeric,
    "take_profit" numeric,
    "confidence" numeric,
    "confidence_score" integer,
    "status" text default 'pending'::text,
    "risk_usd" numeric,
    "approved_by" text,
    "approved_at" timestamp with time zone,
    "rejected_by" text,
    "rejected_at" timestamp with time zone,
    "reasoning" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );



  create table "public"."kill_switch_events" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "trigger_reason" text not null,
    "positions_closed" integer,
    "triggered_at" timestamp with time zone default now()
      );



  create table "public"."position_tracking" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "signal_id" uuid,
    "pair" text not null,
    "entry_price" numeric(18,8) not null,
    "status" text default 'OPEN'::text,
    "opened_at" timestamp with time zone default now()
      );



  create table "public"."profiles" (
    "id" uuid not null,
    "email" text,
    "plan" text default 'free'::text,
    "is_paper_trading" boolean default true,
    "stripe_customer_id" text,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now())
      );


alter table "public"."profiles" enable row level security;


  create table "public"."risk_profiles" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "name" text not null,
    "daily_soft_stop_pct" numeric(5,2) not null,
    "daily_hard_stop_pct" numeric(5,2) not null,
    "weekly_soft_stop_pct" numeric(5,2) not null,
    "weekly_hard_stop_pct" numeric(5,2) not null,
    "max_positions" integer not null default 2,
    "risk_per_trade_pct" numeric(5,2) not null default 0.25,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."user_secrets" (
    "user_id" uuid not null,
    "binance_api_key_encrypted" text,
    "binance_api_secret_encrypted" text,
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now())
      );


alter table "public"."user_secrets" enable row level security;


  create table "public"."users" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "email" text not null,
    "tier" text not null,
    "risk_profile_id" uuid,
    "account_equity_usd" numeric(12,2) default 0,
    "created_at" timestamp with time zone default now()
      );


alter sequence "api"."aisignal_id_seq" owned by "api"."aisignal"."id";

alter sequence "api"."audit_log_id_seq" owned by "api"."audit_log"."id";

CREATE UNIQUE INDEX ai_calls_pkey ON api.ai_calls USING btree (id);

CREATE UNIQUE INDEX aisignal_pkey ON api.aisignal USING btree (id);

CREATE UNIQUE INDEX audit_log_pkey ON api.audit_log USING btree (id);

CREATE UNIQUE INDEX daily_risk_meter_pkey ON api.daily_risk_meter USING btree (id);

CREATE INDEX idx_aisignal_created ON api.aisignal USING btree (created_at DESC);

CREATE INDEX idx_aisignal_status ON api.aisignal USING btree (status);

CREATE INDEX idx_aisignal_symbol ON api.aisignal USING btree (symbol);

CREATE INDEX idx_audit_event_type ON api.audit_log USING btree (event_type);

CREATE INDEX idx_audit_signal ON api.audit_log USING btree (signal_id);

CREATE INDEX idx_audit_timestamp ON api.audit_log USING btree ("timestamp" DESC);

CREATE UNIQUE INDEX positions_pkey ON api.positions USING btree (id);

CREATE UNIQUE INDEX signals_pkey ON api.signals USING btree (id);

CREATE UNIQUE INDEX system_status_pkey ON api.system_status USING btree (id);

CREATE UNIQUE INDEX ai_call_log_pkey ON public.ai_call_log USING btree (id);

CREATE UNIQUE INDEX aisignal_pkey ON public.aisignal USING btree (id);

CREATE INDEX idx_aisignal_created_at ON public.aisignal USING btree (created_at DESC);

CREATE INDEX idx_aisignal_status ON public.aisignal USING btree (status);

CREATE INDEX idx_aisignal_user_id ON public.aisignal USING btree (user_id);

CREATE UNIQUE INDEX kill_switch_events_pkey ON public.kill_switch_events USING btree (id);

CREATE UNIQUE INDEX position_tracking_pkey ON public.position_tracking USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX risk_profiles_name_key ON public.risk_profiles USING btree (name);

CREATE UNIQUE INDEX risk_profiles_pkey ON public.risk_profiles USING btree (id);

CREATE UNIQUE INDEX user_secrets_pkey ON public.user_secrets USING btree (user_id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

alter table "api"."ai_calls" add constraint "ai_calls_pkey" PRIMARY KEY using index "ai_calls_pkey";

alter table "api"."aisignal" add constraint "aisignal_pkey" PRIMARY KEY using index "aisignal_pkey";

alter table "api"."audit_log" add constraint "audit_log_pkey" PRIMARY KEY using index "audit_log_pkey";

alter table "api"."daily_risk_meter" add constraint "daily_risk_meter_pkey" PRIMARY KEY using index "daily_risk_meter_pkey";

alter table "api"."positions" add constraint "positions_pkey" PRIMARY KEY using index "positions_pkey";

alter table "api"."signals" add constraint "signals_pkey" PRIMARY KEY using index "signals_pkey";

alter table "api"."system_status" add constraint "system_status_pkey" PRIMARY KEY using index "system_status_pkey";

alter table "public"."ai_call_log" add constraint "ai_call_log_pkey" PRIMARY KEY using index "ai_call_log_pkey";

alter table "public"."aisignal" add constraint "aisignal_pkey" PRIMARY KEY using index "aisignal_pkey";

alter table "public"."kill_switch_events" add constraint "kill_switch_events_pkey" PRIMARY KEY using index "kill_switch_events_pkey";

alter table "public"."position_tracking" add constraint "position_tracking_pkey" PRIMARY KEY using index "position_tracking_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."risk_profiles" add constraint "risk_profiles_pkey" PRIMARY KEY using index "risk_profiles_pkey";

alter table "public"."user_secrets" add constraint "user_secrets_pkey" PRIMARY KEY using index "user_secrets_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "api"."aisignal" add constraint "aisignal_confidence_check" CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))) not valid;

alter table "api"."aisignal" validate constraint "aisignal_confidence_check";

alter table "api"."aisignal" add constraint "aisignal_direction_check" CHECK ((direction = ANY (ARRAY['long'::text, 'short'::text]))) not valid;

alter table "api"."aisignal" validate constraint "aisignal_direction_check";

alter table "api"."aisignal" add constraint "aisignal_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'closed'::text]))) not valid;

alter table "api"."aisignal" validate constraint "aisignal_status_check";

alter table "api"."audit_log" add constraint "audit_log_signal_id_fkey" FOREIGN KEY (signal_id) REFERENCES api.aisignal(id) not valid;

alter table "api"."audit_log" validate constraint "audit_log_signal_id_fkey";

alter table "api"."system_status" add constraint "single_row" CHECK ((id = 1)) not valid;

alter table "api"."system_status" validate constraint "single_row";

alter table "public"."ai_call_log" add constraint "ai_call_log_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."ai_call_log" validate constraint "ai_call_log_user_id_fkey";

alter table "public"."kill_switch_events" add constraint "kill_switch_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."kill_switch_events" validate constraint "kill_switch_events_user_id_fkey";

alter table "public"."position_tracking" add constraint "position_tracking_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."position_tracking" validate constraint "position_tracking_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."risk_profiles" add constraint "risk_profiles_name_key" UNIQUE using index "risk_profiles_name_key";

alter table "public"."user_secrets" add constraint "user_secrets_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."user_secrets" validate constraint "user_secrets_user_id_fkey";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_risk_profile_id_fkey" FOREIGN KEY (risk_profile_id) REFERENCES public.risk_profiles(id) not valid;

alter table "public"."users" validate constraint "users_risk_profile_id_fkey";

alter table "public"."users" add constraint "users_tier_check" CHECK ((tier = ANY (ARRAY['FREE'::text, 'PRO'::text, 'ELITE'::text]))) not valid;

alter table "public"."users" validate constraint "users_tier_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION api.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$ begin insert into public.profiles (id, email) values (new.id, new.email); return new; end; $function$
;

grant delete on table "api"."ai_calls" to "anon";

grant insert on table "api"."ai_calls" to "anon";

grant references on table "api"."ai_calls" to "anon";

grant select on table "api"."ai_calls" to "anon";

grant trigger on table "api"."ai_calls" to "anon";

grant truncate on table "api"."ai_calls" to "anon";

grant update on table "api"."ai_calls" to "anon";

grant delete on table "api"."ai_calls" to "authenticated";

grant insert on table "api"."ai_calls" to "authenticated";

grant references on table "api"."ai_calls" to "authenticated";

grant select on table "api"."ai_calls" to "authenticated";

grant trigger on table "api"."ai_calls" to "authenticated";

grant truncate on table "api"."ai_calls" to "authenticated";

grant update on table "api"."ai_calls" to "authenticated";

grant delete on table "api"."ai_calls" to "service_role";

grant insert on table "api"."ai_calls" to "service_role";

grant references on table "api"."ai_calls" to "service_role";

grant select on table "api"."ai_calls" to "service_role";

grant trigger on table "api"."ai_calls" to "service_role";

grant truncate on table "api"."ai_calls" to "service_role";

grant update on table "api"."ai_calls" to "service_role";

grant select on table "api"."aisignal" to "anon";

grant select on table "api"."aisignal" to "authenticated";

grant delete on table "api"."aisignal" to "service_role";

grant insert on table "api"."aisignal" to "service_role";

grant select on table "api"."aisignal" to "service_role";

grant update on table "api"."aisignal" to "service_role";

grant select on table "api"."audit_log" to "authenticated";

grant insert on table "api"."audit_log" to "service_role";

grant select on table "api"."audit_log" to "service_role";

grant delete on table "api"."daily_risk_meter" to "anon";

grant insert on table "api"."daily_risk_meter" to "anon";

grant references on table "api"."daily_risk_meter" to "anon";

grant select on table "api"."daily_risk_meter" to "anon";

grant trigger on table "api"."daily_risk_meter" to "anon";

grant truncate on table "api"."daily_risk_meter" to "anon";

grant update on table "api"."daily_risk_meter" to "anon";

grant delete on table "api"."daily_risk_meter" to "authenticated";

grant insert on table "api"."daily_risk_meter" to "authenticated";

grant references on table "api"."daily_risk_meter" to "authenticated";

grant select on table "api"."daily_risk_meter" to "authenticated";

grant trigger on table "api"."daily_risk_meter" to "authenticated";

grant truncate on table "api"."daily_risk_meter" to "authenticated";

grant update on table "api"."daily_risk_meter" to "authenticated";

grant delete on table "api"."daily_risk_meter" to "service_role";

grant insert on table "api"."daily_risk_meter" to "service_role";

grant references on table "api"."daily_risk_meter" to "service_role";

grant select on table "api"."daily_risk_meter" to "service_role";

grant trigger on table "api"."daily_risk_meter" to "service_role";

grant truncate on table "api"."daily_risk_meter" to "service_role";

grant update on table "api"."daily_risk_meter" to "service_role";

grant delete on table "api"."positions" to "anon";

grant insert on table "api"."positions" to "anon";

grant references on table "api"."positions" to "anon";

grant select on table "api"."positions" to "anon";

grant trigger on table "api"."positions" to "anon";

grant truncate on table "api"."positions" to "anon";

grant update on table "api"."positions" to "anon";

grant delete on table "api"."positions" to "authenticated";

grant insert on table "api"."positions" to "authenticated";

grant references on table "api"."positions" to "authenticated";

grant select on table "api"."positions" to "authenticated";

grant trigger on table "api"."positions" to "authenticated";

grant truncate on table "api"."positions" to "authenticated";

grant update on table "api"."positions" to "authenticated";

grant delete on table "api"."positions" to "service_role";

grant insert on table "api"."positions" to "service_role";

grant references on table "api"."positions" to "service_role";

grant select on table "api"."positions" to "service_role";

grant trigger on table "api"."positions" to "service_role";

grant truncate on table "api"."positions" to "service_role";

grant update on table "api"."positions" to "service_role";

grant delete on table "api"."signals" to "anon";

grant insert on table "api"."signals" to "anon";

grant references on table "api"."signals" to "anon";

grant select on table "api"."signals" to "anon";

grant trigger on table "api"."signals" to "anon";

grant truncate on table "api"."signals" to "anon";

grant update on table "api"."signals" to "anon";

grant delete on table "api"."signals" to "authenticated";

grant insert on table "api"."signals" to "authenticated";

grant references on table "api"."signals" to "authenticated";

grant select on table "api"."signals" to "authenticated";

grant trigger on table "api"."signals" to "authenticated";

grant truncate on table "api"."signals" to "authenticated";

grant update on table "api"."signals" to "authenticated";

grant delete on table "api"."signals" to "service_role";

grant insert on table "api"."signals" to "service_role";

grant references on table "api"."signals" to "service_role";

grant select on table "api"."signals" to "service_role";

grant trigger on table "api"."signals" to "service_role";

grant truncate on table "api"."signals" to "service_role";

grant update on table "api"."signals" to "service_role";

grant select on table "api"."system_status" to "anon";

grant select on table "api"."system_status" to "authenticated";

grant select on table "api"."system_status" to "service_role";

grant update on table "api"."system_status" to "service_role";

grant delete on table "public"."ai_call_log" to "anon";

grant insert on table "public"."ai_call_log" to "anon";

grant references on table "public"."ai_call_log" to "anon";

grant select on table "public"."ai_call_log" to "anon";

grant trigger on table "public"."ai_call_log" to "anon";

grant truncate on table "public"."ai_call_log" to "anon";

grant update on table "public"."ai_call_log" to "anon";

grant delete on table "public"."ai_call_log" to "authenticated";

grant insert on table "public"."ai_call_log" to "authenticated";

grant references on table "public"."ai_call_log" to "authenticated";

grant select on table "public"."ai_call_log" to "authenticated";

grant trigger on table "public"."ai_call_log" to "authenticated";

grant truncate on table "public"."ai_call_log" to "authenticated";

grant update on table "public"."ai_call_log" to "authenticated";

grant delete on table "public"."ai_call_log" to "service_role";

grant insert on table "public"."ai_call_log" to "service_role";

grant references on table "public"."ai_call_log" to "service_role";

grant select on table "public"."ai_call_log" to "service_role";

grant trigger on table "public"."ai_call_log" to "service_role";

grant truncate on table "public"."ai_call_log" to "service_role";

grant update on table "public"."ai_call_log" to "service_role";

grant delete on table "public"."aisignal" to "anon";

grant insert on table "public"."aisignal" to "anon";

grant references on table "public"."aisignal" to "anon";

grant select on table "public"."aisignal" to "anon";

grant trigger on table "public"."aisignal" to "anon";

grant truncate on table "public"."aisignal" to "anon";

grant update on table "public"."aisignal" to "anon";

grant delete on table "public"."aisignal" to "authenticated";

grant insert on table "public"."aisignal" to "authenticated";

grant references on table "public"."aisignal" to "authenticated";

grant select on table "public"."aisignal" to "authenticated";

grant trigger on table "public"."aisignal" to "authenticated";

grant truncate on table "public"."aisignal" to "authenticated";

grant update on table "public"."aisignal" to "authenticated";

grant delete on table "public"."aisignal" to "service_role";

grant insert on table "public"."aisignal" to "service_role";

grant references on table "public"."aisignal" to "service_role";

grant select on table "public"."aisignal" to "service_role";

grant trigger on table "public"."aisignal" to "service_role";

grant truncate on table "public"."aisignal" to "service_role";

grant update on table "public"."aisignal" to "service_role";

grant delete on table "public"."kill_switch_events" to "anon";

grant insert on table "public"."kill_switch_events" to "anon";

grant references on table "public"."kill_switch_events" to "anon";

grant select on table "public"."kill_switch_events" to "anon";

grant trigger on table "public"."kill_switch_events" to "anon";

grant truncate on table "public"."kill_switch_events" to "anon";

grant update on table "public"."kill_switch_events" to "anon";

grant delete on table "public"."kill_switch_events" to "authenticated";

grant insert on table "public"."kill_switch_events" to "authenticated";

grant references on table "public"."kill_switch_events" to "authenticated";

grant select on table "public"."kill_switch_events" to "authenticated";

grant trigger on table "public"."kill_switch_events" to "authenticated";

grant truncate on table "public"."kill_switch_events" to "authenticated";

grant update on table "public"."kill_switch_events" to "authenticated";

grant delete on table "public"."kill_switch_events" to "service_role";

grant insert on table "public"."kill_switch_events" to "service_role";

grant references on table "public"."kill_switch_events" to "service_role";

grant select on table "public"."kill_switch_events" to "service_role";

grant trigger on table "public"."kill_switch_events" to "service_role";

grant truncate on table "public"."kill_switch_events" to "service_role";

grant update on table "public"."kill_switch_events" to "service_role";

grant delete on table "public"."position_tracking" to "anon";

grant insert on table "public"."position_tracking" to "anon";

grant references on table "public"."position_tracking" to "anon";

grant select on table "public"."position_tracking" to "anon";

grant trigger on table "public"."position_tracking" to "anon";

grant truncate on table "public"."position_tracking" to "anon";

grant update on table "public"."position_tracking" to "anon";

grant delete on table "public"."position_tracking" to "authenticated";

grant insert on table "public"."position_tracking" to "authenticated";

grant references on table "public"."position_tracking" to "authenticated";

grant select on table "public"."position_tracking" to "authenticated";

grant trigger on table "public"."position_tracking" to "authenticated";

grant truncate on table "public"."position_tracking" to "authenticated";

grant update on table "public"."position_tracking" to "authenticated";

grant delete on table "public"."position_tracking" to "service_role";

grant insert on table "public"."position_tracking" to "service_role";

grant references on table "public"."position_tracking" to "service_role";

grant select on table "public"."position_tracking" to "service_role";

grant trigger on table "public"."position_tracking" to "service_role";

grant truncate on table "public"."position_tracking" to "service_role";

grant update on table "public"."position_tracking" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."risk_profiles" to "anon";

grant insert on table "public"."risk_profiles" to "anon";

grant references on table "public"."risk_profiles" to "anon";

grant select on table "public"."risk_profiles" to "anon";

grant trigger on table "public"."risk_profiles" to "anon";

grant truncate on table "public"."risk_profiles" to "anon";

grant update on table "public"."risk_profiles" to "anon";

grant delete on table "public"."risk_profiles" to "authenticated";

grant insert on table "public"."risk_profiles" to "authenticated";

grant references on table "public"."risk_profiles" to "authenticated";

grant select on table "public"."risk_profiles" to "authenticated";

grant trigger on table "public"."risk_profiles" to "authenticated";

grant truncate on table "public"."risk_profiles" to "authenticated";

grant update on table "public"."risk_profiles" to "authenticated";

grant delete on table "public"."risk_profiles" to "service_role";

grant insert on table "public"."risk_profiles" to "service_role";

grant references on table "public"."risk_profiles" to "service_role";

grant select on table "public"."risk_profiles" to "service_role";

grant trigger on table "public"."risk_profiles" to "service_role";

grant truncate on table "public"."risk_profiles" to "service_role";

grant update on table "public"."risk_profiles" to "service_role";

grant delete on table "public"."user_secrets" to "anon";

grant insert on table "public"."user_secrets" to "anon";

grant references on table "public"."user_secrets" to "anon";

grant select on table "public"."user_secrets" to "anon";

grant trigger on table "public"."user_secrets" to "anon";

grant truncate on table "public"."user_secrets" to "anon";

grant update on table "public"."user_secrets" to "anon";

grant delete on table "public"."user_secrets" to "authenticated";

grant insert on table "public"."user_secrets" to "authenticated";

grant references on table "public"."user_secrets" to "authenticated";

grant select on table "public"."user_secrets" to "authenticated";

grant trigger on table "public"."user_secrets" to "authenticated";

grant truncate on table "public"."user_secrets" to "authenticated";

grant update on table "public"."user_secrets" to "authenticated";

grant delete on table "public"."user_secrets" to "service_role";

grant insert on table "public"."user_secrets" to "service_role";

grant references on table "public"."user_secrets" to "service_role";

grant select on table "public"."user_secrets" to "service_role";

grant trigger on table "public"."user_secrets" to "service_role";

grant truncate on table "public"."user_secrets" to "service_role";

grant update on table "public"."user_secrets" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


  create policy "auth_write_ai"
  on "api"."ai_calls"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "public_read_ai"
  on "api"."ai_calls"
  as permissive
  for select
  to public
using (true);



  create policy "anon_read_approved_signals"
  on "api"."aisignal"
  as permissive
  for select
  to anon
using ((status = 'approved'::text));



  create policy "authenticated_read_all_signals"
  on "api"."aisignal"
  as permissive
  for select
  to authenticated
using (true);



  create policy "authenticated_read_audit_logs"
  on "api"."audit_log"
  as permissive
  for select
  to authenticated
using (true);



  create policy "auth_write_risk"
  on "api"."daily_risk_meter"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "public_read_risk"
  on "api"."daily_risk_meter"
  as permissive
  for select
  to public
using (true);



  create policy "auth_write_positions"
  on "api"."positions"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "public_read_positions"
  on "api"."positions"
  as permissive
  for select
  to public
using (true);



  create policy "auth_write_signals"
  on "api"."signals"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "public_read_signals"
  on "api"."signals"
  as permissive
  for select
  to public
using (true);



  create policy "public_read_system_status"
  on "api"."system_status"
  as permissive
  for select
  to anon, authenticated
using (true);



  create policy "Public read risk"
  on "public"."daily_risk_meter"
  as permissive
  for select
  to public
using (true);



  create policy "Service risk"
  on "public"."daily_risk_meter"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text));



  create policy "Public read positions"
  on "public"."positions"
  as permissive
  for select
  to public
using (true);



  create policy "Service positions"
  on "public"."positions"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text));



  create policy "Users manage own profile"
  on "public"."profiles"
  as permissive
  for all
  to public
using ((auth.uid() = id));



  create policy "Public read signals"
  on "public"."signals"
  as permissive
  for select
  to public
using (true);



  create policy "Service signals"
  on "public"."signals"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text))
with check ((auth.role() = 'service_role'::text));



  create policy "Users manage own secrets"
  on "public"."user_secrets"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));


CREATE TRIGGER update_aisignal_updated_at BEFORE UPDATE ON api.aisignal FOR EACH ROW EXECUTE FUNCTION api.update_updated_at();

CREATE TRIGGER update_system_status_updated_at BEFORE UPDATE ON api.system_status FOR EACH ROW EXECUTE FUNCTION api.update_updated_at();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


