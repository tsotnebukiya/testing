SELECT
  (SELECT count(*) FROM public."user")              AS users,
  (SELECT count(*) FROM public.region)              AS regions,
  (SELECT count(*) FROM public.control_definition)  AS controls,
  (SELECT count(*) FROM public.nfr_definition)      AS nfrs,
  (SELECT count(*) FROM public.digital_property)    AS digital_properties,
  (SELECT count(*) FROM public.control_task)        AS control_tasks,
  (SELECT count(*) FROM public.nfr_task)            AS nfr_tasks;
