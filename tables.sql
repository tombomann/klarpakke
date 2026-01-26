


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."ai_call_log" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "prompt_tokens" integer,
    "completion_tokens" integer,
    "cost_usd" numeric(10,6),
    "timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."ai_call_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."aisignal" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "symbol" "text",
    "pair" "text",
    "direction" "text",
    "signal_type" "text",
    "entry_price" numeric,
    "stop_loss" numeric,
    "take_profit" numeric,
    "confidence" numeric,
    "confidence_score" integer,
    "status" "text" DEFAULT 'pending'::"text",
    "risk_usd" numeric,
    "approved_by" "text",
    "approved_at" timestamp with time zone,
    "rejected_by" "text",
    "rejected_at" timestamp with time zone,
    "reasoning" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."aisignal" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kill_switch_events" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "trigger_reason" "text" NOT NULL,
    "positions_closed" integer,
    "triggered_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."kill_switch_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."position_tracking" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "signal_id" "uuid",
    "pair" "text" NOT NULL,
    "entry_price" numeric(18,8) NOT NULL,
    "status" "text" DEFAULT 'OPEN'::"text",
    "opened_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."position_tracking" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."risk_profiles" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "daily_soft_stop_pct" numeric(5,2) NOT NULL,
    "daily_hard_stop_pct" numeric(5,2) NOT NULL,
    "weekly_soft_stop_pct" numeric(5,2) NOT NULL,
    "weekly_hard_stop_pct" numeric(5,2) NOT NULL,
    "max_positions" integer DEFAULT 2 NOT NULL,
    "risk_per_trade_pct" numeric(5,2) DEFAULT 0.25 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."risk_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "email" "text" NOT NULL,
    "tier" "text" NOT NULL,
    "risk_profile_id" "uuid",
    "account_equity_usd" numeric(12,2) DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "users_tier_check" CHECK (("tier" = ANY (ARRAY['FREE'::"text", 'PRO'::"text", 'ELITE'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."ai_call_log"
    ADD CONSTRAINT "ai_call_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."aisignal"
    ADD CONSTRAINT "aisignal_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kill_switch_events"
    ADD CONSTRAINT "kill_switch_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."position_tracking"
    ADD CONSTRAINT "position_tracking_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."risk_profiles"
    ADD CONSTRAINT "risk_profiles_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."risk_profiles"
    ADD CONSTRAINT "risk_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_aisignal_created_at" ON "public"."aisignal" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_aisignal_status" ON "public"."aisignal" USING "btree" ("status");



CREATE INDEX "idx_aisignal_user_id" ON "public"."aisignal" USING "btree" ("user_id");



ALTER TABLE ONLY "public"."ai_call_log"
    ADD CONSTRAINT "ai_call_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."kill_switch_events"
    ADD CONSTRAINT "kill_switch_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."position_tracking"
    ADD CONSTRAINT "position_tracking_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_risk_profile_id_fkey" FOREIGN KEY ("risk_profile_id") REFERENCES "public"."risk_profiles"("id");



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON TABLE "public"."ai_call_log" TO "anon";
GRANT ALL ON TABLE "public"."ai_call_log" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_call_log" TO "service_role";



GRANT ALL ON TABLE "public"."aisignal" TO "anon";
GRANT ALL ON TABLE "public"."aisignal" TO "authenticated";
GRANT ALL ON TABLE "public"."aisignal" TO "service_role";



GRANT ALL ON TABLE "public"."kill_switch_events" TO "anon";
GRANT ALL ON TABLE "public"."kill_switch_events" TO "authenticated";
GRANT ALL ON TABLE "public"."kill_switch_events" TO "service_role";



GRANT ALL ON TABLE "public"."position_tracking" TO "anon";
GRANT ALL ON TABLE "public"."position_tracking" TO "authenticated";
GRANT ALL ON TABLE "public"."position_tracking" TO "service_role";



GRANT ALL ON TABLE "public"."risk_profiles" TO "anon";
GRANT ALL ON TABLE "public"."risk_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."risk_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







