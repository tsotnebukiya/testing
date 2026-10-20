UPDATE public._prisma_migrations
SET rolled_back_at = now()
WHERE migration_name = '20261015120000_simplify_website_platforms'
  AND finished_at IS NULL AND rolled_back_at IS NULL;
