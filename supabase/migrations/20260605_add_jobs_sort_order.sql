-- Add manual sort order for kanban columns

ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id, status ORDER BY created_at ASC) - 1 AS rn
  FROM public.jobs
)
UPDATE public.jobs j
SET sort_order = ranked.rn
FROM ranked
WHERE j.id = ranked.id;

CREATE INDEX IF NOT EXISTS idx_jobs_user_status_sort
  ON public.jobs(user_id, status, sort_order);
