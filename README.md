# staylatin-api

Backend for StayLatin: traveler accounts, saved stays and guest reviews, stored in Supabase.

## Database

Migrations live in `supabase/migrations/`. `0001_initial_schema.sql` creates `profiles`, `saved_stays` and `reviews`, with row-level security so travelers only see their own data and only approved reviews are public.
