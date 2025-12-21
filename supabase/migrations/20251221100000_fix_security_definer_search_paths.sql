-- Fix all SECURITY DEFINER functions to include search_path
-- This prevents issues when functions are called from auth context or edge functions
--
-- Problem: SECURITY DEFINER functions without search_path set can fail
-- when called from auth context (triggers on auth.users) or edge functions
-- because the search_path doesn't include 'public' by default.
--
-- Solution: Add SET search_path TO 'public' to all SECURITY DEFINER functions

DO $$
DECLARE
    func_record RECORD;
    updated_count INTEGER := 0;
    failed_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting search_path fix for SECURITY DEFINER functions...';

    FOR func_record IN
        SELECT
            p.proname AS function_name,
            pg_get_function_identity_arguments(p.oid) AS args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.prosecdef = true
          AND (p.proconfig IS NULL OR NOT 'search_path=public' = ANY(p.proconfig))
    LOOP
        BEGIN
            EXECUTE format(
                'ALTER FUNCTION public.%I(%s) SET search_path TO ''public''',
                func_record.function_name,
                func_record.args
            );
            updated_count := updated_count + 1;
            RAISE NOTICE 'Updated: public.%(%)', func_record.function_name, func_record.args;
        EXCEPTION WHEN OTHERS THEN
            failed_count := failed_count + 1;
            RAISE WARNING 'Failed to update public.%: %', func_record.function_name, SQLERRM;
        END;
    END LOOP;

    RAISE NOTICE 'Completed: % functions updated, % failed', updated_count, failed_count;
END;
$$;
