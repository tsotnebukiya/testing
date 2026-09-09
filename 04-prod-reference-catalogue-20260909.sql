-- DPR PROD reference data and V1 library only, prepared 9 September 2026.
-- Source: DPR-298/uat-readiness 7255198a; catalogue/schema match release v0.4.0.
-- Verify PROD host in pgAdmin: psql-eu01pwebcustomap.postgres.database.azure.com
-- Expected database: digitalproperty_db; database role: dpr_app_puser_01.
-- Import attribution resolves the EXISTING admin tsotne.bukiya@opella.com.
-- 8 regions, 71 countries, 90 brands, 42 Controls, 52 NFRs, 188 import audits.
-- Includes brand-country links and initial V1 definition versions.
-- No users, roles, agencies, Digital Properties, tasks, notifications or reset.
-- Existing audit history is preserved. Run the WHOLE file after PROD migrations.
-- If any statement fails, run ROLLBACK; and inspect the error before retrying.
BEGIN;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '120s';
SET LOCAL search_path = public;
DO $dpr_prod_preflight$
DECLARE
  actor_id text;
  actor_count integer;
BEGIN
  IF current_database() <> 'digitalproperty_db'
     OR current_user <> 'dpr_app_puser_01'
     OR session_user <> 'dpr_app_puser_01' THEN
    RAISE EXCEPTION 'Wrong PROD target: database=%, user=%, session_user=%',
      current_database(), current_user, session_user;
  END IF;
  LOCK TABLE public._prisma_migrations IN SHARE MODE;
  IF EXISTS (SELECT 1 FROM public._prisma_migrations
             WHERE finished_at IS NULL AND rolled_back_at IS NULL)
     OR NOT EXISTS (SELECT 1 FROM public._prisma_migrations
             WHERE migration_name = '20260908180000_expand_control_reviewer_teams'
               AND finished_at IS NOT NULL AND rolled_back_at IS NULL) THEN
    RAISE EXCEPTION 'PROD migrations are incomplete; nothing imported';
  END IF;
  LOCK TABLE public."user", public.user_role IN SHARE MODE;
  SELECT count(*), min(u.id) INTO actor_count, actor_id
  FROM public."user" u JOIN public.user_role ur ON ur.user_id = u.id
  WHERE lower(u.email) = 'tsotne.bukiya@opella.com' AND ur.role = 'DPR_ADMIN';
  IF actor_count <> 1 THEN
    RAISE EXCEPTION 'Expected exactly one existing DPR Admin for tsotne.bukiya@opella.com';
  END IF;
  PERFORM set_config('dpr.catalogue_actor_user_id', actor_id, true);
  LOCK TABLE public.region, public.country, public.brand,
    public.brand_country_availability, public.control_definition,
    public.control_definition_version, public.nfr_definition,
    public.nfr_definition_version, public.audit_event IN SHARE ROW EXCLUSIVE MODE;
  IF EXISTS (SELECT 1 FROM public.region)
     OR EXISTS (SELECT 1 FROM public.country)
     OR EXISTS (SELECT 1 FROM public.brand)
     OR EXISTS (SELECT 1 FROM public.brand_country_availability)
     OR EXISTS (SELECT 1 FROM public.control_definition)
     OR EXISTS (SELECT 1 FROM public.control_definition_version)
     OR EXISTS (SELECT 1 FROM public.nfr_definition)
     OR EXISTS (SELECT 1 FROM public.nfr_definition_version) THEN
    RAISE EXCEPTION 'PROD reference/library target is not empty; existing data preserved';
  END IF;
  PERFORM set_config('dpr.catalogue_audit_count_before',
    (SELECT count(*)::text FROM public.audit_event), true);
END
$dpr_prod_preflight$;

--
-- PostgreSQL database dump
--


-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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

--
-- Data for Name: audit_event; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.audit_event (id, action, entity_type, entity_id, actor_user_id, target_user_id, reason, details, created_at, actor_type) VALUES
	('3df3df84-4b1b-4213-a842-281e33596a65', 'CREATED', 'CONTROL_DEFINITION', 'e200352e-0c7e-44a8-99d9-ee26022158eb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "ACCESS-02_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c6c708db-9f58-4124-b345-9b1c718bf6f9', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'c3325357-be7f-44c0-8dff-738d61d652ec', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_ACCESS", "objective": "Activities performed by IT members with privileged accesses must be reviewed :\n- For GxP regulated digital solution, the review of activities must be covered as applicable by the audit trail review\n- For SOX & CSRD regulated digital solution, activities of IT accounts with extended rights (e.g. Firefighters, Privileged accounts) which can have impacts on SOX/CSRD data must be reviewed and documented at least annually.", "ownerTeam": "CYBER_SECURITY", "statement": "Activities Review for privileged accesses", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "e200352e-0c7e-44a8-99d9-ee26022158eb", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. GQCMS-QU-STD-0000452-User Access Management Controls: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/867621\n2. DFC-QU-STD-0000298-Access Control: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/581828\n3. DIG-CO-SOP-0015241-SAP Security Baseline: https://opella-connect.veevavault.com/ui/#permalink=V190000000JN001\n4. DFC-QU-SOP-0087024-Business Application Access Management: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/738198", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "* Audit trail review record/report for GxP-regulated digital solutions, covering activities performed under privileged access\n* Documented review log for SOX/CSRD-regulated solutions, covering extended-rights accounts (e.g. Firefighter, Privileged accounts), performed and evidenced at least annually* Reviewer sign-off/approval confirming the review was completed (name, date, scope covered)\n* Record of any anomalies or inappropriate activity identified during the review, with follow-up/remediation evidence\n* List of in-scope privileged/extended-rights accounts at the time of review, to confirm completeness of coverage", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n \n -Is a review of activities performed with IT privileged accesses conducted and documented for GxP, SOX and CSRD digital solutions?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('916ea2b6-9f0b-4ea0-a127-bfebd872fa7f', 'CREATED', 'CONTROL_DEFINITION', 'ffda744c-fb35-4f8d-aec4-d1b6432f3df5', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "B&R-01_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('5a37294a-a4da-4fa2-a2ef-579fe7a4a72a', 'CREATED', 'CONTROL_DEFINITION_VERSION', '8d0cbb09-c6b9-432b-a7be-37fc71377920', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "DEPLOY", "itProcess": "MANAGE_CONTINUITY", "objective": "Digital solutions must have backup implemented (scheduled, executed and monitored) to meet business needs.", "ownerTeam": "CYBER_SECURITY", "statement": "Backup implementation", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "ffda744c-fb35-4f8d-aec4-d1b6432f3df5", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DFC-QU-SOP-0086073-Backup and Restore - Infrastructure: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/477883", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Backup requirements describing all the components to be backed up with the required SLA documented and implemented with effective monitoring in place.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nBack-up set up:\n- Is backup specification documented for the digital solution using the backup specification template?\n- Is the backup configured?\n\nMonitoring and logs:\n- Is the backup monitoring effective and are failures captured?\n- Are the logs traceable and retained for ≥ 6 months?\n\n- For digital solution hosted externally, are back up requirements covered in the contractual clauses with the Third Party?", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a6d14b0d-56d2-4333-8b5a-4251d85425b3', 'CREATED', 'CONTROL_DEFINITION', '43625c0a-b585-4b1a-b2b3-e456187f8965', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "BC-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3303269e-0e22-4a04-ad1e-19ed430f4497', 'CREATED', 'CONTROL_DEFINITION_VERSION', '5faccb24-f44e-41c6-904d-87f701c3d059', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "A business continuity management process must be defined (e.g., Business Continuity Plan) at business process level with adequate measures established and tested (including Disaster Recovery strategy activation if applicable) to ensure business operations during digital solution’s unavailability (e.g., disasters). This process must be maintained and regularly reviewed to ensure its effectiveness and accuracy.", "ownerTeam": "CYBER_SECURITY", "statement": "Business Continuity", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "43625c0a-b585-4b1a-b2b3-e456187f8965", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009\n2. QUA-CO-OPE-0093984-Business Continuity Plan for GxP Computerized Systems: https://opella-connect.veevavault.com/ui/#permalink=V190000000EQ023", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Actionable business continuity plan describing how the business activities will be executed in case of digital solution''s unavailability.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Is a Business Continuity Plan (BCP) defined at the business process level for this digital solution?\n* Does the BCP describe adequate measure to sustain business activities during the solutions'' unavailability (e.g. manual workarounds, alternate processes)?\n* For applicable solutions: does the BCP include Disaster Recovery strategy activation steps?\n* Is the BCP reviewed and updated on a regular cadence to ensure it remains accurate and effective (e.g. after solution changes, org changes, or prior test findings)?\n* Is the BCP readily accessible to the people who would need to execute it during an actual disruption?\n* Any digital solution without a maintained, tested BCP - or with a BCP that hasn''t been reviewed within its required cycle - should be treated as non-complaint.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('06b2762f-4355-4142-b60c-c143fd08ed8c', 'CREATED', 'CONTROL_DEFINITION', 'da8a52ab-2fc3-4f99-8728-62c2ffef289f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "BC-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('87e373b6-029a-41e7-a682-e589a9f76787', 'CREATED', 'CONTROL_DEFINITION_VERSION', '5c7dbc4f-a71c-4df8-9699-5fc60b7455e6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "Ensure business continuity can be maintained when the digital solution becomes unavailable.", "ownerTeam": "CYBER_SECURITY", "statement": "Alternate Procedures and Continuity Measures", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "da8a52ab-2fc3-4f99-8728-62c2ffef289f", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard\nSECU-CO-MAN-0000101-Business Continuity Management Policy", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Documented alternate procedures\nBusiness Continuity Plan\nWork instructions\nTraining material\nExercise or test results\nEvidence of periodic review and update\nCorrective actions arising from continuity exercises", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nDocumentation\nAre alternative procedures documented for the affected business activities?\nAre the procedures sufficiently detailed for users to execute them without relying on undocumented knowledge?\nAre roles and responsibilities clearly defined?\nAvailability\nAre the documented procedures available to the personnel who would need to execute them during a disruption?\nCan the procedures be accessed if the digital solution is unavailable?\nTraining\nHave relevant personnel been trained on the alternative procedures?\nIs training evidence available?\nTesting\nHave the alternative procedures been exercised, tested, or used in practice?\nWere the exercises documented?\nWere lessons learned captured?\nMaintenance\nHave the procedures been reviewed within the defined review cycle?\nHave changes in processes, systems, suppliers, or organization been reflected in the procedures?\nEffectiveness\nWould the alternative procedures allow the business activity to continue for the expected disruption period?\nAre there significant manual dependencies or bottlenecks that could prevent successful execution?\nWere any issues identified during testing remediated and tracked to closure?\n\nNon-Compliance Indicators\n\nThe control should be considered non-compliant when:\n\nNo alternative procedure exists.\nProcedures are undocumented.\nProcedures have never been tested.\nPersonnel are unaware of the procedures.\nProcedures are outdated or no longer applicable.\nSignificant deficiencies identified during testing remain unresolved.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('331ac2b8-eacf-4c26-a4be-012382a225bc', 'CREATED', 'CONTROL_DEFINITION', '39730620-298d-47f0-a3a6-07c807e251b3', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "RES-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('33c77d56-bb21-426c-b1ed-1f9af5e761e6', 'CREATED', 'CONTROL_DEFINITION', '865139a5-726a-4402-a3ac-eceaf051bf86', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-04", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('aae7e99e-1673-4b61-bde8-6b384ce32528', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'f567134d-070e-4b4c-9e43-41d17dbb97b7', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "Vital digital solutions shall demonstrate through testing and documented evidence that recovery can be completed within the approved Recovery Time Objective.", "ownerTeam": "CYBER_SECURITY", "statement": "Recovery Time Objective Demonstration", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "39730620-298d-47f0-a3a6-07c807e251b3", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard\nSECU-CO-MAN-0000101-Business Continuity Management Policy", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Recovery exercise\nRecovery exercise report\nRecovery timings documented: Start time, End time, Measured RTO\nData recovery validated\nDeviations documented and remediated", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\nRecovery Performance\nHas recovery been timed?\nWas recovery completed within the approved RTO (Platinum RTO ≤2; Gold RTO ≤ 4 hours)?\nWas the approved RPO achieved (≤ 15 mins)?\nWere all critical services, data and integrations restored?\nWere all critical services restored?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b251013e-e175-49de-ab34-37c43797ed65', 'CREATED', 'CONTROL_DEFINITION', '752438e6-14b0-46e0-83f1-980f8de92c5b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "RES-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3f647d3c-493d-4d88-87ae-26913441b23b', 'CREATED', 'CONTROL_DEFINITION_VERSION', '41719211-e676-4118-a1b4-cb8cdc547d62', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "Dependencies required for recovery shall be identified, documented, and included in recovery procedures and testing activities.", "ownerTeam": "CYBER_SECURITY", "statement": "Critical Dependency Identification and Recovery Sequencing", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "752438e6-14b0-46e0-83f1-980f8de92c5b", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard\nSECU-CO-MAN-0000101-Business Continuity Management Policy", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Dependency map\nRecovery sequence\nArchitecture documentation", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nDependency Identification\nHave all business, technical, infrastructure, security, data, identity, network, integration, and third-party dependencies required for operation and recovery of the digital solution been identified?\nAre dependencies documented in architecture diagrams, recovery procedures, or dependency inventories?\nDoes the dependency inventory include both internal and external services?\nSingle Points of Failure\nHave potential single points of failure been identified and assessed?\nHave mitigation measures been implemented, documented, or formally accepted through risk management processes?\nRecovery Sequence\nIs the recovery sequence documented?\nDoes the recovery sequence identify which systems, services, databases, integrations, and infrastructure components must be recovered first?\nIs the recovery order consistent with the documented recovery procedures?\nRecovery Objectives\nAre dependency recovery objectives aligned with the digital solution''s Recovery Time Objective (RTO) and Recovery Point Objective (RPO)?\nCould any dependency prevent achievement of the approved recovery objectives?\nThird-Party Dependencies\nFor externally provided services, are supplier recovery responsibilities documented?\nHas the supplier demonstrated recovery capability through testing, assurance reports, or contractual commitments?\nEvidence Quality\nIs there evidence that dependency information has been reviewed and updated following significant architecture, supplier, or infrastructure changes?\nNon-Compliance Indicators\n\nThe control should be considered non-compliant if:\n\nCritical dependencies are unknown or undocumented.\nRecovery sequencing is not defined.\nDependency recovery objectives exceed the solution''s approved RTO or RPO.\nSingle points of failure have not been assessed.\nRecovery relies on undocumented supplier capabilities.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e334d341-9cbc-4cd5-aa23-e8a8ae637936', 'CREATED', 'CONTROL_DEFINITION', 'b609db82-c28e-4a50-ad00-89eca8327616', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "RES-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('77aaf99a-6618-452f-ac29-90e96391e335', 'CREATED', 'CONTROL_DEFINITION_VERSION', '2b4e68bd-2ea7-4232-b135-dc44db5e2d70', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "Ensure recovery objectives and recovery capabilities are defined, implemented, tested, and aligned with the assigned Recovery Tier and Business Criticality classification of the digital solution.", "ownerTeam": "CYBER_SECURITY", "statement": "Vital Application Recovery Readiness Review", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "b609db82-c28e-4a50-ad00-89eca8327616", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard\nSECU-CO-MAN-0000101-Business Continuity Management Policy", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Annual review report\nAction tracking\nUpdated DR documentation", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\nRecovery Asset Protection\nAre recovery assets identified and documented?\nDo recovery assets include backups, configurations, infrastructure definitions, application components, scripts, documentation, recovery credentials, and recovery environments where applicable?\nAre recovery assets protected from unauthorized modification or deletion?\nRecovery Environment\nIs a recovery environment available and documented?\nCan recovery activities be executed independently from a compromised production environment?\nAre recovery procedures clearly documented?\nRecovery Credentials\nAre recovery accounts and credentials protected and managed appropriately?\nCan recovery activities still be performed if production privileged accounts are unavailable or compromised?\nRecovery Integrity\nAre processes defined to verify the integrity and validity of recovered systems, data, and configurations?\nDoes the recovery process include validation activities before restored services are returned to operation?\nTesting and Validation\nHas the recovery design been tested?\nDo test results demonstrate successful recovery of the required components?\nWere recovery issues identified during testing tracked and remediated?\nRecovery Objective Achievement\nDoes available evidence demonstrate that the cyber recovery design can support the approved Recovery Time Objective (RTO) and Recovery Point Objective (RPO)?\nFor Vital applications, does the design demonstrate capability to support Platinum recovery requirements?\nThird-Party Recovery\nFor externally hosted or supplier-supported solutions, has evidence been reviewed demonstrating the supplier''s ability to support recovery requirements?\nAre responsibilities clearly documented through a Shared Responsibility Model?\n\nCompliance Indicators\nPass\nRecovery Tier assigned.\nRTO and RPO defined.\nRecovery capability documented.\nRecovery capability tested or validated.\nNo material open recovery gaps.\n\nConditional Pass\nRecovery capability exists.\nMinor documentation, testing, or remediation gaps remain.\nDefined action plan exists.\n\nFail\nRecovery Tier not assigned.\nRecovery objectives undefined.\nRecovery capability not documented.\nNo evidence of recovery validation.\nMaterial recovery gaps remain unmanaged.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('86e20ac7-eebc-4344-8af5-2c8f3d2a8154', 'CREATED', 'CONTROL_DEFINITION', '5843c09a-3dfe-41c3-87ef-5d677f72dfe6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "RES-04", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ff93ebf4-d926-4e52-929c-583a04ed5058', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'f4c19bbc-3b83-4822-9aaf-3f5284fabccc', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_CONTINUITY", "objective": "Ensure the digital solution can demonstrably recover within approved recovery objectives and that recovery capabilities remain effective throughout the solution lifecycle.", "ownerTeam": "CYBER_SECURITY", "statement": "Recovery Objective Validation", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "5843c09a-3dfe-41c3-87ef-5d677f72dfe6", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard\nSECU-CO-MAN-0000101-Business Continuity Management Policy", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Recovery test reports\nDisaster Recovery exercise reports\nMeasured recovery duration\nMeasured data recovery point\nRecovery validation evidence\nRecovery improvement actions\nTest result approvals\nSupplier recovery testing evidence (where applicable)", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nRecovery Testing\nHas a recovery exercise been performed?\nWas the recovery exercise completed using documented recovery procedures?\nWas the exercise representative of the recovery scenario being evaluated?\nRecovery Time Objective (RTO)\nWas the actual recovery duration measured?\nDid the digital solution achieve the approved Recovery Time Objective?\nIf the approved RTO was not achieved, was a remediation plan documented?\nRecovery Point Objective (RPO)\nWas the actual data recovery point measured?\nDid the digital solution achieve the approved Recovery Point Objective?\nWas any data loss within the approved tolerance?\nRecovery Scope\nWere all critical solution components recovered?\nWere critical data, configurations, interfaces, integrations, and supporting services included in the recovery validation?\nWere dependencies recovered and operational?\nBusiness Validation\nWas business functionality validated following recovery?\nWere business users involved where appropriate?\nWas the recovered solution demonstrated to be fit for use?\nRemediation and Continuous Improvement\nWere recovery issues, delays, or failures documented?\nWere corrective actions assigned and tracked?\nHas evidence of remediation been reviewed when required?\nThird-Party Recovery\n\nFor supplier-supported solutions:\n\nHas supplier recovery evidence been reviewed?\nHas the supplier demonstrated recovery capability consistent with contractual commitments?\nAre supplier recovery responsibilities clearly documented?\nNon-Compliance Indicators\n\nThis control should be considered non-compliant if:\n\nRecovery exercises have not been performed.\nRecovery objectives cannot be demonstrated.\nRecovery time was not measured.\nRecovery point was not measured.\nRecovery exceeded approved objectives without remediation.\nCritical components were not included in testing.\nRecovery evidence is unavailable.\nSupplier recovery capabilities cannot be demonstrated where applicable.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6a1b8f84-9adc-410f-a518-6b08625bb71e', 'CREATED', 'CONTROL_DEFINITION', '2b3668f2-14c9-4ffe-9bb2-173d2983d07b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DP-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('93360714-096a-4f83-87e8-659dee4c6109', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'd66cd55a-434b-4b56-b8f2-ecddd0d22928', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "PLAN", "itProcess": "MANAGE_RISK", "objective": "The  the digital solution must undergo a privacy Data Asset Assessment (DAA) to evaluate compliance with privacy requirements.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "Execute Personal Data Privacy Assessment", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "2b3668f2-14c9-4ffe-9bb2-173d2983d07b", "reviewerTeam": "DATA_PRIVACY", "sourceOfTruth": "1. EBI-CO-STD-0000410-Opella Data Privacy Standard (v1.0)\nhttps://opella-connect.veevavault.com/ui/#permalink=V190000000KB037\n\n2. Privacy Hub\nhttps://sanofi.sharepoint.com/sites/opella-compliance-site/SitePages/Work-with-personal-data-v1.0.aspx?CT=1736934649051&OR=OWA-NT-Mail&CID=47d9fdb6-098e-ddca-947b-ad4f41eab8f3", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Personal Data Privacy Assessment documented in OneTrust.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "1. The digital solution is inventoried as \"digital asset\" in the Opella Privacy Care (One Trust) asset inventory\n2. A Digital Asset Assessment exists and it is either in status \"Completed\" or \"Completed with open risks\"\n3. If the Digital Asset Assessment is \"completed with open risks\", all the risks must be in a status different from \"Ongoing mitigation\" (Avoided, Reduced, Accepted, Expired or Materialized)", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('dd65f41d-4d61-4862-9221-1f8a958ac1e3', 'CREATED', 'CONTROL_DEFINITION', '181f3c6d-f4d8-4582-ba3e-990a25de96f3', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DP-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f2767e67-4e76-433a-b700-b5752266ca9b', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'fa410512-c11f-4cb0-b07d-387a9f249424', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "PLAN", "itProcess": "MANAGE_RISK", "objective": "The owner of the digital solution must self attest compliance with a list of requirements, depending on the type of the digital solution", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "Complete Privacy Compliance Declaratoin", "triggerRule": null, "definitionId": "181f3c6d-f4d8-4582-ba3e-990a25de96f3", "reviewerTeam": "DATA_PRIVACY", "sourceOfTruth": "1. EBI-CO-STD-0000410-Opella Data Privacy Standard (v1.0)\nhttps://opella-connect.veevavault.com/ui/#permalink=V190000000KB037\n\n2. Privacy Hub\nhttps://sanofi.sharepoint.com/sites/opella-compliance-site/SitePages/Work-with-personal-data-v1.0.aspx?CT=1736934649051&OR=OWA-NT-Mail&CID=47d9fdb6-098e-ddca-947b-ad4f41eab8f4", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "Privacy Compliance declaration in the risk profiling tool", "applicabilityType": "ALWAYS", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "The owner of the Digital Property must self-attest compliance with certain requirements depending on the digital property type, as a mandatory pre-condition for go-live approval\n\nFor all Digital Solutions, this will be captured in OneTrust when the Digital Assessment is performed.", "autoAttestationRule": null, "assessmentTemplateKey": "DATA_PRIVACY_SELF_ASSESSMENT_V1", "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ab600cdd-2048-4f8c-9e2c-bb061b5bad48', 'CREATED', 'CONTROL_DEFINITION', 'f050e6d6-32ac-4749-b217-7b079e739ea4', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('9a8390d1-5410-4668-b91f-95da9c40b6a9', 'CREATED', 'CONTROL_DEFINITION', 'f59a8266-784b-48e9-a903-d228e39fc23e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SUP-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('40a56892-b17b-41fd-ba7e-7e536dcd9e16', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'b2e48e71-45b0-453f-a0e5-b256fcbafd10', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The digital solution must have a defined set of requirements that describe the functional (i.e., business-process related) and non-functional (e.g., Audit Trail, Electronic Record, Electronic Signature, Data Privacy, Cybersecurity) needs to satisfy the business. All requirements must be specific, measurable, achievable, realistic and testable (SMART).", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Gather Requirements", "triggerRule": null, "definitionId": "f050e6d6-32ac-4749-b217-7b079e739ea4", "reviewerTeam": "PRODUCT_PROJECT_DELIVERY", "sourceOfTruth": "DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "The requirements the digital solution must meet, including the list of requirements supporting the business process, as well as the applicable non functional requirements.\nE.g.: Epic and user stories in Jira, Requirements in HP ALM, Requirement document in Connect CMS...", "applicabilityType": "ALWAYS", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Are both functional (business-process related) and non-functional requirements (e.g. Audit Trail, Electronic Record, Electronic Signature, Data Privacy, Cybersecurity) documented for the digital solution?\n* Is each requirement specific, measurable, achievable, realistic, and testable (SMART)?\n* Are requirements captured and traceable in the appropriate tool for the solution (e.g. Epics/user stories in JIRA, requirements in HP ALM, requirement document in Connect CMS)?\n* Is there evidence requirements were reviewed/approved by the appropriate business and IT stakeholders before design/build began?\n* Are requirements complete relative to the business process being supported, with no material gaps identified later in the lifecycle?\n* Any digital solution where requirements are missing, non-SMART, or not traceable to a recognized system of record should be treated as noncompliant", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('dc8503e8-8b0f-4e06-b95e-a83b0f423d7e', 'CREATED', 'CONTROL_DEFINITION', '9f7ef809-87e9-4f33-8aca-0753a3357f7e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-10", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('fbbcbf22-40ca-4ec3-89d3-a5eb69f85202', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'd547532e-7a61-4062-8140-f2c4d5cc52ff', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The digital solution must have traceability by linking requirements to its specifications and testing artifacts.", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Ensure Traceability", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "9f7ef809-87e9-4f33-8aca-0753a3357f7e", "reviewerTeam": "PRODUCT_PROJECT_DELIVERY", "sourceOfTruth": "DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Matrix demonstrating traceability between the requirements, specifications and tests.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following: \n\n* Is a traceability matrix in place linking each requirement to its corresponding specification(s)?\n* Does the matrix also link each requirement/specification to its corresponding test artifact (test case/script)?\n* Is coverage complete - i.e can every requirement be traced through to a specification and a test, with no orphaned requirements or untested specifications?\n* Is the traceability matrix kept current as requirements, specifications, or test artifacts change throughout the lifecycle?\n* Can the matrix be used to demonstrate full lifecycle coverage during an audit or inspection (particularly for GxP solutions)?\n* Any digital solution where requirements cannot be traced end-to-end to specifications and tests should be treated as non-compliant.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('5d520a30-e499-4854-9412-0d5f55cb1216', 'CREATED', 'CONTROL_DEFINITION', '50612162-2854-4558-8a23-f6241f7a2c48', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-13_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('4c33a138-d135-461e-9efc-a6aba7a85d9b', 'CREATED', 'CONTROL_DEFINITION_VERSION', '90f490ed-4ac7-40a1-b47b-44f47f4c7653', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "DEPLOY", "itProcess": "MANAGE_DELIVERY", "objective": "A summary of controls execution (as per the defined control strategy) must be documented to authorize the usage of the digital solution. Deviations from the controls strategy must be justified. For unresolved deviations, actions plans must be recorded to monitor their resolutions until closure.", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Authorize for Use", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "50612162-2854-4558-8a23-f6241f7a2c48", "reviewerTeam": "PRODUCT_PROJECT_DELIVERY", "sourceOfTruth": "DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Summary of the Control/Validation Strategy execution, including at least:\n - all the applicable controls and their achivement''s details\n - deviations from the strategy with associated justification and action plan to remediate them\n- the readiness status of the operational & maintenance processes\n- decision to authorize the usage of the digital solution\nE.g.: Authorization for use, Release report", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n- Has a summary of controls executed been documented?\n- Are all controls defined in the control strategy implemented? If not, are deviations justified?\n- For any unresolved deviations, is there an action plan defined with an assigned owner and due date?\n- Based on their impact, are there any unresolved deviation that would block the authorization for use?\n- Have operational readiness activities been properly executed to ensure the digital solution is ready for operation?\n- Has a comprehensive review of control execution, deviations, and operational readiness been conducted to make an informed decision on authorizing the usage of the digital solution?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a3bc8651-5ec4-4223-aad0-94b67eec65e3', 'CREATED', 'CONTROL_DEFINITION', 'c57c3e99-c9a0-4890-ade1-4e3d06463548', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-14", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('be26536d-f422-4c8f-ac99-34bfd95effdc', 'CREATED', 'CONTROL_DEFINITION_VERSION', '3c05a484-0beb-4d6d-9d8e-4eda0cfdddeb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The digital solution identified as digital property must adhere to the Digital Properties process.", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Execute Digital Properties Process", "triggerRule": null, "definitionId": "c57c3e99-c9a0-4890-ade1-4e3d06463548", "reviewerTeam": null, "sourceOfTruth": "DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/860315", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "Reference of the digital solution recorded in Digital Property Registry.", "applicabilityType": "ALWAYS", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Reference of the digital solution recorded in Digital Property Registry.", "autoAttestationRule": {"outcomeKey": "PROPERTY_TYPE", "acceptedValues": ["WEBSITE", "SOCIAL", "MOBILE_APP", "CHATBOT"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cbc58363-2e2a-48d3-991f-4e1dfd7465d8', 'CREATED', 'CONTROL_DEFINITION', '81f8fd1e-d226-462e-afa8-9ef1a2c5d07b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-15", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('02a331aa-2b1b-4f84-8358-5ef2a1deb060', 'CREATED', 'CONTROL_DEFINITION_VERSION', '223b640e-39cd-49af-bbff-5afc4fd6b95c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The AI solution risk assessment shall be documented and approved before deployment.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Risk Assessment", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "81f8fd1e-d226-462e-afa8-9ef1a2c5d07b", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Completed AI Risk Assessment, approval record", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Has an AI risk assessment been completed before deployment? Has the solution been classified according to the applicable AI risk categories? Have significant risks, limitations, and mitigation measures been documented? Has the AI risk assessment been reviewed and approved by the appropriate stakeholders?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e0db5523-cee7-4bcf-aa8a-1429b7c5f1e6', 'CREATED', 'CONTROL_DEFINITION', '5f9afb33-fa7f-4193-9eec-76bb84f92a1c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-16", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('225ac451-afa0-4e51-ac41-d1787ca7fe92', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'ebb02637-8715-442e-b3d5-08f21b42b85f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The AI solution shall have documented intended purpose, architecture, limitations, risks and usage instructions.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Documentation", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "5f9afb33-fa7f-4193-9eec-76bb84f92a1c", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "AI Solution Documentation, Architecture Diagram", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Is the intended purpose of the AI solution documented? Are the architecture, AI models, data sources, knowledge sources, and integrations documented? Are the known limitations, assumptions, and risks documented? Are user instructions and operating procedures available? Is documentation maintained throughout the solution lifecycle?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cd044b00-4a22-48a5-9dde-67206a782540', 'CREATED', 'CONTROL_DEFINITION', '620478d8-cc17-4a45-83a9-0d2da737e6ac', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-17", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('889406b8-61af-458d-a9c8-09e3a4a9c40a', 'CREATED', 'CONTROL_DEFINITION_VERSION', '8f6b96d0-8200-437b-a610-d4e78a2bf51e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "AI outputs shall be evaluated against predefined acceptance criteria before release.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Output Evaluation", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "620478d8-cc17-4a45-83a9-0d2da737e6ac", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Evaluation Report, UAT Results, Test Evidence", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Have AI outputs been evaluated before deployment? Have acceptance criteria been defined and approved? Has testing been performed using representative business scenarios? Have evaluation results been documented and reviewed? Are identified issues tracked and resolved before release?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('226f47de-25ca-41f4-8f46-34d9c9a4ad29', 'CREATED', 'CONTROL_DEFINITION', 'd2b2151a-ca2b-4cc6-80c7-a8d69aabadc3', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-18", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('22854b4b-f553-4bf3-950f-2c62eb29da24', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'b9ebc098-36b3-489d-b7b3-5bee27315cfb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Human oversight mechanisms shall be documented and implemented when required by the AI risk classification.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Human Oversight Design", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "d2b2151a-ca2b-4cc6-80c7-a8d69aabadc3", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Design Documentation, User Procedures", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Are human oversight mechanisms defined and documented? Can users intervene, challenge, approve, or override AI outputs when required? Are roles and responsibilities for oversight clearly defined? Is evidence of human approval or review retained where applicable?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('49a4ef27-15fb-431d-beec-f2c5db63e210', 'CREATED', 'CONTROL_DEFINITION', '55c1a526-c20f-4bcc-88f1-ccf5f804f5c0', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "QUAL-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('4f7e1b10-1950-485f-8310-4c392e875f92', 'CREATED', 'CONTROL_DEFINITION_VERSION', '3cb7862b-29eb-4a10-b49b-18fcfb431b4c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_QUALITY", "objective": "Records generated throughout the digital solution lifecycle (e.g Specifications, Access Request records etc) must be maintained and retained as per the Opella Record Retention Schedule that defines the retention period.", "ownerTeam": "DIGITAL_QUALITY", "statement": "Records Retention", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "55c1a526-c20f-4bcc-88f1-ccf5f804f5c0", "reviewerTeam": "QUALITY", "sourceOfTruth": "DFC-QU-GOP-0000296-Project & System Lifecycle: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/484176", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "*Inventory/list of records generated throughout the digital solution lifecycle (e.g Specifications, Access Request records, test evidence, CRs, etc)\n*Record retention log or archive index mapping each record type to its defined retention period per the Opella Record Retention Schedule\n*Evidence records are stored in a manner that ensures they remain accessible and legible for their full retention period\n* Disposal/destruction record for any documents reaching end of retention, showing this was executed per the schedule (not ad hoc)", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Have all record types generated throughout the digital solution lifecycle been identified and mapped to the Opella Record Retention Schedule?\n* Are records actually being retained for the period defined in the schedule (not shorter and not definitely without justification)?\n* Are records stored in a format/location that keeps them accessible and legible throughout the retention period?\n* Where retention periods have lapsed, was disposal handled per the defined process (not informal deletion)?\n* Any record type missing a defined retention period, or retained/disposed of outside the schedule, should be treated as non-compliant.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d8523865-7444-47db-a12d-168f5557e8e3', 'CREATED', 'CONTROL_DEFINITION', '923877ba-497e-45e7-9378-14841db4eeb5', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "QUAL-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('86932deb-f778-4c47-b30f-4254f1c91edc', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'cffb536f-9ca8-4295-b899-b1a3fe46c67f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_QUALITY", "objective": "Detected or potential GxP-related compliance failures impacting a digital solution must be reported as a Quality Event. Each event must be assessed with respect to GxP/Regulatory compliance, Product impact, and Safety, Patients, Data reliability. The associated action plans supporting resolution must be tracked as Corrective Actions and/or Preventive Actions (CAPAs).\n \nNote: For Quality Events reported as non-significant deviations, a Corrective Action and/or Preventive Action is not required.", "ownerTeam": "DIGITAL_QUALITY", "statement": "Deviation", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "923877ba-497e-45e7-9378-14841db4eeb5", "reviewerTeam": "QUALITY", "sourceOfTruth": "1. GQCMS-QU-GOP-0000518-Management of Deviations in QualiPSO: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/741670\n2. GQCMS-QU-GOP-0000286-Escalation of Quality Events and Management of Quality Alerts: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/470603\n3. GQCMS-QU-GOP-0000595-Corrective Action, Preventive Action and Effectiveness Check Management: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/856185", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "* Quality Event record documenting the detected or potential GxP-related compliance failure\n* Assessment documentation covering GxP/Regulatory compliance impact, Product impact, and Safety/Patients/Data reliability impact\n* For significant deviations: CAPA record(s) tracking the associated action plan through to resolution\n*For on-significant deviations: documented rationale confirming CAPA was correctly determined not required\n* Escalation record, where the Quality Event required escalation per the Management of Quality Alerts process", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Was the GxP-related compliance failure reported as a Quality Event in a timely manner?\n* Was the event assessed against all required dimensions - GxP/Regulatory compliance, Product impact, and Safety/Patients/Data reliability?\n* For deviations assessed as significant: was a CAPA created and tracked to resolution?\n* For deviations assessed as non-significant: is the \"CAPA not required\" determination documented and justified, not just assumed?\n* Was escalation triggered where the eent met escalation criteria?\n* Any GxP-related compliance failure not reported as a Quality Event, or missing a documented significance assessment, should be treated as non-compliant.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('33b442c6-2739-4c5c-9e54-bcab80e70e0a', 'CREATED', 'CONTROL_DEFINITION', '5113db89-d701-4833-ba41-0861b6d78b8d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "QUAL-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f93ec86c-0917-49a4-8c7d-07c6080ba680', 'CREATED', 'CONTROL_DEFINITION_VERSION', '50382738-488b-478b-8043-077129bb37f5', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_QUALITY", "objective": "The remediation of detected or potential failures of a digital  solution to comply with applicable regulatory (e.g. GxP, SOX, CSRD) or Opella requirements  must be tracked and monitored until completion to ensure timely and committed resolution.", "ownerTeam": "DIGITAL_QUALITY", "statement": "Corrective Action Preventive Action", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "5113db89-d701-4833-ba41-0861b6d78b8d", "reviewerTeam": "QUALITY", "sourceOfTruth": "QUA-CO-SOP-0010049-Management of CAPA and Effectiveness:", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "* CAPA record(s) tracking remediation of detected/potential failures against applicable regulatory requirements (GxP, SOX, CSRD) or Opella requirements\n* Action plan with defined owner, due date, and remediation steps\n* Status tracking evidence showing CAPA progress until completion (not just opened and left open)\n* Effectiveness check record confirming the corrective/prevventive action actually resolved the underlying issue\n* Escalation or overdue - CAPA report, where applicable, showing timely resolution was monitored", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Is every CAPA arising from a detected or potential failure tracked with an assigned owner and due date?\n* Is CAPA status monitored and updated until formal completion/closure?\n* Was an effectiveness check performed to confirm the corrective/preventive action resolved the root cause (not just closed administratively)?\n* Are overdue CAPAs identified and escalated per the defined process?\n* Any CAPA left open past its due date without escalation, or closed without an effectiveness check, should be treated as non-compliant.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('9cb4c928-c73c-477c-8ffd-8a4204bb99ec', 'CREATED', 'CONTROL_DEFINITION', '2f809e49-063f-4de8-aeb2-6238dfd023ef', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "RISK-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e6c73565-4cf7-434e-a05f-cfa3e14558d6', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'c6ebdc07-a5ff-4e7a-a3bb-d2b615d84c0e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "AI models, prompts, grounding data and configurations shall be controlled and versioned.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Model and Prompt Governance", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "f6e69665-74c5-47f3-8fe0-8387631fd439", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Version History, Configuration Repository", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Are AI models, prompts, configurations, and knowledge sources version controlled? Are changes documented and approved?  Is a history of modifications maintained? Can previously deployed versions be identified and retrieved?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8e0369d0-6ab0-46af-a42a-9537e3d1d384', 'CREATED', 'CONTROL_DEFINITION_VERSION', '65aac8bc-0d74-4cad-8c3d-8158a78b39f7', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_RISK", "objective": "The digital solution''s functions or components must be assessed for potential risks to business, patient safety, product quality, data integrity, and regulatory compliance in the event of a failure. The assessment determines the depth of expected tests or verifications to ensure these risks are controlled.", "ownerTeam": "CYBER_SECURITY", "statement": "Assess Functional Risk", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "2f809e49-063f-4de8-aeb2-6238dfd023ef", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "The risk assessment of the digital solution''s functionalities or components, describing the impact in case of failure and level of testing or verification required.\nE.g.: Risk issue in JIRA, Risk record in HP ALM, Functional Risk Assessment in Connect CMS...).", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following: \n\n* Has a risk assessment been performed for the digital solution''s functionalities or components, describing the impact in case of failure?\n* Does the assessment determine the appropriate level of testing or verification required based on the identified risk?\n* Is the risk assessment recorded in the appropriate tool for the solution (eg. Risk issue in Jira, Risk record in HP ALM, Functional Risk Assessment in Connect CMS)?\n* Does the assessment cover all functionalities/components in scope, with no material gaps?\n* Is there evidence the resulting testing/verification level was actually applied downstream (eg. traceable to the test strategy)?\n* Any functionality or component without a documented functional risk assessment, or where the assigned testing rigor doesn''t match the assessed risk, should be treated as non-compliant.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6ef4cdc2-c4e4-444e-b73c-fd6b332f7c69', 'CREATED', 'CONTROL_DEFINITION', '5cfb7e3c-6f86-4f12-8faa-cf3a20b3ef1f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d3a5f35e-56d7-422e-98e3-a3fa44fa31a0', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'd12bc0a6-bfc9-459e-8b8a-08d72426f39b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Threats must be identified so that risky scenarios can be understood and mitigated.", "ownerTeam": "CYBER_SECURITY", "statement": "Threat Modeling", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["OPELLA_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "5cfb7e3c-6f86-4f12-8faa-cf3a20b3ef1f", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "QU-STD-0000469 Secure Development of Applications: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/910529", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Cybersecurity Threat assessment describing the cyber security risks which can impact the digital solution and the mitigition plan.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Create a Security Architecture Review Intake using the form : https://opella-health.atlassian.net/wiki/spaces/CYBSECKB10/pages/557974353/Security+Architecture+Review+Intake", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f60ee2f0-e9d8-4c72-a55e-2aad2db42623', 'CREATED', 'CONTROL_DEFINITION', 'd6a4f79e-9f17-4da1-9765-3ba5291ddb97', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-02_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d759bba6-6996-4a93-832d-18cc725e8779', 'CREATED', 'CONTROL_DEFINITION_VERSION', '1f9916e9-fa0d-470b-b07c-f07971ccae93', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Vulnerabilities at code level of the digital solution must be identified and remediated. Additionally, if open source dependencies within the code are used then they must be reviewed to ensure proper use.", "ownerTeam": "CYBER_SECURITY", "statement": "Cyber Security Code Scan", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "d6a4f79e-9f17-4da1-9765-3ba5291ddb97", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "QU-STD-0000469 Secure Development of Applications:  https://api-eu.sanofi.com:8443/smartlink/api/qualipso/910529", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Result of the code scan with list of vulnerabilities detected and indicating that no critical/high vulnerabilities remains open.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n - Is the code of the digital solution stored into Opella GitHub repository?\n - Has a Cybersecurity code scan been requested and completed, before the release into production, to detect potential vulnerabilities?\n - Is a proof available, including at least: the list of vulnerabilities detected, the scan identifier, the date of the scan, the branch that was scanned, the result of the scan (SCA, SAST...) and name of the person who realized the screenshot and the timestamp?\n - If Critical/High vulnerabilities have been identified, have they been remediated before deployment in Production?\n\nIf open-source code is used:\n - Have we ensured compliance usage with the license terms (e.g. use for commercial purposes allowed, number of workstations allowed)?", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('37e52e14-2910-49f9-945c-7168659eed8d', 'CREATED', 'CONTROL_DEFINITION', '1a86ec24-95f5-4310-9369-f5b93d33a91b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('7841faa7-aee5-4317-89d2-cc8ea27413f4', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'f99e6ad0-a689-4eed-8b98-169bdc03422a', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Vulnerabilities of cloud environment of the digital solution must be identified and remediated.", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Cloud Security Posture", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "1a86ec24-95f5-4310-9369-f5b93d33a91b", "reviewerTeam": "INFRASTRUCTURE", "sourceOfTruth": "DIG-CO-STD-0000031-Systems Security Standard:https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "PRISMA/ SonarCube cloud service monitoring report indicating that no medium or high vulnerabilities are open.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "PRISMA/ SonarCube cloud service monitoring report indicating that no medium or high vulnerabilities are open.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6d596431-a76f-4602-a4f0-0c8f31b42566', 'CREATED', 'CONTROL_DEFINITION_VERSION', '6eb933a4-9c3d-490b-b2ad-37a4f666bc6f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Infrastructure vulnerability exposure of the digital solution must be monitored all along its lifecycle to ensure it is exempt from known vulnerabilities.", "ownerTeam": "CYBER_SECURITY", "statement": "Vulnerability Lifecycle Program", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "865139a5-726a-4402-a3ac-eceaf051bf86", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "If a vulnerability is identified through a Qualys scan, the corresponding report will be shared with the application owner, who is responsible for taking the necessary remediation actions within the required timelines.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "If a vulnerability is identified through a Qualys scan, the corresponding report will be shared with the application owner, who is responsible for taking the necessary remediation actions within the required timelines.", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('65b2530a-b8c5-4e77-868c-6a61fa132a73', 'CREATED', 'CONTROL_DEFINITION', '5963099b-6be9-4ec1-96db-a7471d87c5d7', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-05", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0afecdb6-f41b-4120-8828-a67eec35ab57', 'CREATED', 'CONTROL_DEFINITION_VERSION', '7c576686-92cb-4792-a5ae-4df00dff5433', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Attacks must be simulated to identify overall vulnerabilities before releasing the digital solution to production .", "ownerTeam": "CYBER_SECURITY", "statement": "Cyber Pentest", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}]}, "definitionId": "5963099b-6be9-4ec1-96db-a7471d87c5d7", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Cyber pentest report summarizing the simulation of the attacks on the digital solution executed and critial risks remediated.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Cyber pentest report summarizing the simulation of the attacks on the digital solution executed and critial risks remediated.", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('bf65549d-096d-49bf-8b27-528edd5d7f92', 'CREATED', 'CONTROL_DEFINITION', '690a3006-2358-42da-8075-912a062b66b1', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-06", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('504d0d2b-f9cb-45e9-a17a-f291a1535154', 'CREATED', 'CONTROL_DEFINITION_VERSION', '39ec7361-5ee2-4cdb-9f49-19fb76c9c236', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "If the digital solution is used in China:\nIt must comply with laws and regulations under China''s cyber security and data security regime.\n\nFor digital solutions hosted outside Mainland China: If No personal information or only Technical Personal data is collected from Mainland China, this control is not applicable. Otherwise a China Cross-Border Data Transfer – Personal Information (CBDT-PI) risk review must be included.\n\nFor digital solutions hosted in Mainland China: this control must be addressed.", "ownerTeam": "CYBER_SECURITY", "statement": "China Digital Compliance Requirement", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["USED_IN_CHINA"], "operator": "IN", "outcomeKey": "TERRITORIAL_COMPLIANCE_EXTENSION"}]}]}, "definitionId": "690a3006-2358-42da-8075-912a062b66b1", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "QU-GOP-0001332 China Digital Compliance Framework: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/8565258", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Requestor to contact GRC team - CyberGRC@Opella.com for further instructions", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Requestor to contact GRC team - CyberGRC@Opella.com for further instructions", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a16e5915-5bf0-4181-a2f9-5de7176d9cb3', 'CREATED', 'CONTROL_DEFINITION', 'c86b0c27-30fb-405f-acbd-a392d8c8a43b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SEC-07", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0482f66a-aa38-4067-8ce4-9d30acf0b780', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'cf1377dd-3854-41bb-a511-00ce412ea116', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SECURITY", "objective": "Vulnerabilities of cloud infrastructure code of the digital solution must be identified and remediated.", "ownerTeam": "DIGITAL_TECHNOLOGY", "statement": "Cloud infrastructure code scan", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "c86b0c27-30fb-405f-acbd-a392d8c8a43b", "reviewerTeam": "INFRASTRUCTURE", "sourceOfTruth": "DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "PRISMA/ SonarCube code scan report from Github repository indicating that no medium or high vulnerabilities are open.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "PRISMA/ SonarCube code scan report from Github repository indicating that no medium or high vulnerabilities are open.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b2d0dd32-5f37-442d-86f2-69114522e101', 'CREATED', 'CONTROL_DEFINITION_VERSION', '976322e7-b549-4e40-bfdc-a295ff69ae78', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SUPPLIER", "objective": "Third Party Risk must be identified during any sourcing activity in order to determine applicable due diligence and contracting actions to be executed prior to final qualification for the Cyber, Data Privacy, and Quality risk domains. A Non-Disclosure Agreement must be signed by both Opella and the 3rd Party to create a confidential relationship if applicable to conduct due diligence activities.", "ownerTeam": "CYBER_SECURITY", "statement": "Identify Third Party Risk", "triggerRule": {"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}, "definitionId": "f59a8266-784b-48e9-a903-d228e39fc23e", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009\n2. For Quality: DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974\n3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025\n4. Procurement Governance: GF-QU-STD-0000419-Procurement Global Operating Standard: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/819585", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Third Parties risk assessment (e.g Third Party Risk Identification Form completed).", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "All vendors with access to Opella''s network or are critical vendors need to go through the VIRP.During vendor onboarding  incase the vendor does not meet the Opella''s requirements, Risk Acceptance Letter to be signed by the Business", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cc18cd88-5ffd-4762-9c44-3ee3e631c07c', 'CREATED', 'CONTROL_DEFINITION', '86b82cdf-84dd-4ee6-bc8f-6ee5698cd4fd', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SUP-02_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('844d38a4-f4f0-408c-b00a-781da8751bd7', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'c32a1baa-64cb-43f3-87e7-917b0795123c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SUPPLIER", "objective": "According to a risk based approach based on the third party risk identification process,  the Digital Opella contract Owner (the person requesting and managing the contract process) must ensure that Quality contractual Clauses, Cyber Security measures, and Data Privacy Agreements relevant to the scope of services* are included in a contract with the third party.   \n\n*Note : a Contract, including Master Service Agreement can cover services related to one or several digital solutions.", "ownerTeam": "CYBER_SECURITY", "statement": "Contract", "triggerRule": {"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}, "definitionId": "86b82cdf-84dd-4ee6-bc8f-6ee5698cd4fd", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974 \n2. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Reference of established contract, agreement or Purchase order including proper clauses for each 3rd party used.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nFor each Third Party providing or supporting the digital solution (SaaS system, On-Premise Software, Middleware, Infrastructure or Platform provider, Managed Services, Outsourced services):\n\n- For Third Party identified as a “High Risk third party”* the control is to be attested in alignement with compliance status found into the High-Risk Third-Party dashboard.\n \nOtherwise:\n \nFor Third Party supporting a GxP  feature / process: \n- Are quality contractual clauses signed by authorized Opella and third party signatories, included into the contract and stored in a contract management system? If not, has a quality contractual clause exemption form been approved by the Contract owner?  \n\n- If the contract is up for renewal by end of the current year, and the contractual clauses have been signed for more than 5 years, is a gap assessment documented and an action plan defined for remediations?\n \nFor Third-Party that either accesses, stores or manages Opella information, has access to Opella systems, or has privileged access, or supports a vital process: Are the Cyber contractual measures included into the contract?\n \nFor Third-Party processing personal data: Is the Data Privacy Agreement included into the contract?\n \n* A High Risk Third Party is a provider supporting either a Vital activity or handling high risk data (highly sensitive data, sensitive personal data or GxP  / SOX relevant data).", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('101bac15-466b-40be-b8bd-9d897475672d', 'CREATED', 'CONTROL_DEFINITION', 'd2596b40-4456-4c7e-ad89-e990b34d9b1b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SUP-03_SIC", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f98ab606-c2f8-4662-b178-d4ef2575bc1d', 'CREATED', 'CONTROL_DEFINITION_VERSION', '5b4e556c-025b-4e34-823d-3a8d5256d436', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_SUPPLIER", "objective": "According to a risk based approach based on the third party risk identification process, an assessment of the 3rd Party is performed in order to evaluate quality, cyber and data privacy compliance. The results of this assessment are documented; it confirms the 3rd party meets Opella requirements to begin providing the solution or service.   \n\nFor SOX digital solutions and associated infrastructure components under the scope of the SOX annual campaign: A yearly independent assessment must be provided for any service outsourced to a Third Party so that compliance assurance is obtained.", "ownerTeam": "CYBER_SECURITY", "statement": "3rd Party Assessments", "triggerRule": {"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}, "definitionId": "d2596b40-4456-4c7e-ad89-e990b34d9b1b", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974\n2. DFC-QU-GOP-0000204-Computerized Systems Third-Party Assessments: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/351770 \n3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Third party Assessments performed including: third party audit/assessment report, Cyber Security certificates evaluation or completed VIRP, Data Privacy assessment.", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\nFor each Third Party providing or supporting the digital solution (SaaS system, On-Premise Software, Middleware, Infrastructure or Platform provider, Managed Services, Outsourced services):\n \nFor Third Party identified as a “High Risk third party”*, the control is to be attested in alignement with compliance status found into the High-Risk Third-Party dashboard.\n \nOtherwise, \n \n- For Quality Assessment:\nBased on the Third Party Risk Identification form result for the Third Party, if a Quality Assessment or Quality audit was required, has it been executed and recorded into CONNECT?\n\n- For VIRP (Cyber-Security) Assessment:\nIf the Third-Party either accesses, stores or manage Opella information, has access to Opella systems, or has privileged access, or supports a vital process: Has a VIRP assessment been completed and registered in the CyberVadis tool?\n \n- For Data Privacy Assessment :\nIf the Third Party processes personal data: Has a Data Privacy assessment been performed in OneTrust?\n \n* A High Risk Third Party is a provider supporting either supporting a Vital activity or handling high risk data (highly sensitive data, sensitive personal data or GxP  / SOX relevant data).", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cb1617b3-0ba6-4c7e-96d3-4c18b1bcf53b', 'CREATED', 'CONTROL_DEFINITION', '5c9909da-bdba-47eb-88ba-af66890170f7', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "SUP-04", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8410ddd4-da24-4696-b96c-f53057977ae3', 'CREATED', 'CONTROL_DEFINITION_VERSION', '86f10f52-6243-49ec-b366-5050540e893f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_SUPPLIER", "objective": "Relevant 3rd Party failures potentially impacting the data integrity, security, or privacy aspects associated to the digital solution as well as 3rd Party termination must be reported, assessed and addressed in order to minimize impact and restore controls.", "ownerTeam": "CYBER_SECURITY", "statement": "3rd Party Monitoring and Termination", "triggerRule": {"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}, "definitionId": "5c9909da-bdba-47eb-88ba-af66890170f7", "reviewerTeam": "CYBERSECURITY", "sourceOfTruth": "1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974\n2. DFC-QU-GOP-0000204-Computerized Systems Third-Party Assessments: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/351770\n3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "* Record of 3rd party failure/incident reported, with impact assessment covering data integrity, security, and privacy aspects\n* Assessment documentation evaluating the failure''s impact on the digital solution and associated controls. \n* Remediation/corrective action record showing how impact was minimized and controls restored\n* For 3rd party termination: documented termination record, including transition/exit plan and confirmation that data handling obligations were met\n* For High Risk Third Parties specifically (supporting Vital activities or handling highly sensitive/GxP/SoX-relevvant data): evidence of enhanced monitoring commensurate with that risk classification\n* Reference to the 3rd party''s classification/risk tier, to confirm the correct level of monitoring rigor was applied", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n* Has the 3rd party''s risk classification (including High Risk status, if applicable) been correctly identified per the defined criteria?\n* Were any 3rd party failures impacting data integrity, security, or privacy reported and assessed in a timely manner?\n* Were corrective actions taken to minimize impact and restore affected controls?\n* For terminated 3rd parties: was termination executed per the defined process, with data/access appropriately closed out?\n* For High Risk Third Parties: is there evidence of monitoring proportionate to that elevated risk (e.g. more frequent reviews, deeper assessments)?\n\nAll employees are required to promptly report any vendor-related incidents of which they become aware.to cyber@opella.com.", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0a76c5df-8ee0-4f9f-82b8-c0d7ca5a0a6d', 'CREATED', 'CONTROL_DEFINITION', '58de171c-5cb9-4b32-9d78-060b76aaa29f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-19", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('1ae0d629-7406-4d37-80ae-e7f861540904', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'dc64c63f-202d-4b34-8f4b-7b4a0d082874', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "AI transparency obligations shall be identified and implemented before deployment.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Transparency Assessment", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "58de171c-5cb9-4b32-9d78-060b76aaa29f", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Transparency Assessment, User Notification Evidence", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Are users informed when interacting with AI-generated content where required? Are AI-generated outputs clearly distinguishable from human-generated content? Are transparency requirements consistently applied across user interfaces?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e935b128-52c5-4222-80a2-ca7f64d071a6', 'CREATED', 'CONTROL_DEFINITION', '538c492c-245b-490a-86cd-39ce496831b4', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-20", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('601ef67b-1698-4ccf-adf1-30ee6f7dc122', 'CREATED', 'CONTROL_DEFINITION_VERSION', '107c7e22-4ec3-4211-809c-17d94250f53e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_DELIVERY", "objective": "ONLY applicable if there is 2 way communication on the platform:\nIf monitoring is performed by an outsourced service provider, a PV clause must be included in the contract wherever a service provider is involved in monitoring. \n\nNote: If this is performed by Opella employee, this control is not required.", "ownerTeam": "PV", "statement": "PV Monitoring for Digital Properties - PV Clause availability in Contract", "triggerRule": {"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}, {"values": ["SERVICE_PROVIDER"], "operator": "IN", "outcomeKey": "PV_MONITOR"}]}]}, "definitionId": "538c492c-245b-490a-86cd-39ce496831b4", "reviewerTeam": "PV", "sourceOfTruth": "DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Before GO LIVE: Signed contract containing PV clause, for any digital property involving a service provider", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "When attesting this control, consider the following:\n\n1. Does the digital property has two-way communication where PV information may be mentioned?\n2. Who is responsible to perform the monitoring (Service provider or Opella employee)?\n3. If a service provider performs the monitoring, is a PV clause present in the contract?\n4. If Opella employee, no action is required for this control", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3ecd370f-d759-4dea-96db-6214e66ef9cc', 'CREATED', 'CONTROL_DEFINITION', 'f6e69665-74c5-47f3-8fe0-8387631fd439', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-21", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d7882df5-20ad-44d5-9479-c24fc1061df4', 'CREATED', 'CONTROL_DEFINITION', '1a2d005c-4d48-4d90-b479-673720b2b191', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-22", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6498b7bd-efac-47d6-a685-2a86348f546a', 'CREATED', 'CONTROL_DEFINITION_VERSION', '3f705ac6-4096-41fe-9b7b-086453daa816', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "High-risk AI solutions shall include appropriate explainability information for intended users.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Explainability Assessment", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "1a2d005c-4d48-4d90-b479-673720b2b191", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Explainability Documentation", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Is information available to explain how AI outputs are generated? Are explanations appropriate for the intended audience? Are limitations and uncertainties communicated where appropriate? Has explainability information been documented and reviewed?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('52a2f6af-df80-4632-bcef-4ed6cc1889f6', 'CREATED', 'CONTROL_DEFINITION', 'e39c24d2-dc35-4be0-827d-e305640a236b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "MONIT-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('39ba0cac-786c-40eb-af2f-88eeb28508c7', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'd8738b3d-ee0d-49cd-8f4a-60c68273628e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MONITOR_PERFORMANCE_INDICATORS", "objective": "AI solutions shall be monitored in production to identify degradation, quality issues or unexpected behaviour.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Performance Monitoring", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "e39c24d2-dc35-4be0-827d-e305640a236b", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Monitoring Dashboard, Monitoring Report", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Is monitoring in place for AI quality, reliability, and performance? Have monitoring metrics and thresholds been defined? Are alerts generated when performance degrades?  Are monitoring results periodically reviewed? Are corrective actions defined and tracked when issues are detected?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8373cfcf-9447-46eb-b47d-bfe3fdf49a8c', 'CREATED', 'CONTROL_DEFINITION', '828802e9-318d-4d12-a854-9786209e4e63', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "MONIT-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6f2eb02f-2284-44e2-8dda-b4223227b806', 'CREATED', 'CONTROL_DEFINITION_VERSION', '38b0bbbf-6999-4b45-a385-1ba08a9358fd', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MONITOR_PERFORMANCE_INDICATORS", "objective": "AI-related incidents shall be recorded, assessed and remediated.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Incident Monitoring", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "828802e9-318d-4d12-a854-9786209e4e63", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Incident Records", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Are AI-related incidents recorded and investigated? Are root causes identified and documented?  Are corrective and preventive actions implemented? Are significant incidents escalated appropriately? Are lessons learned incorporated into the AI solution lifecycle?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('90939138-12f4-414f-9397-086121e3df24', 'CREATED', 'CONTROL_DEFINITION', 'a0405e56-a891-44df-828e-55daf4675d09', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "MONIT-04", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('fc5369bd-d4f3-4474-9120-02f975f994a7', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'abe83830-123b-4341-8cce-1939f6df8b41', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MONITOR_PERFORMANCE_INDICATORS", "objective": "AI solutions shall be periodically reviewed for continued fitness for intended use.", "ownerTeam": "DIGITAL_DATA", "statement": "AI Continuous Improvement", "triggerRule": {"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "a0405e56-a891-44df-828e-55daf4675d09", "reviewerTeam": "AI", "sourceOfTruth": "https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Periodic Review Report, Improvement Actions", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Is the AI solution periodically reviewed for continued fitness for intended use? Are changes in business requirements, data, or operating context assessed? Are improvement opportunities documented and tracked? Are monitoring results used to drive improvements? Is periodic review evidence retained?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e47a3521-364b-44b4-a290-fd7460de520e', 'CREATED', 'CONTROL_DEFINITION', '9ce48c02-47c1-4232-91ce-0f9d6469c7f4', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-23", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c18c3971-de03-4eab-af58-04d3b26cd0fe', 'CREATED', 'NFR_DEFINITION', '27182909-b008-42bf-a0a9-1776468e884e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-21", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('06a09529-d5aa-4227-bea8-669e86beed00', 'CREATED', 'CONTROL_DEFINITION_VERSION', 'e26edae2-a1ac-4947-8fab-fc8219f9f812', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_DELIVERY", "objective": "ONLY applicable if there is 2 way communication on the platform:\n\n1. PV training must be completed by personnel involved in monitoring  (service provider and/or Opella employee).", "ownerTeam": "PV", "statement": "PV Training", "triggerRule": {"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}]}]}, "definitionId": "9ce48c02-47c1-4232-91ce-0f9d6469c7f4", "reviewerTeam": "PV", "sourceOfTruth": "DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties\n(Opella SOP is currently in a draft stage)", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "Before GO LIVE: PV training documentation (certification/attendance record) for individuals involved in monitoring.\n\nAfter GO LIVE: PV Training documentation [On a yearly basis refresher training required for individuals involved in monitoring ]", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Have all individuals involved in monitoring completed PV training, with evidence available?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 12}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3c7665a3-5dbb-466f-a5f0-7155d78e9b6f', 'CREATED', 'CONTROL_DEFINITION', '010a40d2-eae8-4d61-b2bf-d0e4d8589d64', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "DEL-24", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e9d26347-5595-4db6-b027-3e957e5ee30d', 'CREATED', 'CONTROL_DEFINITION_VERSION', '8614ac0b-23ef-4e43-8fbe-bafdf961bfff', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "RUN", "itProcess": "MANAGE_DELIVERY", "objective": "ONLY applicable if there is 2 way communication on the platform:\n\nMonthly reconciliation (For any periodicity besides monthly reconciliation, a documentation is required) .", "ownerTeam": "PV", "statement": "PV Reconciliation", "triggerRule": {"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}]}]}, "definitionId": "010a40d2-eae8-4d61-b2bf-d0e4d8589d64", "reviewerTeam": "PV", "sourceOfTruth": "DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties\n(Opella SOP is currently in a draft stage)", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "APPROVAL_REQUIRED", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": true, "targetedEvidence": "After GO LIVE: Completed periodic reconciliation documents (monthly, or as otherwise agreed)", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "Where reconciliation applies, what are the evidence available to document that the reconciliation has been completed?", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": 1}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6793b70b-d47f-4d66-926d-ca13f53ad468', 'CREATED', 'NFR_DEFINITION', '2a55602f-e7d1-4f17-b0d8-57042c94bf51', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-01", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('006e5cc1-0eaa-48a6-8d73-a55d74b87f99', 'CREATED', 'NFR_DEFINITION_VERSION', 'aca6b047-0bd2-4e17-b71b-9a8006421ee5', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Each audit trail entry should specify the type of action (e.g. Create, Modify, Delete) performed on the electronic record.\n2. Each audit trail entry should include the user (inc administrator) name who performed the action.\n3. Each audit trail entry should include the exact date and time (hours, minutes, seconds) of user entries and actions, with time zone information if applicable.\n4. In case of modification or deletion, the audit trail should record the old data or value and also the new data or value.\n5. If required by regulations, each audit trail entry should include the reason for the change.\n6. The digital solution should be able to present the audit trail in a human-readable form \n7. The digital solution should provide functionalities to view, search, and analyze the audit trail.\n8. The audit trail must always be on, i.e. users must not be able to turn it off or modify it.\n9. Audit trail must be securely retained for the same duration as the associated record.\n\nReference STD: QUA-CO-STD-0000155: Management of GxP Electronic Records & Electronic Signatures", "ownerTeam": "DIGITAL_QUALITY", "statement": "I want to ensure that the digital solution creates and retains a secure, computer-generated, time-stamped audit trail of creation, modification, or deletion of data impacting regulated Electronic Records, so that the solution can comply with regulations and maintain data integrity.\n\nSpecific: user/administrator access accounts are one type of record to be audit trailed.", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "2a55602f-e7d1-4f17-b0d8-57042c94bf51", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('1c6a68e5-777f-4816-8fa6-2145ffc90bd7', 'CREATED', 'NFR_DEFINITION', 'eaa3bcbe-272f-4b6d-95f6-bcafeb44cdeb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-02", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c62a7e55-95ad-4862-8289-f01ff9a3b97b', 'CREATED', 'NFR_DEFINITION_VERSION', 'b0add7eb-d31e-451f-91ec-9beaaeaad870', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Given a set of data to be migrated/exchanged, the digital solution should validate the format and content of incoming data from other digital solutions before processing and generate alerts in case of error (e.g. volume, accuracy)\n2. The digital solution should ensure secure data transmission with other digital solutions, utilizing appropriate encryption methods.\n\nThe extent of the checks to be implemented is dependent on the use case.", "ownerTeam": "DIGITAL_QUALITY", "statement": "I want to ensure the digital solution has built-in checks for correct and secure entry and processing of data when exchanging data with other solutions, to minimize risks and ensure data integrity.", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}, {"conditions": [{"values": ["ECOMMERCE_OR_FINANCIAL"], "operator": "IN", "outcomeKey": "PROPERTY_CATEGORY"}]}]}, "definitionId": "eaa3bcbe-272f-4b6d-95f6-bcafeb44cdeb", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0e27c846-5544-4ce3-89e2-6b3faa02a846', 'CREATED', 'NFR_DEFINITION', 'b2064414-2123-41af-b2ab-74a72d6e6a52', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-03", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a9c6b34d-50da-41b8-bc7b-850b4711f102', 'CREATED', 'NFR_DEFINITION_VERSION', '0401050d-29e0-43a6-8b59-1ecf996814ee', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The digital solution should automatically check for invalid field entries upon data input.\n2. The digital solution should not allow the user to proceed without filling in required entry fields.\n3. The digital solution should validate the data type of entered data (e.g. date format)\n4 The digital solution should implement operational check to enforce the correct sequence of steps and events when necessary (e.g. a step cannot be executed if preceding step is not complete).\n5. In case of any error (incl out of range value), the digital solution should show an appropriate error message and guide the user to correct the error.\n6. The digital solution should not save any data until all the errors are resolved.\n\nThe extent of the checks to be implemented is dependent on the use case.", "ownerTeam": "DIGITAL_QUALITY", "statement": "I want to ensure the digital solution contains error detection mechanisms for invalid field entries, out of range values, blank fields for required entry, invalid data types and sequence enforcement related to the defined Electronic Records.", "triggerRule": {"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}, "definitionId": "b2064414-2123-41af-b2ab-74a72d6e6a52", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('31603d2b-c757-4766-80d8-564983634892', 'CREATED', 'NFR_DEFINITION', 'f2653553-9139-405f-a510-b12fe195f81b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-08", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('13970160-868a-4fd9-ac2e-dbb145beb2d7', 'CREATED', 'NFR_DEFINITION_VERSION', 'faccea15-2e20-4fd3-bfc9-4c67c3e3ce22', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Preferred solution is Opella SSO / AzureAD / Akamai.\n\nIf it''s a PAM or Opella account, then Identity shall be used:\n     --> https://identity.sanofi.com/edentity/ui/setTimeZone.jsf\n1. The digital solution must have the capability to create a password for a unique user ID. \n\n2. Password creation must adhere to the following rules: \n•\tLength of passwords: 8 characters minimum\n•\tComplexity: the password must have a minimum of 3 out of the following 4 elements: \n-\tNumeric characters: 0,1,2,3,4,5,6,7,8,9\n-\tSpecial characters: !, “,#,$,%,&,´,(,),*,+,-,.,/,[,],\\, @,^,_,{,|,},~\n-\tLowercase alphabetical characters\n-\tUppercase alphabetical characters\n•\tPassword history: the password must be different from the 10 previous used passwords \n•\tMaximum duration of the password: the password must be changed every 90 days\n•\tNo minimum duration of password \n•\tNo easily guessable words allowed in passwords \nFor additional details on passwords for PAM, SaaS refer to the document DFC-QU-STD-0000298-Access Control: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/581828. \n\n3. Passwords must be stored using modern and cryptographically strong hashing algorithm with a random salt per password, as specified in the document DFC-QU-STD-0000259 - Cryptography Standard.\n\n4. Prior to release, the digital solution must be tested in the BeSafe portal  (https://safe.sanofi.com/testYourPassword) to ensure that password creation complies to Policy requirements.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure all passwords comply with the minimum requirements.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "f2653553-9139-405f-a510-b12fe195f81b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('374a6d7c-4622-4386-9009-d9fc2f342463', 'CREATED', 'NFR_DEFINITION', 'ba890274-6fcf-45f3-86c0-05ba7ce73e32', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-09", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0e907c1b-551a-4954-bb98-ad44150326e7', 'CREATED', 'NFR_DEFINITION_VERSION', '2913a08e-f255-4f9b-a90a-bc72bc0dbade', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Prefer solution is Opella SSO / AzureAD / Akamai.\n\nIf it''s a PAM or Opella account, then Identity shall be used:\n     --> https://identity.sanofi.com/edentity/ui/setTimeZone.jsf\n\nNote: If you are specifically using a PAM service account, even though they have no password expiration, they are still bounded by a regular change of password to ensure there is no unauthorized access.\n\n1. The digital solution must have the capability to change a password. \n2. The digital solution must enable this capability when a password is forgotten.\n3. The existing password must be entered prior to initiating a new password change.\n4. If a new password is successfully accepted per the Password Creation rules, digital solution must send an email to the owner of the user ID to inform the owner of the password change.\n5. When a user forgets a password, the password is changed and not recovered, avoiding password not to be stored encrypted, as requested by the Cryptography Policy DFC-QU-STD-0000259-Cryptography Standard: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/500892.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure password changes are completed securely.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "ba890274-6fcf-45f3-86c0-05ba7ce73e32", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e563a23b-d242-4733-b6ac-5149212c592f', 'CREATED', 'NFR_DEFINITION', '5d2f8856-050b-41f5-b2d2-fb59f65f36cf', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-10", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('9908b112-372b-4fa3-a32b-e18596d84608', 'CREATED', 'NFR_DEFINITION_VERSION', '920f7820-809e-4f00-b024-5a84fad09756', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Service accounts for Pharma/Pasteur domains must use PAM process in accordance with the type of privileges requested.\n\nOther accounts must follow following rules:\n1. The digital solution must have varying authority levels that can be assigned to users and administrators.\n2. The digital solution users and administrators should be able to create, modify, and delete records depending on their authority level.\n3. The digital solution should enable the creation, modification, and deactivation of user accounts.\n4. The digital solution should prevent users and administrators from performing operations that exceed their authority level.\n5. The digital solution should maintain a log of all operations performed by users and administrators, including changes to authority levels.\n6. The digital solution should alert the security team/individual when an attempt is made to perform an operation that exceeds a user''s or administrator''s authority level.\n7. If the system is not using SSO, any change made to an account must force the reconnection of the user to his account.\n8. The system must provide the ability to create a list of users with associated access privileges that can be filtered and sorted for the current date, and for a 1 year past date.\n9. Administration, maintenance and support remote access must be restricted to access only the needed components. \n\nFor APIs: \n1) Use AzureAd or Cognito for managing permissions", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the digital solution has configurable authority levels for users and administrators, so they can perform specific operations (e.g. using the digital solution, managing records, electronically signing a record, managing user accounts, etc.) according to their assigned roles and permissions.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "5d2f8856-050b-41f5-b2d2-fb59f65f36cf", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('558e44e3-308e-420a-874e-160bf3934fa6', 'CREATED', 'NFR_DEFINITION', '9881e8a9-f4d6-4627-8ea2-7833bbad8fcd', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-11", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('062ab3fa-402e-48be-9e5a-5f6810c8e2fe', 'CREATED', 'NFR_DEFINITION_VERSION', '5de7c595-4867-47ca-a01c-863ade241519', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Accounts used on application and Operative Systems shall be Opella domain accounts.\nIdentity is Opella''s standard solution for account management.\n\nIf Identity cannot be used, then:\n1. The digital solution must require unique identification details for each user during registration.\n2. The digital solution must have a mechanism in place to check for duplicate user IDs during registration.\n3. The digital solution should not allow a user ID to be allocated to a new user if the user ID has been previously registered or inactivated. \n4. The digital solution must provide a clear error message when an attempt is made to register with an inactivated or in-use user ID.\n5. The digital solution must retain an audit log to track user ID allocation and inactivation for administrative review.\n\nIf there are nominative accounts (no generic / shared accounts), then the system must provide the ability to identify users uniquely, and a nominative account must be used.\n\nThe use of service accounts must be strictly limited to the purpose that is required.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that the digital solution uniquely identifies users and prevents the allocation of inactivated user IDs to new users, to maintain data integrity and security.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "9881e8a9-f4d6-4627-8ea2-7833bbad8fcd", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8c1f410a-fd05-4a40-bcca-a3a7d041239f', 'CREATED', 'NFR_DEFINITION', '9e1df205-e8f9-42d0-a1cb-93a629c0707e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-12", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER');
INSERT INTO public.audit_event (id, action, entity_type, entity_id, actor_user_id, target_user_id, reason, details, created_at, actor_type) VALUES
	('4decd323-7567-46ad-9bf1-9ee85b0fee98', 'CREATED', 'NFR_DEFINITION_VERSION', '4c7c9a08-dfd3-4496-a043-37a0d6f2b19c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "All default accounts for technology deployed (OS, middleware) must be disabled. \nIf the default account cannot be disabled, then it must comply with DFC-QU-STD-0000298-Access Control & GQCMS-QU-STD-0000452-User Access Management Controls:\n1. the default password must be updated to a stronger password. \n2. an owner must be identified.\n3. the default account must be registered into the role based access definition.\n4. when possible, username must be updated to differ from default name.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure all default accounts are deactivated to prevent them from being exploited to access the digital solution.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "9e1df205-e8f9-42d0-a1cb-93a629c0707e", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8ebd897e-09a4-451f-ba13-878a5e516562', 'CREATED', 'NFR_DEFINITION', '58e7a13d-95b6-4aff-a93f-b08613bd2b9b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-13", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f9dc23f0-5eba-4b38-8a69-830a67b45742', 'CREATED', 'NFR_DEFINITION_VERSION', '2f047781-6e80-458c-acc0-50e9d3c5b5ff', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If using standard SSO, then this is automatically validated. If not (if using not the standard), then the digital solution must:\n\n1. The digital solution must provide functions to deactivate and reactivate user and administrator accounts.\n•\tWhen an account is deactivated, the digital solution should retain all historical data and activities related to that account.\n•\tWhen an account is reactivated, the digital solution should restore access to all historical data and activities related to that account.\n2. The digital solution must record the times and dates of account deactivation and reactivation in the user activity log.\n3. The digital solution must prevent deactivated accounts from logging in until they have been reactivated.\n4. The digital solution should not allow any data modification or deletion during the period an account is deactivated.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the digital solution allows for deactivation and reactivation of user and administrator accounts without losing their activity history, so access can be appropriately managed while preserving important user data.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "58e7a13d-95b6-4aff-a93f-b08613bd2b9b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('60978de5-8785-480b-b9fd-d9d3809a10fe', 'CREATED', 'NFR_DEFINITION', '77b32464-9320-41ee-9f2d-0af178016832', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-14", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('14df81a9-8cf5-4857-a126-dbf20d8042f8', 'CREATED', 'NFR_DEFINITION_VERSION', '43ebd2a5-27c5-4280-bcdd-20131ecdac22', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "When the digital solution is using form-based authentication, a POST request must be used to avoid authentication credentials to be cached to browser history. \n•\tUse POST instead of GET. \n•\tEnsure a correct message (200 message) is displayed when retrieving the response from the request.", "ownerTeam": "CYBER_SECURITY", "statement": "I want all backend requests to the digital solution to be sent in a hidden format for security.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "77b32464-9320-41ee-9f2d-0af178016832", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8d70ff73-eb25-4752-8a7e-e677ae27f2f9', 'CREATED', 'NFR_DEFINITION', '163cef95-d70b-428a-ae84-72a1ed207fae', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-15", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('5be114a0-fa2a-4ccc-a13e-f9ffef00f51a', 'CREATED', 'NFR_DEFINITION_VERSION', '17fe4a05-fd48-46ae-a30c-3ddfb7aaad89', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Mechanisms must be in place to secure login to the digital solution including: \n•\tLogin to the digital solution must be blocked after 5 unsuccessful login attempts; login can be blocked based on user ID or IP address (prioritized ID).\n•\tThe digital solution should maintain the security and confidentiality of the users'' credentials during the authentication process.\n\n2. For machine-to-machine login mechanisms, the key-pair must be prioritized over credentials with clear lifecycle management.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure authentication controls are enabled for the digital solution to prevent brute-force attacks.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}, "definitionId": "163cef95-d70b-428a-ae84-72a1ed207fae", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f8143055-fb12-40f9-8d67-9e75b865fd5e', 'CREATED', 'NFR_DEFINITION', 'ac722f69-5bb2-4277-aaeb-997ac9985d2e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-16", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e9f276fe-d233-4ce1-9835-0c69acd0dcee', 'CREATED', 'NFR_DEFINITION_VERSION', '4ccabc65-0483-4b81-a472-2ed8c8a090d0', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Secure authentication (e.g. two-factor authentication) must be implemented for sensitive accounts to prevent successful spear-phishing attacks from evolving to access into the solution.\n\nMFA is mandatory for all the following cases:\n- Connexion to a SaaS (user and admin accounts)\n- Administrative access to specific solutions (Technology Platforms, Application that manages sensitive personal data or sensitive data)\n\n\n1. MFA requirements must be defined for all digital solution actions that required secure authentication; examples include: \n•\tPrivileged account authentication\n•\tActions to be carried out on confidential data\n2. MFA must be implemented according to the digital solution’s authentication requirements. \n\nNote: The Multi Factor Authenitcation is an additional method to the user / password that increases the level of security. This MFA is usually something that the user has (token) or is (fingerprint). \n\nExamples of MFA can be through Tokens, Codes, SMS, email, Mobile Apps, Fingerprint, etc.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to implement multi-factor authentication to avoid credential stuffing attacks to the digital solution.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}, {"values": ["CONFIDENTIAL", "HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "ac722f69-5bb2-4277-aaeb-997ac9985d2e", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8d48e00e-edea-4fe2-8879-cfb61f8159ba', 'CREATED', 'NFR_DEFINITION', 'a607d58e-cfdb-46ef-afd7-4a56065562c1', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-17", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('839fb319-97ba-4051-9c1e-00f4e99f2bd9', 'CREATED', 'NFR_DEFINITION_VERSION', 'f0563477-8970-4ecb-955e-5e60928d7924', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "SSO is mandatory for all Opella accounts (including internal and external) to login to SaaS applications.\n\n1. The digital solution must be integrated with a Single Sign-On (SSO) digital solution to allow transparent user authentication using SSO methodes trusted by Opella (e.g., OAuth on Azure AD).\n2. The digital solution should automatically authenticate the user’s identity through the SSO digital solution when a user accesses the digital solution, without requiring manual login.\n•\tIf the authentication is successful, the SSO digital solution should grant the user access to the digital solution and associated applications.\n•\tIf the authentication fails, the SSO digital solution should deny access and display an appropriate error message.\n3. The digital solution should maintain the security and confidentiality of the user''s credentials during the SSO authentication process.\n4. The digital solution should log all successful and unsuccessful SSO authentication attempts for audit purposes.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the digital solution authenticates users through Single Sign-On (SSO), so they can seamlessly access the digital solution without needing a different login.", "triggerRule": {"groups": [{"conditions": [{"values": ["OPELLA_EMPLOYEES_ONLY"], "operator": "IN", "outcomeKey": "TARGET_AUDIENCE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "a607d58e-cfdb-46ef-afd7-4a56065562c1", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ba958cb5-856e-4a1b-902f-938faa95def4', 'CREATED', 'NFR_DEFINITION', 'c54e3b54-49a0-4a35-a2de-f35c0fd7964b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-18", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('abb45691-20bf-4f56-b3d9-1222fe68246c', 'CREATED', 'NFR_DEFINITION_VERSION', '5d2a977b-c08c-4861-ba64-fdd843147812', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Measures must be taken to secure the digital solution’s network services such as: \n•\tLimiting network services exposure to only what the user needs to see (e.g. only port 443 for a web server).\n•\tDesigning the internal network so that databases and application servers are placed on dedicated network areas, which standard users cannot access.\n•\tLimiting administrative interfaces (e.g. RDP and SSH) to a dedicated administrative network.\n•\tRefraining from opening all ports in both directions.\n•\tRestrict administration exposure on the WAN (RDP/SSH/HTTPS). For NGDC (no firewall), use SEP firewall (for Windows) or iptable (for Linux). Only BASTION IP addresses should be allowed to connect to administration interfaces/ports.\n•\tEnsuring only secured ports are used and required for the digital solution.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that only the necessary network services (ports) are exposed to the user to reduce the likelihood of surface attacks.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "c54e3b54-49a0-4a35-a2de-f35c0fd7964b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cff1352b-4730-43e2-a86b-2a0660a2bc23', 'CREATED', 'NFR_DEFINITION', '330c182c-0a23-4e49-bafd-5d62ae48a855', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-19", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f1002051-2efd-4559-8bbc-12c247a83da9', 'CREATED', 'NFR_DEFINITION_VERSION', '798cd3dc-2a66-41cd-bd45-89135a3cfccb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "For internal solutions, use the request via SSL Certificate Global Request.\n --> https://sanofiservices.service-now.com/onesupport?id=sc_cat_item&sys_id=add1aad7db597300bb471923059619e0&table=sc_cat_item&searchTerm=ssl \n\nFor external solutions, ensure: \nThe digital solution’s SSL configuration must be compliant with best practices. At a minimum:\n•\tThe SSLv2/v3 should be disabled.\n•\tWEAK/INSECURE Cipher Suites should be avoided.\n•\tSSL certificate must have a key size of 2048 bytes and an algorithm of SHA 256 for encryption.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that configuration of cipher suites remains up to date to avoid vulnerabilities.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "330c182c-0a23-4e49-bafd-5d62ae48a855", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d261589a-7352-48bd-8903-31b307402df8', 'CREATED', 'NFR_DEFINITION', '905f35ec-62c9-4f1f-829c-66d1eb65d247', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-20", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('168f53f1-cfc7-43c2-b082-9bfcf101b9be', 'CREATED', 'NFR_DEFINITION_VERSION', 'c078f83f-ffaf-4088-beff-5aa976409ad9', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Anti-DOS measures must be implemented on the network and application layers depending on the availability needs of the digital solution. For example:\n•\tAt the network level, a service provider can prevent such attacks.\n•\tAt the digital solution layer level, mitigation measures such as setting up a Captcha or a Web Application Firewall (WAF) can reduce the impact of the attack.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that my digital solution is protected against denial of service (at the network and code level) to prevent any digital solution unavailability.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "905f35ec-62c9-4f1f-829c-66d1eb65d247", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('45577a0d-2dad-41df-b172-7f5ae3aeb3dd', 'CREATED', 'NFR_DEFINITION_VERSION', '68da4e50-af05-43fa-a019-04cd6efc08e2', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The applicable network areas must be defined, and the digital solution’s servers must be mapped and placed across these network areas accordingly. \n2. The digital solution’s servers must be mapped to each network area according to their criticality and the confidentiality of the data they contain (e.g. administration server, database servers, backup servers, etc.).\n3. The digital solution’s servers must be separated using VLANs, IP subnets, and firewalls, or by colors/zones if it’s a SCADA network (industrial network).  \n4. The digital solution’s environments (e.g. pre-production, production, and recipe) must be separated. \n\nIf SCADALAN network is used: SCADALANv2 is the architecture standard for Opella''s industrial information system segmentation.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that my digital solution is segregated across multiple network areas, to prevent attacks/incidents from spreading to the rest of the solution and/or enterprise network.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "27182909-b008-42bf-a0a9-1776468e884e", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e7fde7d7-fca2-401f-bcce-fa986f4f6433', 'CREATED', 'NFR_DEFINITION', 'b4c20e62-dac0-4bd4-b88c-fcedc7b4bfa6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-22", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('27133651-77e2-46a5-8153-45d0efab7a84', 'CREATED', 'NFR_DEFINITION_VERSION', '4ab0026b-6d27-441c-8ffe-70e9c1ef444f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Any digital solution component that is exposed on the internet must be clearly defined in APM (Application Portfolio Management) or DPR (Digital Property Registry), except for local projects.\n2. Exposed components must be placed in a demilitarized zone (DMZ).\n3. A reverse proxy and/or web firewall must be set up and configured between the DMZ and the internet.\n4. A firewall must be set up and configured between the DMZ and the network.\n5. Firewall rules must be reviewed by the Cyber security expert.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that any services exposed on the internet are partitioned from the rest of the network to prevent the spread of incidents/attacks to the internal network.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "b4c20e62-dac0-4bd4-b88c-fcedc7b4bfa6", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('60b69815-fa06-4c6f-8ce6-62777e05b5ae', 'CREATED', 'NFR_DEFINITION', '4524e59f-e7cd-4758-abc7-f75a02e1924c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-23", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('dd88011b-5822-4bb2-bc3a-17045e1ba566', 'CREATED', 'NFR_DEFINITION_VERSION', 'ad6e3921-f88c-44cc-809a-3b937fdc729c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Measures must be taken to secure the digital solution’s cloud architecture such as: \n•\tProhibiting RDP (Remote Desktop Protocol) access or similar protocols except from approved infrastructure dedicated to remote accesses (e.g., Bastion).\n•\tPartitioning the infrastructures of different projects/applications by setting up subnetworks or a VPC (virtual private cloud)\n•\tIdentifying and taking inventory of interconnection points between cloud infrastructure and the enterprise network\n•\tConfiguring and setting up firewalls at the interconnection points identified\n•\tIf Cloud-as-code / Infrastructure-as-Code is used, ensure there are not high or critical vulnerabilities found before deploying.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the digital solution’s cloud architecture is secured to avoid the spread of attacks in the cloud infrastructure or digital solution’s infrastructure.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "4524e59f-e7cd-4758-abc7-f75a02e1924c", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('31e9c219-feab-4cee-90ad-44930bb3456c', 'CREATED', 'NFR_DEFINITION', '74fc523e-4533-41d5-94f8-d9babe917259', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-24", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cc6969eb-cb60-4fc1-9b5d-f934ab772ffd', 'CREATED', 'NFR_DEFINITION_VERSION', 'bc96c4cd-2c89-4bf8-9c44-0313ccb6a589', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Measures must be taken to ensure the appropriate hardening is in place (Network, Operating System, Database); at a minimum the following must be done: \n•\tThe infrastructure has been passed through a security review before deploying. If it’s cloud-as-code, a secure cloud check must be done with appropriate tools (such as Prisma).\n•\tInfrastructure is protected with network security controls, such as firewalls, Intrusion Prevention/Detection Systems (IPS/IDS), access controls lists and network segmentation.\n•\tUnnecessary files, folders, services / ports, and debugging functions have been removed and disabled.\n•\tWeb and solution components are up to date (including operating digital solution, middleware, Content Management Systems (CMS), and plugins, and other components supporting the Web application).\n•\tWebserver should not be prone to path traversal, not directory listing.\n•\tInfrastructure is using the latest version available of the product.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure my digital solution’s infrastructure is secured to prevent technical vulnerabilities.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "74fc523e-4533-41d5-94f8-d9babe917259", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('dd38c68d-86d7-4d2e-a880-4667c6aef1a7', 'CREATED', 'NFR_DEFINITION', 'f1d57645-9bea-45ef-a0d9-ed351bc4f1cf', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-25", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c5ceab0c-c64c-445b-b435-7947d90f4a8f', 'CREATED', 'NFR_DEFINITION_VERSION', '6bb99028-ff65-4425-9354-6190375ebd72', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Security measures must be in place to ensure the web application is protected against Reflective/Permanent XSS (Cross Site Scripting) and any possible command injections (SQL, Operating system, Active Directory, XML):\n•\tValidate and sanitize all user inputs (form fields, URLs, cookies) before processing them.\n•\tUse prepared statements for SQL calls.\n•\tEncapsulate database requests in stored procedures.\n•\tImplement secure headers (content security policy and x-protection).\n\nIf application uses a token (JWT), then this NFR is not applicable.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the digital solution is protected against injection methods, to prevent technical vulnerabilities.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "f1d57645-9bea-45ef-a0d9-ed351bc4f1cf", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c8f101e5-6fa9-4a52-80ed-921ee52167cf', 'CREATED', 'NFR_DEFINITION', '850e6c37-b708-4e73-8be1-fe9aaa017bfb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-26", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('08ba4998-1043-46d2-8626-ba65300abd88', 'CREATED', 'NFR_DEFINITION_VERSION', '09bb55db-be62-4ed9-bcdc-05796eba20aa', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The session identifier must be created on the server side. \n2. A random algorithm must be used to generate session identifiers.\n3. Domain and patch for cookies, containing the authenticated session, should be restricted.\n4. Logout functionality should terminate all associated session connections.\n5. A new session identifier must be generated for any re-authentication.\n6. The session should timeout if not in use for a maximum of 15 minutes if Highly Confidential information are processed, or a maximum 1 hour if not.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to minimize the exposure of the web application session so I can prevent security attacks on open sessions that are not in use.", "triggerRule": {"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "850e6c37-b708-4e73-8be1-fe9aaa017bfb", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('5334d801-efda-49a6-9715-146b9cbcb4f3', 'CREATED', 'NFR_DEFINITION', '17351137-5380-43fa-afb3-180ca682a127', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-29", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('dd5e233c-713d-4afe-b301-e0a356d02987', 'CREATED', 'NFR_DEFINITION_VERSION', '2cb9457b-4c8b-4b8d-8b11-ef371d3a8e66', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. An inventory of the digital solution’s APIs must be tracked and established. \n2. The digital solution’s APIs must be secured through practices such as: \n•\tTracking API editors (only Applicable for 3rd parties)\n•\tTracking and capturing detailed API operations (only Applicable for 3rd parties)\n•\tConducting API reviews (only Applicable for 3rd parties)\n•\tTracking the API score in SAST or DAST tool (CodeGuard)\n\n3. Measures must be taken to minimize the processing of confidential, strategic, or personal data by the digital solution’s APIs.\n4. The digital solution must use APIs that encrypt the exchanged data flows.\n5. The digital solution must use APIs with an authentication and autorization system implemented.\n6. The digital solution muse use APIs with a call and rate limiting.\n7. When applicable, expose or consume the APIs via Opella Layer7 (architecture standard)", "ownerTeam": "CYBER_SECURITY", "statement": "I want to secure the use of APIs, so that they are not a source of vulnerability or attack to the digital solution.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "17351137-5380-43fa-afb3-180ca682a127", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0405dcaf-32af-4a1c-b4ec-152ca13d180d', 'CREATED', 'NFR_DEFINITION', '376392d0-a9e5-4b77-992b-ae65f3db31a8', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-30", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('59003b6f-2cd0-4ba3-9600-4f2175e1b58b', 'CREATED', 'NFR_DEFINITION_VERSION', 'cfe4c267-7393-4fd7-b649-acd7e9da8757', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Measures must be taken to secure data transmission to and from my digital solution (including migration activities) such as:\n•Implementing encrypted protocols (e.g., HTTPS instead of HTTP, SFTP instead of FTP, etc.)\n• Ensuring HTTP redirects to HTTPS\n• Using Layer7 technology when applicable  for ETLs (Extract, Transform, and Load procedures)\n• Encrypting data transmission with secure protocols (e.g., TLS with PFS) and ensuring its integrity\n• Only authorizing encrypted protocols to web servers, with an SSL certificate and HSTS (HTTP Strict Transport Security) enabled\n• Only using secure algorithms and ciphers for protocols\n• Passwords / Credentials are not transmitted in clear text over the network", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure all data transmission to and from the digital solution is encrypted.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "376392d0-a9e5-4b77-992b-ae65f3db31a8", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c05b295f-44a2-42db-9fb1-45cee76ac9ba', 'CREATED', 'NFR_DEFINITION', '1bc7191f-81e1-45d6-8634-733f31e9bd08', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-31", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('88787f9d-cc83-4e06-b4a1-1cb945581a27', 'CREATED', 'NFR_DEFINITION_VERSION', '395c7f40-bd47-4ccf-8ef9-dfba25db9f86', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Measures should be taken to implement data masking techniques to conceal any irrelevant or sensitive information that is not directly related to the requested data.\n2. The digital solution must only expose the bare minimum of information required for a particular user or task at the frontend.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that only essential information is shared or consumed, with a focus on avoiding the exposure of any additional information beyond what is specifically requested.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "1bc7191f-81e1-45d6-8634-733f31e9bd08", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ae959475-3913-44d8-8491-18912a3c2b4b', 'CREATED', 'NFR_DEFINITION', '33740363-b4b9-4cf6-b1a5-f70c9a9d8aec', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-32", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('63d578d4-1f9f-4e41-bfc4-a6b89678ec6a', 'CREATED', 'NFR_DEFINITION_VERSION', '117b3396-168f-4a7a-bfb4-32239821175d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The digital solution’s strategic and/or confidential data must be stored in a data host that has successfully completed the Cybersecurity assessment (VIRP process) with a successful score (above 700) or with equivalent certification (e.g., ISO 27001).\n2. Measures must be taken to anonymize and/or remove sensitive content from strategic and/or confidential data before hosting this data in a public cloud or outside of Opella standards.\n3. If applicable, each data folder/container must be properly isolated to ensure segregation between different parties.\n4.  Robust authentication mechanisms must be in place to authorize users’ access to data folders/containers.\n6. All access modifications to data folders/containers must be tracked and logged. \n7. Encryption measures should be taken to protect the data within each data folder/container.\n\nIf it''s a local system (HMI, PLC for instance), then: \n• Data and backup data must be stored in different physical locations and must be protected with an equal security level of encryption.\n• Databases must be encrypted.\n• Configuration files must be encrypted", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that all strategic and confidential data is hosted according to criticality, to ensure maximum data security.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}, "definitionId": "33740363-b4b9-4cf6-b1a5-f70c9a9d8aec", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": {"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b0f3ed3a-ec1a-4b36-93db-ffe8323ade34', 'CREATED', 'NFR_DEFINITION', '2042e88c-f3c3-4f62-a52d-0450f9b0742d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-33", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('36884e64-d5c3-49e8-bf52-04e40878e78e', 'CREATED', 'NFR_DEFINITION_VERSION', '1e81256e-4178-47de-8101-cd738d865977', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. Production data without proper masking or sanitization must not be handled outside of production environment.\n2. If the project requires to handle production data (especially personal data or confidential and Highly Confidentia) outside of production, an anonymization tool must be used.\n3. Confidential or Highly Confidentia data must only be stored when necessary.\n4. Confidential or Highly Confidentia data must be encrypted at rest. \n5. Confidential or Highly Confidentia data must be anonymized and filtered from production environments if they will be used in non-product environments (qualification, development, etc.).\n6. Confidential or Highly Confidentia data must not be made public.\n7. Test data must be deleted from the testing environment after finishing the tests", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure that all sensitive information is removed when production data is used in non-production environments.", "triggerRule": {"groups": [{"conditions": [{"values": ["CONFIDENTIAL", "HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}]}, "definitionId": "2042e88c-f3c3-4f62-a52d-0450f9b0742d", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ddb8ccc5-47dd-4af2-88d6-aec5209ec637', 'CREATED', 'NFR_DEFINITION', '2dc45294-6d91-4898-8f42-804b7effd193', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-34", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('84234743-360a-443f-a2be-1ad83a384408', 'CREATED', 'NFR_DEFINITION_VERSION', 'a53aad17-b139-4361-93d1-ec800561656d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. All of the digital solution’s infrastructure components must be centrally monitored and tracked with EDR tools. \n2. The triggers and rules for receiving monitoring alerts must be defined; examples of triggers include: \n•\tMalicious activity\n•\tUser malicious behavior \n•\tEndpoint monitoring (file integrity, process execution, registry changes)\n•\tIndicators of compromise (IOC)\n•\tThreat intelligence\n\n3. The digital solution’s infrastructure monitoring logs must be enabled and forwarded to a cybersecurity monitoring platform. \n4. Antimalware solutions must be deployed", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure monitoring mechanisms are in place to detect cybersecurity threats.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "2dc45294-6d91-4898-8f42-804b7effd193", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e489a78d-e0f4-4a33-8f81-e38f788ad296', 'CREATED', 'NFR_DEFINITION', 'b11d737b-5521-48c9-9281-4c6c18d73a46', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-35", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('784cfb2c-a389-45a1-9956-1179b18476c3', 'CREATED', 'NFR_DEFINITION_VERSION', 'a75bbab5-8655-4cbf-9ad1-97b9f51c805a', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The solution shall provide information describing how AI-generated outputs are produced. Explanations shall be appropriate for the intended audience and use case. The key factors, data sources, or inputs influencing the output shall be identifiable where technically feasible. Limitations and known constraints of the AI solution shall be documented and available to users.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall provide explanations appropriate to the audience regarding how AI-generated outputs are produced.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "6c43b8a0-5150-4dcb-b4fc-64cd0fe6eb4b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('eb48c32d-4891-4380-abd6-bba704e227f4', 'CREATED', 'NFR_DEFINITION_VERSION', '3a6d661c-b170-40a8-93c5-5a8935f56e7f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The associated log escalation and monitoring solution must:\n• Record all connection, access control and validation failures – all server-side entries must be recorded with sufficient user context to identify suspicious or malicious accounts, and kept for a sufficient period of time to permit a deferred investigation; Or\n• Implement an effective alert process so that suspicious activities are detected and processed in a timely manner. (e.g. automated alerts are triggered by the log analysis integrated in the SOC).\n\n2. Every log entry should include:\n• The date and time when the event occurred.\n• The location (IP address, device, etc.) where the event occurred.\n• The source of the event (e.g. the screen or page accessed).\n• The outcome of the event (e.g. successful login, failed login, account locked due to too many failed attempts, etc.).\n• The identity of any individuals, subjects, or objects/entities associated with the event, (e.g. user ID, role, etc.).\n\n3. The digital solution must store logs in a secure manner, preventing unauthorized access, modification, or deletion.\n\n4. The digital solution must provide a function for the system administrator to view, search, and analyze the logs.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure my digital solution is connected to a log escalation and monitoring solution for active incident detection.", "triggerRule": {"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}, "definitionId": "b11d737b-5521-48c9-9281-4c6c18d73a46", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ccc8ad9b-c154-44e5-9b6e-f3e15600daed', 'CREATED', 'NFR_DEFINITION', 'e8c654fb-1faa-4892-919d-e054adc32133', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-36", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('ad8ec084-92b7-4058-b25b-5c1c67a445b4', 'CREATED', 'NFR_DEFINITION_VERSION', '070565db-f711-4b14-b4d5-83ba9bd340fe', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "All websites must integrate with analytics technology that at a minimum track:\n•\tNumber of visits\n•\tEngagement\n•\tSessions per users \n•\tSession time", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure the website is equipped with tools to accurately measure usage (e.g., visits and page views) and to produce analytics reports for tracking purposes.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "e8c654fb-1faa-4892-919d-e054adc32133", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('bc3c6543-f48e-4594-9db7-1cc59733f8bf', 'CREATED', 'NFR_DEFINITION', 'd7ef72f3-7a62-4fc5-aa23-0c172f9d3526', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-38", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('1d66a6ee-c745-4f99-98f5-387bc7776cae', 'CREATED', 'NFR_DEFINITION_VERSION', '2804bfc5-df53-4ada-8831-7b6c6a686aac', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The solution shall provide mechanisms allowing human review, approval, intervention, or override of AI-generated outputs where required. Human oversight responsibilities shall be documented and assigned. The solution shall prevent autonomous execution of actions requiring human approval. Where applicable, evidence of human review or approval shall be retained for audit purposes.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall provide mechanisms enabling human review, approval, intervention, or override of AI outputs where required.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "d7ef72f3-7a62-4fc5-aa23-0c172f9d3526", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6db2e8e3-a414-44c9-94a9-d111dd601dea', 'CREATED', 'NFR_DEFINITION', 'b66bb021-7486-40cb-8f7d-d9a91fcd8d04', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-39", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b5558896-f3d3-489c-bee3-7327d014e1c8', 'CREATED', 'NFR_DEFINITION_VERSION', 'abed2d93-aa6c-45a4-bf69-e52686472be2', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "AI-generated content shall be clearly distinguishable from human-generated content. Users shall be informed when content, recommendations, or responses are generated by AI. AI labels shall be preserved when outputs are exchanged with other digital solutions where technically feasible. Labeling mechanisms shall be consistently applied across all user interfaces.", "ownerTeam": "DIGITAL_DATA", "statement": "AI-generated content shall be clearly distinguishable from human-generated content.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "b66bb021-7486-40cb-8f7d-d9a91fcd8d04", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6b1111cd-476e-42a6-a778-6291fcd43da0', 'CREATED', 'NFR_DEFINITION', '6c43b8a0-5150-4dcb-b4fc-64cd0fe6eb4b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-40", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d1f02122-a33b-4c7d-8912-0cfe4b5183dd', 'CREATED', 'NFR_DEFINITION', '0a01bf0f-7284-4ac8-948c-6ea171b5cad3', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-41", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('642245a8-2e3b-49da-87f1-2a12e89653aa', 'CREATED', 'NFR_DEFINITION_VERSION', '07e365b5-8114-4095-bc17-2fcda819eac6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The solution shall maintain traceability of AI model versions, prompts, configurations, knowledge sources, and generated outputs where applicable. Traceability information shall support audit, investigation, troubleshooting, compliance, and model governance activities. Records shall be protected against unauthorized modification and retained according to applicable retention requirements. Traceability information shall be retrievable throughout the AI solution lifecycle.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall maintain traceability of AI models, prompts, configurations, knowledge sources, and generated outputs where required to support audit, investigation, troubleshooting, compliance, and lifecycle management activities.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "0a01bf0f-7284-4ac8-948c-6ea171b5cad3", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8ef434e1-61ed-4530-aa0e-8ab3d663de31', 'CREATED', 'NFR_DEFINITION', 'ca7891f6-995f-4351-86ae-616665f408f1', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-42", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c1fcfd7b-325b-4866-86aa-220b93ce52eb', 'CREATED', 'NFR_DEFINITION_VERSION', '06c89174-6505-4a60-85e6-10fefdb0c103', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. The Operating Systems of the infrastructure of the digital solution are not obsolete and supported by Opella. \n2. The systems support regular updates through Opella patching solution and are enrolled in Up2date.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure my digital solution''s infrastructure is up to date and can be patched overtime to prevent cybersecurity vulnerabilities.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "ca7891f6-995f-4351-86ae-616665f408f1", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('5ef725ef-dd25-4392-b996-02dbda86d83e', 'CREATED', 'NFR_DEFINITION', '32e29ebb-0794-4c92-8aaf-1230c056de1d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-44", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a1449de6-5cdd-470a-93a5-28d113acea42', 'CREATED', 'NFR_DEFINITION_VERSION', 'f229b1d9-92ee-4ba5-95be-e1b8fa7c3971', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "1. All unnecessary softwares must be removed from the infrastructure. \n2. All softwares running necessary for the solution must be up-to-date. \n3. Software''s agent and application must be patched regularly, at least when a high or critical vulnerability is disclosed.", "ownerTeam": "CYBER_SECURITY", "statement": "I want to ensure my application is robust against cybersecurity vulnerabilities and that a patching strategy can be defined.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "32e29ebb-0794-4c92-8aaf-1230c056de1d", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('59d78934-25d4-40e5-8949-3627d0791c3e', 'CREATED', 'NFR_DEFINITION', '2796144d-7837-4d31-ab5c-b31909ba9b5f', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-52", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b4acb639-923f-4ade-ab8d-1d999785dd5f', 'CREATED', 'NFR_DEFINITION_VERSION', 'd753c674-a0d9-4caf-bdbd-b6a72f21b083', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data, the digital solution should allow authorized users to search for and extract all data related to a specific data subject. The extract should be available in a common / machine readable format (csv, txt, xml, ...). Any extraction should be logged by the digital solution for audit and compliance purposes.\nThis feature/right will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users)", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that if a personal data portability request is received, we can fulfilll it", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "2796144d-7837-4d31-ab5c-b31909ba9b5f", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('98d258d7-f993-481e-b5f9-9c96dc34db5a', 'CREATED', 'NFR_DEFINITION', '580ddb3a-e97e-4a8b-9d1b-53759d0b35ef', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-53", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('429e8293-e099-4bef-9389-8905144f48eb', 'CREATED', 'NFR_DEFINITION', 'ed37a4de-4573-4412-9ed0-bd9b34a10261', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-60", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('f3296de1-0994-43b5-bb17-ffb1fcc9c05b', 'CREATED', 'NFR_DEFINITION_VERSION', 'c0ed6467-02f0-41e0-91e0-5c07de57a671', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data, the digital solution should allow authorized users to rectify / update personal data of a data subject, if that is inaccurate or obsolete in respect to the purpose for which it is processed(*) Any extraction should be logged by the digital solution for audit and compliance purposes.\nThis feature will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users)\n\n(*) therefore, this requirement to not apply to cases in which personal data shall be retained as it was at the time when it was collected or processed (e.g. for audit or regulatory purposes).", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that if a personal data correction request is received, we can fulfilll it", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "580ddb3a-e97e-4a8b-9d1b-53759d0b35ef", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('8e3266c3-7318-4ea3-8b3f-b818df77d1ec', 'CREATED', 'NFR_DEFINITION', '4836d9d8-6be8-404b-a711-ce5a8a8d4f6a', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-54", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a56cfae4-d3c2-4f86-ad11-cd7592679766', 'CREATED', 'NFR_DEFINITION_VERSION', '7abe4b86-779d-4847-906b-2d66b50d56b6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data, the digital solution should allow authorized users to delete/anonymize the personal data of a data subject. \nAny deletion should be logged by the digital solution for audit and compliance purposes.\n\nThis feature will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users).", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that if a personal data erasure request is received, we can fulfilll it", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "4836d9d8-6be8-404b-a711-ce5a8a8d4f6a", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('a3d78984-3b65-4267-bdfe-e5b6b2c14ca4', 'CREATED', 'NFR_DEFINITION', '1094a551-513d-4e12-b901-f6ff7741c37b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-55", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('cdda5247-690e-463a-b11a-19e4eae5b3e1', 'CREATED', 'NFR_DEFINITION_VERSION', '295c5746-42d1-41ff-b7b4-43879af3291a', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution exchanges personal data with other solutions or otherwise transmits personal data over a digital network:\n1. all personal data must be encrypted when in transit.\n2.  encryption should be in line with approved encryption standards.\n3. the digital solution should verify that the data encryption was successful, and the data remains encrypted in transit.\n4. the digital solution should not allow unencrypted personal data to be transmitted.\n5. the digital solution should provide a report/log confirming that the data encryption process was successful for audit and compliance purposes.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that all personal data is encrypted in transit so data is protected from unauthorized access and potential breaches.", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "1094a551-513d-4e12-b901-f6ff7741c37b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0e751778-0bc1-4ead-a9f5-56fcb109b6cb', 'CREATED', 'NFR_DEFINITION', 'e46f2065-7899-4d6c-9ea8-2c6cb89911f3', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-56", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('c948dd12-62c5-4bee-a01c-59c488dfac00', 'CREATED', 'NFR_DEFINITION_VERSION', 'fa246bfe-5d53-400f-97a2-b34dcb53ddc4', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The solution shall support monitoring of AI quality, reliability, and performance. Performance thresholds and monitoring metrics shall be defined. Mechanisms shall exist to detect degradation of AI performance over time. Monitoring results shall be periodically reviewed.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall support monitoring of AI performance, quality, and reliability over time.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "93b1d6e0-a1f3-4c5b-bf1a-06fd404da816", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('68e8948e-533c-4a68-880c-04e370e73356', 'CREATED', 'NFR_DEFINITION_VERSION', 'ea8dcd47-7c5c-40b7-8413-bbc93b482d97', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data:\n1. sensitive personal data must be encrypted by the digital solution when at rest.\n2.  encryption should be in line with approved encryption standards.\n3. the digital solution should verify that the encryption was successful, and the data remains encrypted at rest.\n4. the digital solution should not allow unencrypted personal data to be stored.\n5. the digital solution should provide a report/log confirming that the data encryption process was successful for audit and compliance purposes.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that all sensitive personal data is encrypted at rest so data is further protected from potential breaches.", "triggerRule": {"groups": [{"conditions": [{"values": ["SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "e46f2065-7899-4d6c-9ea8-2c6cb89911f3", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3bf84cb5-2108-4c37-bc38-2e6dba5f8c3d', 'CREATED', 'NFR_DEFINITION', 'f63c030d-ece5-47e8-9ad6-e3368c7fdee8', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-57", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('9919bfe2-d33a-4915-b6a5-c6f69bae9eac', 'CREATED', 'NFR_DEFINITION_VERSION', '4290779b-4c85-456a-aee5-855f697bdf92', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data, the digital solution must include automated or semi-automated procedures to either delete or anonymize personal data when specific conditions (identified by the business owner) are met.\n\n Examples include, but are not limited to:\n- personal data is deleted/anonymized if/when a certain condition is met (e.g. when the data subject withdraws consent)\n- personal data is deleted/anonymized after a fixed period after a certain condition is met (20 years after the end of the employment contract, or 1 year after the data was collected).\nDifferent subsets of personal data may be subject to different rules.\n\nThe digital solution should not allow for endless retention of personal data", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that personal data is not retained for longer than it is necessary to fulfill the purposes for which it is processed within the digital solution", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "f63c030d-ece5-47e8-9ad6-e3368c7fdee8", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('9d9615b6-0c80-464f-94c7-f1a06311660f', 'CREATED', 'NFR_DEFINITION', '4c25426d-d58e-47a8-ba4d-9cb7ad9d90e6', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-58", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('320e208c-8eed-4e78-82b4-ced8df6e0bf7', 'CREATED', 'NFR_DEFINITION_VERSION', 'aaecbdc3-1b5b-4a2d-b9b5-609985906796', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution stores personal data and supports the processing of such data for different purposes, criteria and controls shall be in place to ensure that once a certain purpose is achieved, the relevant personal data remains available for other purposes but:\na) it can no longer be processed for the already achieved purpose(s), and\nb) access is restriced accordingly.\n\nExample: in a payroll system, time and attendance information of the last working period is actively processed to generate the corresponding payslip and transmit information for payment. When this purpose is achieved, such personal data is no longer needed for that purpose (which is achieved) and is archived to fulfil other purposes, such as to comply with regulatory requirements and allow for audits. As such, the time and attendance information of a certain month shal be retained but it must be frozen (no changes possible), and access should be restriced to those who may need access for regulatory or audit purpose. When all the purposes are achieved, personal data must be deleted or anonymized (see the previous NFR).\n\nExample: user data is processed to allow for login, and for activity tracking. When the user is terminated, the personal data of the user does no longer allow access to the system, but the data is retained for a longer period, for security and audit purpose.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that personal data is not used and/or accessed when it is no longer needed for certain purposes and to certain users, but remains available to other users and for different purposes (if applicable)", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "4c25426d-d58e-47a8-ba4d-9cb7ad9d90e6", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('871b6365-a324-4b99-9fa1-d968fc04aa39', 'CREATED', 'NFR_DEFINITION', '95c51290-a68f-4a03-8375-c4f6a78d7722', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-59", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('e75e59ca-4ef0-4418-993c-490c3439e0d8', 'CREATED', 'NFR_DEFINITION_VERSION', '6dff452b-28d9-4be0-9910-87df9829c5e5', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution includes the possibility to extract/export reports including personal data, such reports shall:\n- include a footer/header disclaimer such as \"This report contains personal data. Handle carefully to prevent unauthorized or unnecessary disclosure and dispose of it when no longer necessary\"\n- includes the name of the user that exported/downloaded the report, and the timestamp.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to facilitate responsible handling of reports including personal data by means of labelling", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "95c51290-a68f-4a03-8375-c4f6a78d7722", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('def70363-219a-4dd2-b996-5ddef3ab783c', 'CREATED', 'NFR_DEFINITION_VERSION', '41871b4d-f424-43ef-b925-13f5a25315ba', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution allows user to certain choices concerning their own personal data, and/or to set certain preferences concerning personal data, the default value of each choice/preference must be the least intrusive.\n\nExamples:\n- users can choose whether to display their full name or only initials to other uses <-- default = initials\n- users can choose whether to share activity logs for product improvement or not <-- default = no\n- users can choose whether to give feedback or not regarding certain features of the application <-- default = no\n- users can choose whether their status (active or inactive) can be visible to other users <-- dafault = not visible\n- etc.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that the default configuration or user''s options is the most conservative in terms of privacy, in accordance with the privacy y default principle / obligation", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}, "definitionId": "ed37a4de-4573-4412-9ed0-bd9b34a10261", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('6478b325-c1e0-458f-988d-ba82b6ae1bc3', 'CREATED', 'NFR_DEFINITION', '8b060bbd-13b8-40f4-a8df-0ea83b8e2a00', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-61", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('3da1c581-7908-4087-874b-6061ca8600dd', 'CREATED', 'NFR_DEFINITION_VERSION', '71f8fb9d-6e36-4008-b870-62cabd4b368a', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "If the digital solution allows users to input personal data about them, an appropriate privacy notice muct be available to users and mut be accessible from the digital solution itself  (contact the Privacy Office to get support with regards to identification or drafting of the notice)", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that users are provided with appropriate information concerning the intended use of their data, as required by the law", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}]}]}, "definitionId": "8b060bbd-13b8-40f4-a8df-0ea83b8e2a00", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('be1a286b-a0ea-4714-8534-47adacf90e5a', 'CREATED', 'NFR_DEFINITION', 'de2316c3-de8d-43d1-a1dd-eb583616197e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-62", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('d6b96b95-a4f3-4ca5-beaa-ef146c170bb5', 'CREATED', 'NFR_DEFINITION_VERSION', '561f2fc2-25f6-46ca-a557-2282ea2f3619', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Ensure that access to personal data and related functions of the digital solution is restricted to authorized users based on defined roles and legitimate business needs. Access shall be governed by a formal authorization process and implemented through appropriate authentication mechanisms, role-based access controls, and least-privilege principles. Access rights shall be appropriately provisioned, periodically reviewed, modified, and revoked throughout the user lifecycle.", "ownerTeam": "DATA_PRIVACY_OFFICE", "statement": "I want to ensure that data is not exposed to users who don''t really need it, as this would constitute a data breach.", "triggerRule": {"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}]}]}, "definitionId": "de2316c3-de8d-43d1-a1dd-eb583616197e", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b938fd15-07ba-4b78-bb4e-38bb9dd085cb', 'CREATED', 'NFR_DEFINITION', '8826814f-02f8-4050-b451-883d4747590d', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-63", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b6ac065a-d66c-4bce-8809-b950615ce5e4', 'CREATED', 'NFR_DEFINITION_VERSION', '4af8885b-6f4d-4fd5-9bd0-9dbc8fae8bdb', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "AI models, prompts, configurations, and grounding sources shall be version controlled. Changes to AI configurations shall be documented and traceable. Previous versions shall be retrievable when required. Version history shall be available for audit and troubleshooting purposes.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall maintain version control of AI models, prompts, configurations, and knowledge sources", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "8826814f-02f8-4050-b451-883d4747590d", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('85cc4540-0909-44aa-ac17-fbec00fa3822', 'CREATED', 'NFR_DEFINITION', '93b1d6e0-a1f3-4c5b-bf1a-06fd404da816', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-64", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('0259772f-9a3a-4fb4-9059-82c115fc1c49', 'CREATED', 'NFR_DEFINITION', '7612dbd5-de5c-466b-a2c6-11d74e9bad0b', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-65", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('61f35e03-90d8-4c49-9613-3867169411b0', 'CREATED', 'NFR_DEFINITION_VERSION', '00999338-ef6e-40ca-8c19-fb11160c9c8c', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Evidence of AI testing, evaluation, and validation activities shall be maintained. Evaluation results shall be traceable to the deployed version of the AI solution. Evaluation evidence shall be retrievable for audits and reviews. Approved acceptance criteria shall exist before deployment.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall support storage and retrieval of AI testing, evaluation, and validation evidence", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "7612dbd5-de5c-466b-a2c6-11d74e9bad0b", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('435cc3ca-f3de-4494-a835-da9602dd0211', 'CREATED', 'NFR_DEFINITION', '601bb291-306b-475d-a42e-87df03a8fa38', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-66", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('7e95fe98-febc-4f87-b69d-3990af8b04e6', 'CREATED', 'NFR_DEFINITION_VERSION', 'de69e013-aef2-4146-91d7-6ea893db714e', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "Knowledge sources used by the AI solution shall be identified and documented. Ownership of knowledge sources shall be defined. Processes shall exist to review and maintain the quality of knowledge sources. AI solutions shall only use authorized knowledge sources.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall maintain governance and traceability of the knowledge sources used to generate AI outputs", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "601bb291-306b-475d-a42e-87df03a8fa38", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('b2624f4f-7eaa-43c3-8d73-8186e79017ac', 'CREATED', 'NFR_DEFINITION', 'c90b93f6-d933-4648-a7bc-9c5d6d3e61bf', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"code": "NFR-67", "active": true, "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__"}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER'),
	('785b4351-9e31-417e-a21a-cd9cc54e7a8e', 'CREATED', 'NFR_DEFINITION_VERSION', '7999d0ce-0e88-4c84-bd34-ebd866334369', current_setting('dpr.catalogue_actor_user_id'), NULL, NULL, replace('{"after": {"slcPhase": "BUILD", "itProcess": "MANAGE_DELIVERY", "objective": "The solution shall implement safeguards to reduce the likelihood of harmful, inaccurate, biased, or inappropriate outputs. Mechanisms shall exist to identify and report unsafe AI outputs. Safety controls shall be periodically reviewed and updated. Documented mitigation measures shall exist for identified AI risks.", "ownerTeam": "DIGITAL_DATA", "statement": "The solution shall implement safeguards to reduce the risk of harmful, inaccurate, biased, or inappropriate outputs.", "triggerRule": {"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}, "definitionId": "c90b93f6-d933-4648-a7bc-9c5d6d3e61bf", "reviewerTeam": null, "sourceOfTruth": "", "versionNumber": 1, "versionReason": "INITIAL_IMPORT", "attestationType": "SELF_ATTESTATION", "createdByUserId": "__DPR_PROD_CATALOGUE_ACTOR__", "evidenceRequired": false, "targetedEvidence": "", "applicabilityType": "OUTCOME_TRIGGERED", "catalogVersionKey": "RISK_PROFILE_V1", "attestationGuidance": "", "autoAttestationRule": null, "assessmentTemplateKey": null, "revalidationIntervalMonths": null}, "before": null}', '__DPR_PROD_CATALOGUE_ACTOR__', current_setting('dpr.catalogue_actor_user_id'))::jsonb, '2026-09-09 11:16:30.079', 'USER');


--
-- Data for Name: brand; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.brand (id, name, scope, active, created_at, updated_at) VALUES
	('seed-brand-acemuc', 'Acemuc', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-actoralcare', 'ActoralCare', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-aderogyl', 'Aderogyl', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-alesion', 'Alesion', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-algoflex', 'Algoflex', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-allegra', 'Allegra', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-anador', 'Anador', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-antinevralgic', 'Antinevralgic', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-aspegic', 'Aspegic', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-aspercreme', 'Aspercreme', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-baralgin', 'Baralgin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-bioflorin', 'Bioflorin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-bisolvon', 'Bisolvon', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-bronchi', 'Bronchi', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-buscamint', 'Buscamint', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-buscofen', 'Buscofen', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-buscopan', 'Buscopan', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-calcium-corbiere', 'Calcium Corbiere', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-cenovis', 'Cenovis', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-cialis', 'Cialis', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-cortizone-10', 'Cortizone 10', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-despreconstipatie', 'Despreconstipatie', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dicarbocalm', 'Dicarbocalm', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dolihume', 'Dolihume', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-doliprane', 'Doliprane', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dorflex', 'Dorflex', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dulcogas', 'Dulcogas', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dulcolax', 'Dulcolax', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dulconatural', 'Dulconatural', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dulcoplant', 'Dulcoplant', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-dulcosoft', 'Dulcosoft', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-endiaron', 'Endiaron', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-enterogermina', 'Enterogermina', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-essentiale', 'Essentiale', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-eve', 'Eve', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-festal', 'Festal', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-finalgon', 'Finalgon', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-flomax', 'Flomax', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-gammelodiprane', 'Gammelodiprane', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-gelicart', 'Gelicart', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-goldbond', 'GoldBond', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-guttalax', 'Guttalax', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-histiacil', 'Histiacil', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-ibalgin', 'Ibalgin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-ibolex', 'Ibolex', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-ibuflam', 'Ibuflam', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-icyhot', 'IcyHot', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-initv', 'Initv', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-ipraalox', 'Ipraalox', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-iprafeine', 'Iprafeine', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-lactacyd', 'Lactacyd', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-lanzor', 'Lanzor', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-lasolvan', 'Lasolvan', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-laxoberal', 'Laxoberal', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-lizipaina', 'Lizipaina', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-lysopaine', 'Lysopaine', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-maalox', 'Maalox', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-magneb6', 'MagneB6', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-magnevie', 'Magnevie', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-maxilase', 'Maxilase', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-migralgin', 'Migralgin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-mobility', 'Mobility', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-mucoangin', 'Mucoangin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-muconasal', 'Muconasal', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-mucosan-mucosolvan', 'Mucosan/Mucosolvan', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-mucosin', 'Mucosin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-nasacort', 'Nasacort', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-nature-s-own', 'Nature''s Own', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-nospa', 'NoSpa', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-novalgina', 'Novalgina', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-novanight', 'Novanight', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-opella', 'Opella', 'GLOBAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-oscal', 'Oscal', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-ostelin', 'Ostelin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-paralen', 'Paralen', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-pharmaton', 'Pharmaton', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-phenergan', 'Phenergan', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-phosphalugel', 'Phosphalugel', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-physiomer', 'Physiomer', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-phytoxil', 'Phytoxil', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-quarelin', 'Quarelin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-rhinospray', 'Rhinospray', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-selsun-blue', 'Selsun Blue', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-sinuberase', 'Sinuberase', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-targifor', 'Targifor', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-thomapyrin', 'Thomapyrin', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-toplexil', 'Toplexil', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-unisom', 'Unisom', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-xyzal', 'Xyzal', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-brand-zantac', 'Zantac', 'LOCAL', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079');


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.region (id, name, active, created_at, updated_at) VALUES
	('seed-region-africa', 'Africa', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-latam', 'LATAM', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-eurasia-and-middle-east', 'Eurasia & Middle East', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-europe', 'Europe', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-asia', 'Asia', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-north-america', 'North America', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-jpac', 'JPAC', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-region-china', 'China', true, '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079');


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.country (id, name, active, region_id, created_at, updated_at) VALUES
	('seed-country-argentina', 'Argentina', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-australia', 'Australia', true, 'seed-region-jpac', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-austria', 'Austria', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-azerbaijan', 'Azerbaijan', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-belarus', 'Belarus', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-belgium', 'Belgium', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-bosnia-and-herzegovina', 'Bosnia and Herzegovina', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-brazil', 'Brazil', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-bulgaria', 'Bulgaria', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-burundi', 'Burundi', true, 'seed-region-africa', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-cambodia', 'Cambodia', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-canada', 'Canada', true, 'seed-region-north-america', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-chile', 'Chile', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-china', 'China', true, 'seed-region-china', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-colombia', 'Colombia', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-croatia', 'Croatia', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-czech-republic', 'Czech Republic', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-denmark', 'Denmark', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-dominican-republic', 'Dominican Republic', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-ecuador', 'Ecuador', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-egypt', 'Egypt', true, 'seed-region-africa', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-estonia', 'Estonia', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-finland', 'Finland', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-france', 'France', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-georgia', 'Georgia', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-germany', 'Germany', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-greece', 'Greece', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-hong-kong', 'Hong Kong', true, 'seed-region-china', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-hungary', 'Hungary', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-india', 'India', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-indonesia', 'Indonesia', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-ireland', 'Ireland', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-israel', 'Israel', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-italy', 'Italy', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-japan', 'Japan', true, 'seed-region-jpac', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-kazakhstan', 'Kazakhstan', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-latvia', 'Latvia', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-lithuania', 'Lithuania', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-luxembourg', 'Luxembourg', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-malaysia', 'Malaysia', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-mexico', 'Mexico', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-montenegro', 'Montenegro', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-netherlands', 'Netherlands', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-new-zealand', 'New Zealand', true, 'seed-region-jpac', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-norway', 'Norway', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-pakistan', 'Pakistan', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-peru', 'Peru', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-philippines', 'Philippines', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-poland', 'Poland', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-portugal', 'Portugal', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-romania', 'Romania', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-russia', 'Russia', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-saudi-arabia', 'Saudi Arabia', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-serbia', 'Serbia', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-singapore', 'Singapore', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-slovakia', 'Slovakia', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-south-africa', 'South Africa', true, 'seed-region-africa', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-south-korea', 'South Korea', true, 'seed-region-jpac', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-spain', 'Spain', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-sweden', 'Sweden', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-switzerland', 'Switzerland', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-thailand', 'Thailand', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-turkey', 'Turkey', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-ukraine', 'Ukraine', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-united-arab-emirates', 'United Arab Emirates', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-united-kingdom', 'United Kingdom', true, 'seed-region-europe', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-united-states', 'United States', true, 'seed-region-north-america', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-uruguay', 'Uruguay', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-uzbekistan', 'Uzbekistan', true, 'seed-region-eurasia-and-middle-east', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-venezuela', 'Venezuela', true, 'seed-region-latam', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('seed-country-vietnam', 'Vietnam', true, 'seed-region-asia', '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079');


--
-- Data for Name: brand_country_availability; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-acemuc', 'seed-country-vietnam'),
	('seed-brand-actoralcare', 'seed-country-united-states'),
	('seed-brand-aderogyl', 'seed-country-mexico'),
	('seed-brand-alesion', 'seed-country-japan'),
	('seed-brand-algoflex', 'seed-country-hungary'),
	('seed-brand-allegra', 'seed-country-argentina'),
	('seed-brand-allegra', 'seed-country-australia'),
	('seed-brand-allegra', 'seed-country-austria'),
	('seed-brand-allegra', 'seed-country-azerbaijan'),
	('seed-brand-allegra', 'seed-country-belarus'),
	('seed-brand-allegra', 'seed-country-belgium'),
	('seed-brand-allegra', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-allegra', 'seed-country-brazil'),
	('seed-brand-allegra', 'seed-country-bulgaria'),
	('seed-brand-allegra', 'seed-country-burundi'),
	('seed-brand-allegra', 'seed-country-cambodia'),
	('seed-brand-allegra', 'seed-country-canada'),
	('seed-brand-allegra', 'seed-country-chile'),
	('seed-brand-allegra', 'seed-country-china'),
	('seed-brand-allegra', 'seed-country-colombia'),
	('seed-brand-allegra', 'seed-country-croatia'),
	('seed-brand-allegra', 'seed-country-czech-republic'),
	('seed-brand-allegra', 'seed-country-denmark'),
	('seed-brand-allegra', 'seed-country-dominican-republic'),
	('seed-brand-allegra', 'seed-country-ecuador'),
	('seed-brand-allegra', 'seed-country-egypt'),
	('seed-brand-allegra', 'seed-country-estonia'),
	('seed-brand-allegra', 'seed-country-finland'),
	('seed-brand-allegra', 'seed-country-france'),
	('seed-brand-allegra', 'seed-country-georgia'),
	('seed-brand-allegra', 'seed-country-germany'),
	('seed-brand-allegra', 'seed-country-greece'),
	('seed-brand-allegra', 'seed-country-hong-kong'),
	('seed-brand-allegra', 'seed-country-hungary'),
	('seed-brand-allegra', 'seed-country-india'),
	('seed-brand-allegra', 'seed-country-indonesia'),
	('seed-brand-allegra', 'seed-country-ireland'),
	('seed-brand-allegra', 'seed-country-israel'),
	('seed-brand-allegra', 'seed-country-italy'),
	('seed-brand-allegra', 'seed-country-japan'),
	('seed-brand-allegra', 'seed-country-kazakhstan'),
	('seed-brand-allegra', 'seed-country-latvia'),
	('seed-brand-allegra', 'seed-country-lithuania'),
	('seed-brand-allegra', 'seed-country-luxembourg'),
	('seed-brand-allegra', 'seed-country-malaysia'),
	('seed-brand-allegra', 'seed-country-mexico'),
	('seed-brand-allegra', 'seed-country-montenegro'),
	('seed-brand-allegra', 'seed-country-netherlands'),
	('seed-brand-allegra', 'seed-country-new-zealand'),
	('seed-brand-allegra', 'seed-country-norway'),
	('seed-brand-allegra', 'seed-country-pakistan'),
	('seed-brand-allegra', 'seed-country-peru'),
	('seed-brand-allegra', 'seed-country-philippines'),
	('seed-brand-allegra', 'seed-country-poland'),
	('seed-brand-allegra', 'seed-country-portugal'),
	('seed-brand-allegra', 'seed-country-romania'),
	('seed-brand-allegra', 'seed-country-russia'),
	('seed-brand-allegra', 'seed-country-saudi-arabia'),
	('seed-brand-allegra', 'seed-country-serbia'),
	('seed-brand-allegra', 'seed-country-singapore'),
	('seed-brand-allegra', 'seed-country-slovakia'),
	('seed-brand-allegra', 'seed-country-south-africa'),
	('seed-brand-allegra', 'seed-country-south-korea'),
	('seed-brand-allegra', 'seed-country-spain'),
	('seed-brand-allegra', 'seed-country-sweden'),
	('seed-brand-allegra', 'seed-country-switzerland'),
	('seed-brand-allegra', 'seed-country-thailand'),
	('seed-brand-allegra', 'seed-country-turkey'),
	('seed-brand-allegra', 'seed-country-ukraine'),
	('seed-brand-allegra', 'seed-country-united-arab-emirates'),
	('seed-brand-allegra', 'seed-country-united-kingdom'),
	('seed-brand-allegra', 'seed-country-united-states'),
	('seed-brand-allegra', 'seed-country-uruguay'),
	('seed-brand-allegra', 'seed-country-uzbekistan'),
	('seed-brand-allegra', 'seed-country-venezuela'),
	('seed-brand-allegra', 'seed-country-vietnam'),
	('seed-brand-anador', 'seed-country-brazil'),
	('seed-brand-antinevralgic', 'seed-country-romania'),
	('seed-brand-aspegic', 'seed-country-argentina'),
	('seed-brand-aspegic', 'seed-country-australia'),
	('seed-brand-aspegic', 'seed-country-austria'),
	('seed-brand-aspegic', 'seed-country-azerbaijan'),
	('seed-brand-aspegic', 'seed-country-belarus'),
	('seed-brand-aspegic', 'seed-country-belgium'),
	('seed-brand-aspegic', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-aspegic', 'seed-country-brazil'),
	('seed-brand-aspegic', 'seed-country-bulgaria'),
	('seed-brand-aspegic', 'seed-country-burundi'),
	('seed-brand-aspegic', 'seed-country-cambodia'),
	('seed-brand-aspegic', 'seed-country-canada'),
	('seed-brand-aspegic', 'seed-country-chile'),
	('seed-brand-aspegic', 'seed-country-china'),
	('seed-brand-aspegic', 'seed-country-colombia'),
	('seed-brand-aspegic', 'seed-country-croatia'),
	('seed-brand-aspegic', 'seed-country-czech-republic'),
	('seed-brand-aspegic', 'seed-country-denmark'),
	('seed-brand-aspegic', 'seed-country-dominican-republic'),
	('seed-brand-aspegic', 'seed-country-ecuador'),
	('seed-brand-aspegic', 'seed-country-egypt'),
	('seed-brand-aspegic', 'seed-country-estonia');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-aspegic', 'seed-country-finland'),
	('seed-brand-aspegic', 'seed-country-france'),
	('seed-brand-aspegic', 'seed-country-georgia'),
	('seed-brand-aspegic', 'seed-country-germany'),
	('seed-brand-aspegic', 'seed-country-greece'),
	('seed-brand-aspegic', 'seed-country-hong-kong'),
	('seed-brand-aspegic', 'seed-country-hungary'),
	('seed-brand-aspegic', 'seed-country-india'),
	('seed-brand-aspegic', 'seed-country-indonesia'),
	('seed-brand-aspegic', 'seed-country-ireland'),
	('seed-brand-aspegic', 'seed-country-israel'),
	('seed-brand-aspegic', 'seed-country-italy'),
	('seed-brand-aspegic', 'seed-country-japan'),
	('seed-brand-aspegic', 'seed-country-kazakhstan'),
	('seed-brand-aspegic', 'seed-country-latvia'),
	('seed-brand-aspegic', 'seed-country-lithuania'),
	('seed-brand-aspegic', 'seed-country-luxembourg'),
	('seed-brand-aspegic', 'seed-country-malaysia'),
	('seed-brand-aspegic', 'seed-country-mexico'),
	('seed-brand-aspegic', 'seed-country-montenegro'),
	('seed-brand-aspegic', 'seed-country-netherlands'),
	('seed-brand-aspegic', 'seed-country-new-zealand'),
	('seed-brand-aspegic', 'seed-country-norway'),
	('seed-brand-aspegic', 'seed-country-pakistan'),
	('seed-brand-aspegic', 'seed-country-peru'),
	('seed-brand-aspegic', 'seed-country-philippines'),
	('seed-brand-aspegic', 'seed-country-poland'),
	('seed-brand-aspegic', 'seed-country-portugal'),
	('seed-brand-aspegic', 'seed-country-romania'),
	('seed-brand-aspegic', 'seed-country-russia'),
	('seed-brand-aspegic', 'seed-country-saudi-arabia'),
	('seed-brand-aspegic', 'seed-country-serbia'),
	('seed-brand-aspegic', 'seed-country-singapore'),
	('seed-brand-aspegic', 'seed-country-slovakia'),
	('seed-brand-aspegic', 'seed-country-south-africa'),
	('seed-brand-aspegic', 'seed-country-south-korea'),
	('seed-brand-aspegic', 'seed-country-spain'),
	('seed-brand-aspegic', 'seed-country-sweden'),
	('seed-brand-aspegic', 'seed-country-switzerland'),
	('seed-brand-aspegic', 'seed-country-thailand'),
	('seed-brand-aspegic', 'seed-country-turkey'),
	('seed-brand-aspegic', 'seed-country-ukraine'),
	('seed-brand-aspegic', 'seed-country-united-arab-emirates'),
	('seed-brand-aspegic', 'seed-country-united-kingdom'),
	('seed-brand-aspegic', 'seed-country-united-states'),
	('seed-brand-aspegic', 'seed-country-uruguay'),
	('seed-brand-aspegic', 'seed-country-uzbekistan'),
	('seed-brand-aspegic', 'seed-country-venezuela'),
	('seed-brand-aspegic', 'seed-country-vietnam'),
	('seed-brand-aspercreme', 'seed-country-united-states'),
	('seed-brand-baralgin', 'seed-country-russia'),
	('seed-brand-bioflorin', 'seed-country-switzerland'),
	('seed-brand-bisolvon', 'seed-country-argentina'),
	('seed-brand-bisolvon', 'seed-country-australia'),
	('seed-brand-bisolvon', 'seed-country-austria'),
	('seed-brand-bisolvon', 'seed-country-azerbaijan'),
	('seed-brand-bisolvon', 'seed-country-belarus'),
	('seed-brand-bisolvon', 'seed-country-belgium'),
	('seed-brand-bisolvon', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-bisolvon', 'seed-country-brazil'),
	('seed-brand-bisolvon', 'seed-country-bulgaria'),
	('seed-brand-bisolvon', 'seed-country-burundi'),
	('seed-brand-bisolvon', 'seed-country-cambodia'),
	('seed-brand-bisolvon', 'seed-country-canada'),
	('seed-brand-bisolvon', 'seed-country-chile'),
	('seed-brand-bisolvon', 'seed-country-china'),
	('seed-brand-bisolvon', 'seed-country-colombia'),
	('seed-brand-bisolvon', 'seed-country-croatia'),
	('seed-brand-bisolvon', 'seed-country-czech-republic'),
	('seed-brand-bisolvon', 'seed-country-denmark'),
	('seed-brand-bisolvon', 'seed-country-dominican-republic'),
	('seed-brand-bisolvon', 'seed-country-ecuador'),
	('seed-brand-bisolvon', 'seed-country-egypt'),
	('seed-brand-bisolvon', 'seed-country-estonia'),
	('seed-brand-bisolvon', 'seed-country-finland'),
	('seed-brand-bisolvon', 'seed-country-france'),
	('seed-brand-bisolvon', 'seed-country-georgia'),
	('seed-brand-bisolvon', 'seed-country-germany'),
	('seed-brand-bisolvon', 'seed-country-greece'),
	('seed-brand-bisolvon', 'seed-country-hong-kong'),
	('seed-brand-bisolvon', 'seed-country-hungary'),
	('seed-brand-bisolvon', 'seed-country-india'),
	('seed-brand-bisolvon', 'seed-country-indonesia'),
	('seed-brand-bisolvon', 'seed-country-ireland'),
	('seed-brand-bisolvon', 'seed-country-israel'),
	('seed-brand-bisolvon', 'seed-country-italy'),
	('seed-brand-bisolvon', 'seed-country-japan'),
	('seed-brand-bisolvon', 'seed-country-kazakhstan'),
	('seed-brand-bisolvon', 'seed-country-latvia'),
	('seed-brand-bisolvon', 'seed-country-lithuania'),
	('seed-brand-bisolvon', 'seed-country-luxembourg'),
	('seed-brand-bisolvon', 'seed-country-malaysia'),
	('seed-brand-bisolvon', 'seed-country-mexico'),
	('seed-brand-bisolvon', 'seed-country-montenegro'),
	('seed-brand-bisolvon', 'seed-country-netherlands'),
	('seed-brand-bisolvon', 'seed-country-new-zealand'),
	('seed-brand-bisolvon', 'seed-country-norway'),
	('seed-brand-bisolvon', 'seed-country-pakistan'),
	('seed-brand-bisolvon', 'seed-country-peru'),
	('seed-brand-bisolvon', 'seed-country-philippines');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-bisolvon', 'seed-country-poland'),
	('seed-brand-bisolvon', 'seed-country-portugal'),
	('seed-brand-bisolvon', 'seed-country-romania'),
	('seed-brand-bisolvon', 'seed-country-russia'),
	('seed-brand-bisolvon', 'seed-country-saudi-arabia'),
	('seed-brand-bisolvon', 'seed-country-serbia'),
	('seed-brand-bisolvon', 'seed-country-singapore'),
	('seed-brand-bisolvon', 'seed-country-slovakia'),
	('seed-brand-bisolvon', 'seed-country-south-africa'),
	('seed-brand-bisolvon', 'seed-country-south-korea'),
	('seed-brand-bisolvon', 'seed-country-spain'),
	('seed-brand-bisolvon', 'seed-country-sweden'),
	('seed-brand-bisolvon', 'seed-country-switzerland'),
	('seed-brand-bisolvon', 'seed-country-thailand'),
	('seed-brand-bisolvon', 'seed-country-turkey'),
	('seed-brand-bisolvon', 'seed-country-ukraine'),
	('seed-brand-bisolvon', 'seed-country-united-arab-emirates'),
	('seed-brand-bisolvon', 'seed-country-united-kingdom'),
	('seed-brand-bisolvon', 'seed-country-united-states'),
	('seed-brand-bisolvon', 'seed-country-uruguay'),
	('seed-brand-bisolvon', 'seed-country-uzbekistan'),
	('seed-brand-bisolvon', 'seed-country-venezuela'),
	('seed-brand-bisolvon', 'seed-country-vietnam'),
	('seed-brand-bronchi', 'seed-country-egypt'),
	('seed-brand-bronchi', 'seed-country-saudi-arabia'),
	('seed-brand-bronchi', 'seed-country-united-arab-emirates'),
	('seed-brand-buscamint', 'seed-country-chile'),
	('seed-brand-buscamint', 'seed-country-venezuela'),
	('seed-brand-buscofen', 'seed-country-italy'),
	('seed-brand-buscopan', 'seed-country-argentina'),
	('seed-brand-buscopan', 'seed-country-australia'),
	('seed-brand-buscopan', 'seed-country-austria'),
	('seed-brand-buscopan', 'seed-country-azerbaijan'),
	('seed-brand-buscopan', 'seed-country-belarus'),
	('seed-brand-buscopan', 'seed-country-belgium'),
	('seed-brand-buscopan', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-buscopan', 'seed-country-brazil'),
	('seed-brand-buscopan', 'seed-country-bulgaria'),
	('seed-brand-buscopan', 'seed-country-burundi'),
	('seed-brand-buscopan', 'seed-country-cambodia'),
	('seed-brand-buscopan', 'seed-country-canada'),
	('seed-brand-buscopan', 'seed-country-chile'),
	('seed-brand-buscopan', 'seed-country-china'),
	('seed-brand-buscopan', 'seed-country-colombia'),
	('seed-brand-buscopan', 'seed-country-croatia'),
	('seed-brand-buscopan', 'seed-country-czech-republic'),
	('seed-brand-buscopan', 'seed-country-denmark'),
	('seed-brand-buscopan', 'seed-country-dominican-republic'),
	('seed-brand-buscopan', 'seed-country-ecuador'),
	('seed-brand-buscopan', 'seed-country-egypt'),
	('seed-brand-buscopan', 'seed-country-estonia'),
	('seed-brand-buscopan', 'seed-country-finland'),
	('seed-brand-buscopan', 'seed-country-france'),
	('seed-brand-buscopan', 'seed-country-georgia'),
	('seed-brand-buscopan', 'seed-country-germany'),
	('seed-brand-buscopan', 'seed-country-greece'),
	('seed-brand-buscopan', 'seed-country-hong-kong'),
	('seed-brand-buscopan', 'seed-country-hungary'),
	('seed-brand-buscopan', 'seed-country-india'),
	('seed-brand-buscopan', 'seed-country-indonesia'),
	('seed-brand-buscopan', 'seed-country-ireland'),
	('seed-brand-buscopan', 'seed-country-israel'),
	('seed-brand-buscopan', 'seed-country-italy'),
	('seed-brand-buscopan', 'seed-country-japan'),
	('seed-brand-buscopan', 'seed-country-kazakhstan'),
	('seed-brand-buscopan', 'seed-country-latvia'),
	('seed-brand-buscopan', 'seed-country-lithuania'),
	('seed-brand-buscopan', 'seed-country-luxembourg'),
	('seed-brand-buscopan', 'seed-country-malaysia'),
	('seed-brand-buscopan', 'seed-country-mexico'),
	('seed-brand-buscopan', 'seed-country-montenegro'),
	('seed-brand-buscopan', 'seed-country-netherlands'),
	('seed-brand-buscopan', 'seed-country-new-zealand'),
	('seed-brand-buscopan', 'seed-country-norway'),
	('seed-brand-buscopan', 'seed-country-pakistan'),
	('seed-brand-buscopan', 'seed-country-peru'),
	('seed-brand-buscopan', 'seed-country-philippines'),
	('seed-brand-buscopan', 'seed-country-poland'),
	('seed-brand-buscopan', 'seed-country-portugal'),
	('seed-brand-buscopan', 'seed-country-romania'),
	('seed-brand-buscopan', 'seed-country-russia'),
	('seed-brand-buscopan', 'seed-country-saudi-arabia'),
	('seed-brand-buscopan', 'seed-country-serbia'),
	('seed-brand-buscopan', 'seed-country-singapore'),
	('seed-brand-buscopan', 'seed-country-slovakia'),
	('seed-brand-buscopan', 'seed-country-south-africa'),
	('seed-brand-buscopan', 'seed-country-south-korea'),
	('seed-brand-buscopan', 'seed-country-spain'),
	('seed-brand-buscopan', 'seed-country-sweden'),
	('seed-brand-buscopan', 'seed-country-switzerland'),
	('seed-brand-buscopan', 'seed-country-thailand'),
	('seed-brand-buscopan', 'seed-country-turkey'),
	('seed-brand-buscopan', 'seed-country-ukraine'),
	('seed-brand-buscopan', 'seed-country-united-arab-emirates'),
	('seed-brand-buscopan', 'seed-country-united-kingdom'),
	('seed-brand-buscopan', 'seed-country-united-states'),
	('seed-brand-buscopan', 'seed-country-uruguay'),
	('seed-brand-buscopan', 'seed-country-uzbekistan'),
	('seed-brand-buscopan', 'seed-country-venezuela'),
	('seed-brand-buscopan', 'seed-country-vietnam');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-calcium-corbiere', 'seed-country-vietnam'),
	('seed-brand-cenovis', 'seed-country-argentina'),
	('seed-brand-cenovis', 'seed-country-australia'),
	('seed-brand-cenovis', 'seed-country-austria'),
	('seed-brand-cenovis', 'seed-country-azerbaijan'),
	('seed-brand-cenovis', 'seed-country-belarus'),
	('seed-brand-cenovis', 'seed-country-belgium'),
	('seed-brand-cenovis', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-cenovis', 'seed-country-brazil'),
	('seed-brand-cenovis', 'seed-country-bulgaria'),
	('seed-brand-cenovis', 'seed-country-burundi'),
	('seed-brand-cenovis', 'seed-country-cambodia'),
	('seed-brand-cenovis', 'seed-country-canada'),
	('seed-brand-cenovis', 'seed-country-chile'),
	('seed-brand-cenovis', 'seed-country-china'),
	('seed-brand-cenovis', 'seed-country-colombia'),
	('seed-brand-cenovis', 'seed-country-croatia'),
	('seed-brand-cenovis', 'seed-country-czech-republic'),
	('seed-brand-cenovis', 'seed-country-denmark'),
	('seed-brand-cenovis', 'seed-country-dominican-republic'),
	('seed-brand-cenovis', 'seed-country-ecuador'),
	('seed-brand-cenovis', 'seed-country-egypt'),
	('seed-brand-cenovis', 'seed-country-estonia'),
	('seed-brand-cenovis', 'seed-country-finland'),
	('seed-brand-cenovis', 'seed-country-france'),
	('seed-brand-cenovis', 'seed-country-georgia'),
	('seed-brand-cenovis', 'seed-country-germany'),
	('seed-brand-cenovis', 'seed-country-greece'),
	('seed-brand-cenovis', 'seed-country-hong-kong'),
	('seed-brand-cenovis', 'seed-country-hungary'),
	('seed-brand-cenovis', 'seed-country-india'),
	('seed-brand-cenovis', 'seed-country-indonesia'),
	('seed-brand-cenovis', 'seed-country-ireland'),
	('seed-brand-cenovis', 'seed-country-israel'),
	('seed-brand-cenovis', 'seed-country-italy'),
	('seed-brand-cenovis', 'seed-country-japan'),
	('seed-brand-cenovis', 'seed-country-kazakhstan'),
	('seed-brand-cenovis', 'seed-country-latvia'),
	('seed-brand-cenovis', 'seed-country-lithuania'),
	('seed-brand-cenovis', 'seed-country-luxembourg'),
	('seed-brand-cenovis', 'seed-country-malaysia'),
	('seed-brand-cenovis', 'seed-country-mexico'),
	('seed-brand-cenovis', 'seed-country-montenegro'),
	('seed-brand-cenovis', 'seed-country-netherlands'),
	('seed-brand-cenovis', 'seed-country-new-zealand'),
	('seed-brand-cenovis', 'seed-country-norway'),
	('seed-brand-cenovis', 'seed-country-pakistan'),
	('seed-brand-cenovis', 'seed-country-peru'),
	('seed-brand-cenovis', 'seed-country-philippines'),
	('seed-brand-cenovis', 'seed-country-poland'),
	('seed-brand-cenovis', 'seed-country-portugal'),
	('seed-brand-cenovis', 'seed-country-romania'),
	('seed-brand-cenovis', 'seed-country-russia'),
	('seed-brand-cenovis', 'seed-country-saudi-arabia'),
	('seed-brand-cenovis', 'seed-country-serbia'),
	('seed-brand-cenovis', 'seed-country-singapore'),
	('seed-brand-cenovis', 'seed-country-slovakia'),
	('seed-brand-cenovis', 'seed-country-south-africa'),
	('seed-brand-cenovis', 'seed-country-south-korea'),
	('seed-brand-cenovis', 'seed-country-spain'),
	('seed-brand-cenovis', 'seed-country-sweden'),
	('seed-brand-cenovis', 'seed-country-switzerland'),
	('seed-brand-cenovis', 'seed-country-thailand'),
	('seed-brand-cenovis', 'seed-country-turkey'),
	('seed-brand-cenovis', 'seed-country-ukraine'),
	('seed-brand-cenovis', 'seed-country-united-arab-emirates'),
	('seed-brand-cenovis', 'seed-country-united-kingdom'),
	('seed-brand-cenovis', 'seed-country-united-states'),
	('seed-brand-cenovis', 'seed-country-uruguay'),
	('seed-brand-cenovis', 'seed-country-uzbekistan'),
	('seed-brand-cenovis', 'seed-country-venezuela'),
	('seed-brand-cenovis', 'seed-country-vietnam'),
	('seed-brand-cialis', 'seed-country-canada'),
	('seed-brand-cialis', 'seed-country-germany'),
	('seed-brand-cialis', 'seed-country-ireland'),
	('seed-brand-cialis', 'seed-country-japan'),
	('seed-brand-cialis', 'seed-country-norway'),
	('seed-brand-cialis', 'seed-country-united-kingdom'),
	('seed-brand-cortizone-10', 'seed-country-argentina'),
	('seed-brand-cortizone-10', 'seed-country-australia'),
	('seed-brand-cortizone-10', 'seed-country-austria'),
	('seed-brand-cortizone-10', 'seed-country-azerbaijan'),
	('seed-brand-cortizone-10', 'seed-country-belarus'),
	('seed-brand-cortizone-10', 'seed-country-belgium'),
	('seed-brand-cortizone-10', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-cortizone-10', 'seed-country-brazil'),
	('seed-brand-cortizone-10', 'seed-country-bulgaria'),
	('seed-brand-cortizone-10', 'seed-country-burundi'),
	('seed-brand-cortizone-10', 'seed-country-cambodia'),
	('seed-brand-cortizone-10', 'seed-country-canada'),
	('seed-brand-cortizone-10', 'seed-country-chile'),
	('seed-brand-cortizone-10', 'seed-country-china'),
	('seed-brand-cortizone-10', 'seed-country-colombia'),
	('seed-brand-cortizone-10', 'seed-country-croatia'),
	('seed-brand-cortizone-10', 'seed-country-czech-republic'),
	('seed-brand-cortizone-10', 'seed-country-denmark'),
	('seed-brand-cortizone-10', 'seed-country-dominican-republic'),
	('seed-brand-cortizone-10', 'seed-country-ecuador'),
	('seed-brand-cortizone-10', 'seed-country-egypt'),
	('seed-brand-cortizone-10', 'seed-country-estonia');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-cortizone-10', 'seed-country-finland'),
	('seed-brand-cortizone-10', 'seed-country-france'),
	('seed-brand-cortizone-10', 'seed-country-georgia'),
	('seed-brand-cortizone-10', 'seed-country-germany'),
	('seed-brand-cortizone-10', 'seed-country-greece'),
	('seed-brand-cortizone-10', 'seed-country-hong-kong'),
	('seed-brand-cortizone-10', 'seed-country-hungary'),
	('seed-brand-cortizone-10', 'seed-country-india'),
	('seed-brand-cortizone-10', 'seed-country-indonesia'),
	('seed-brand-cortizone-10', 'seed-country-ireland'),
	('seed-brand-cortizone-10', 'seed-country-israel'),
	('seed-brand-cortizone-10', 'seed-country-italy'),
	('seed-brand-cortizone-10', 'seed-country-japan'),
	('seed-brand-cortizone-10', 'seed-country-kazakhstan'),
	('seed-brand-cortizone-10', 'seed-country-latvia'),
	('seed-brand-cortizone-10', 'seed-country-lithuania'),
	('seed-brand-cortizone-10', 'seed-country-luxembourg'),
	('seed-brand-cortizone-10', 'seed-country-malaysia'),
	('seed-brand-cortizone-10', 'seed-country-mexico'),
	('seed-brand-cortizone-10', 'seed-country-montenegro'),
	('seed-brand-cortizone-10', 'seed-country-netherlands'),
	('seed-brand-cortizone-10', 'seed-country-new-zealand'),
	('seed-brand-cortizone-10', 'seed-country-norway'),
	('seed-brand-cortizone-10', 'seed-country-pakistan'),
	('seed-brand-cortizone-10', 'seed-country-peru'),
	('seed-brand-cortizone-10', 'seed-country-philippines'),
	('seed-brand-cortizone-10', 'seed-country-poland'),
	('seed-brand-cortizone-10', 'seed-country-portugal'),
	('seed-brand-cortizone-10', 'seed-country-romania'),
	('seed-brand-cortizone-10', 'seed-country-russia'),
	('seed-brand-cortizone-10', 'seed-country-saudi-arabia'),
	('seed-brand-cortizone-10', 'seed-country-serbia'),
	('seed-brand-cortizone-10', 'seed-country-singapore'),
	('seed-brand-cortizone-10', 'seed-country-slovakia'),
	('seed-brand-cortizone-10', 'seed-country-south-africa'),
	('seed-brand-cortizone-10', 'seed-country-south-korea'),
	('seed-brand-cortizone-10', 'seed-country-spain'),
	('seed-brand-cortizone-10', 'seed-country-sweden'),
	('seed-brand-cortizone-10', 'seed-country-switzerland'),
	('seed-brand-cortizone-10', 'seed-country-thailand'),
	('seed-brand-cortizone-10', 'seed-country-turkey'),
	('seed-brand-cortizone-10', 'seed-country-ukraine'),
	('seed-brand-cortizone-10', 'seed-country-united-arab-emirates'),
	('seed-brand-cortizone-10', 'seed-country-united-kingdom'),
	('seed-brand-cortizone-10', 'seed-country-united-states'),
	('seed-brand-cortizone-10', 'seed-country-uruguay'),
	('seed-brand-cortizone-10', 'seed-country-uzbekistan'),
	('seed-brand-cortizone-10', 'seed-country-venezuela'),
	('seed-brand-cortizone-10', 'seed-country-vietnam'),
	('seed-brand-despreconstipatie', 'seed-country-romania'),
	('seed-brand-dicarbocalm', 'seed-country-romania'),
	('seed-brand-dolihume', 'seed-country-argentina'),
	('seed-brand-dolihume', 'seed-country-australia'),
	('seed-brand-dolihume', 'seed-country-austria'),
	('seed-brand-dolihume', 'seed-country-azerbaijan'),
	('seed-brand-dolihume', 'seed-country-belarus'),
	('seed-brand-dolihume', 'seed-country-belgium'),
	('seed-brand-dolihume', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-dolihume', 'seed-country-brazil'),
	('seed-brand-dolihume', 'seed-country-bulgaria'),
	('seed-brand-dolihume', 'seed-country-burundi'),
	('seed-brand-dolihume', 'seed-country-cambodia'),
	('seed-brand-dolihume', 'seed-country-canada'),
	('seed-brand-dolihume', 'seed-country-chile'),
	('seed-brand-dolihume', 'seed-country-china'),
	('seed-brand-dolihume', 'seed-country-colombia'),
	('seed-brand-dolihume', 'seed-country-croatia'),
	('seed-brand-dolihume', 'seed-country-czech-republic'),
	('seed-brand-dolihume', 'seed-country-denmark'),
	('seed-brand-dolihume', 'seed-country-dominican-republic'),
	('seed-brand-dolihume', 'seed-country-ecuador'),
	('seed-brand-dolihume', 'seed-country-egypt'),
	('seed-brand-dolihume', 'seed-country-estonia'),
	('seed-brand-dolihume', 'seed-country-finland'),
	('seed-brand-dolihume', 'seed-country-france'),
	('seed-brand-dolihume', 'seed-country-georgia'),
	('seed-brand-dolihume', 'seed-country-germany'),
	('seed-brand-dolihume', 'seed-country-greece'),
	('seed-brand-dolihume', 'seed-country-hong-kong'),
	('seed-brand-dolihume', 'seed-country-hungary'),
	('seed-brand-dolihume', 'seed-country-india'),
	('seed-brand-dolihume', 'seed-country-indonesia'),
	('seed-brand-dolihume', 'seed-country-ireland'),
	('seed-brand-dolihume', 'seed-country-israel'),
	('seed-brand-dolihume', 'seed-country-italy'),
	('seed-brand-dolihume', 'seed-country-japan'),
	('seed-brand-dolihume', 'seed-country-kazakhstan'),
	('seed-brand-dolihume', 'seed-country-latvia'),
	('seed-brand-dolihume', 'seed-country-lithuania'),
	('seed-brand-dolihume', 'seed-country-luxembourg'),
	('seed-brand-dolihume', 'seed-country-malaysia'),
	('seed-brand-dolihume', 'seed-country-mexico'),
	('seed-brand-dolihume', 'seed-country-montenegro'),
	('seed-brand-dolihume', 'seed-country-netherlands'),
	('seed-brand-dolihume', 'seed-country-new-zealand'),
	('seed-brand-dolihume', 'seed-country-norway'),
	('seed-brand-dolihume', 'seed-country-pakistan'),
	('seed-brand-dolihume', 'seed-country-peru'),
	('seed-brand-dolihume', 'seed-country-philippines'),
	('seed-brand-dolihume', 'seed-country-poland');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-dolihume', 'seed-country-portugal'),
	('seed-brand-dolihume', 'seed-country-romania'),
	('seed-brand-dolihume', 'seed-country-russia'),
	('seed-brand-dolihume', 'seed-country-saudi-arabia'),
	('seed-brand-dolihume', 'seed-country-serbia'),
	('seed-brand-dolihume', 'seed-country-singapore'),
	('seed-brand-dolihume', 'seed-country-slovakia'),
	('seed-brand-dolihume', 'seed-country-south-africa'),
	('seed-brand-dolihume', 'seed-country-south-korea'),
	('seed-brand-dolihume', 'seed-country-spain'),
	('seed-brand-dolihume', 'seed-country-sweden'),
	('seed-brand-dolihume', 'seed-country-switzerland'),
	('seed-brand-dolihume', 'seed-country-thailand'),
	('seed-brand-dolihume', 'seed-country-turkey'),
	('seed-brand-dolihume', 'seed-country-ukraine'),
	('seed-brand-dolihume', 'seed-country-united-arab-emirates'),
	('seed-brand-dolihume', 'seed-country-united-kingdom'),
	('seed-brand-dolihume', 'seed-country-united-states'),
	('seed-brand-dolihume', 'seed-country-uruguay'),
	('seed-brand-dolihume', 'seed-country-uzbekistan'),
	('seed-brand-dolihume', 'seed-country-venezuela'),
	('seed-brand-dolihume', 'seed-country-vietnam'),
	('seed-brand-doliprane', 'seed-country-argentina'),
	('seed-brand-doliprane', 'seed-country-australia'),
	('seed-brand-doliprane', 'seed-country-austria'),
	('seed-brand-doliprane', 'seed-country-azerbaijan'),
	('seed-brand-doliprane', 'seed-country-belarus'),
	('seed-brand-doliprane', 'seed-country-belgium'),
	('seed-brand-doliprane', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-doliprane', 'seed-country-brazil'),
	('seed-brand-doliprane', 'seed-country-bulgaria'),
	('seed-brand-doliprane', 'seed-country-burundi'),
	('seed-brand-doliprane', 'seed-country-cambodia'),
	('seed-brand-doliprane', 'seed-country-canada'),
	('seed-brand-doliprane', 'seed-country-chile'),
	('seed-brand-doliprane', 'seed-country-china'),
	('seed-brand-doliprane', 'seed-country-colombia'),
	('seed-brand-doliprane', 'seed-country-croatia'),
	('seed-brand-doliprane', 'seed-country-czech-republic'),
	('seed-brand-doliprane', 'seed-country-denmark'),
	('seed-brand-doliprane', 'seed-country-dominican-republic'),
	('seed-brand-doliprane', 'seed-country-ecuador'),
	('seed-brand-doliprane', 'seed-country-egypt'),
	('seed-brand-doliprane', 'seed-country-estonia'),
	('seed-brand-doliprane', 'seed-country-finland'),
	('seed-brand-doliprane', 'seed-country-france'),
	('seed-brand-doliprane', 'seed-country-georgia'),
	('seed-brand-doliprane', 'seed-country-germany'),
	('seed-brand-doliprane', 'seed-country-greece'),
	('seed-brand-doliprane', 'seed-country-hong-kong'),
	('seed-brand-doliprane', 'seed-country-hungary'),
	('seed-brand-doliprane', 'seed-country-india'),
	('seed-brand-doliprane', 'seed-country-indonesia'),
	('seed-brand-doliprane', 'seed-country-ireland'),
	('seed-brand-doliprane', 'seed-country-israel'),
	('seed-brand-doliprane', 'seed-country-italy'),
	('seed-brand-doliprane', 'seed-country-japan'),
	('seed-brand-doliprane', 'seed-country-kazakhstan'),
	('seed-brand-doliprane', 'seed-country-latvia'),
	('seed-brand-doliprane', 'seed-country-lithuania'),
	('seed-brand-doliprane', 'seed-country-luxembourg'),
	('seed-brand-doliprane', 'seed-country-malaysia'),
	('seed-brand-doliprane', 'seed-country-mexico'),
	('seed-brand-doliprane', 'seed-country-montenegro'),
	('seed-brand-doliprane', 'seed-country-netherlands'),
	('seed-brand-doliprane', 'seed-country-new-zealand'),
	('seed-brand-doliprane', 'seed-country-norway'),
	('seed-brand-doliprane', 'seed-country-pakistan'),
	('seed-brand-doliprane', 'seed-country-peru'),
	('seed-brand-doliprane', 'seed-country-philippines'),
	('seed-brand-doliprane', 'seed-country-poland'),
	('seed-brand-doliprane', 'seed-country-portugal'),
	('seed-brand-doliprane', 'seed-country-romania'),
	('seed-brand-doliprane', 'seed-country-russia'),
	('seed-brand-doliprane', 'seed-country-saudi-arabia'),
	('seed-brand-doliprane', 'seed-country-serbia'),
	('seed-brand-doliprane', 'seed-country-singapore'),
	('seed-brand-doliprane', 'seed-country-slovakia'),
	('seed-brand-doliprane', 'seed-country-south-africa'),
	('seed-brand-doliprane', 'seed-country-south-korea'),
	('seed-brand-doliprane', 'seed-country-spain'),
	('seed-brand-doliprane', 'seed-country-sweden'),
	('seed-brand-doliprane', 'seed-country-switzerland'),
	('seed-brand-doliprane', 'seed-country-thailand'),
	('seed-brand-doliprane', 'seed-country-turkey'),
	('seed-brand-doliprane', 'seed-country-ukraine'),
	('seed-brand-doliprane', 'seed-country-united-arab-emirates'),
	('seed-brand-doliprane', 'seed-country-united-kingdom'),
	('seed-brand-doliprane', 'seed-country-united-states'),
	('seed-brand-doliprane', 'seed-country-uruguay'),
	('seed-brand-doliprane', 'seed-country-uzbekistan'),
	('seed-brand-doliprane', 'seed-country-venezuela'),
	('seed-brand-doliprane', 'seed-country-vietnam'),
	('seed-brand-dorflex', 'seed-country-brazil'),
	('seed-brand-dulcogas', 'seed-country-norway'),
	('seed-brand-dulcogas', 'seed-country-sweden'),
	('seed-brand-dulcogas', 'seed-country-turkey'),
	('seed-brand-dulcolax', 'seed-country-argentina'),
	('seed-brand-dulcolax', 'seed-country-australia'),
	('seed-brand-dulcolax', 'seed-country-austria');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-dulcolax', 'seed-country-azerbaijan'),
	('seed-brand-dulcolax', 'seed-country-belarus'),
	('seed-brand-dulcolax', 'seed-country-belgium'),
	('seed-brand-dulcolax', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-dulcolax', 'seed-country-brazil'),
	('seed-brand-dulcolax', 'seed-country-bulgaria'),
	('seed-brand-dulcolax', 'seed-country-burundi'),
	('seed-brand-dulcolax', 'seed-country-cambodia'),
	('seed-brand-dulcolax', 'seed-country-canada'),
	('seed-brand-dulcolax', 'seed-country-chile'),
	('seed-brand-dulcolax', 'seed-country-china'),
	('seed-brand-dulcolax', 'seed-country-colombia'),
	('seed-brand-dulcolax', 'seed-country-croatia'),
	('seed-brand-dulcolax', 'seed-country-czech-republic'),
	('seed-brand-dulcolax', 'seed-country-denmark'),
	('seed-brand-dulcolax', 'seed-country-dominican-republic'),
	('seed-brand-dulcolax', 'seed-country-ecuador'),
	('seed-brand-dulcolax', 'seed-country-egypt'),
	('seed-brand-dulcolax', 'seed-country-estonia'),
	('seed-brand-dulcolax', 'seed-country-finland'),
	('seed-brand-dulcolax', 'seed-country-france'),
	('seed-brand-dulcolax', 'seed-country-georgia'),
	('seed-brand-dulcolax', 'seed-country-germany'),
	('seed-brand-dulcolax', 'seed-country-greece'),
	('seed-brand-dulcolax', 'seed-country-hong-kong'),
	('seed-brand-dulcolax', 'seed-country-hungary'),
	('seed-brand-dulcolax', 'seed-country-india'),
	('seed-brand-dulcolax', 'seed-country-indonesia'),
	('seed-brand-dulcolax', 'seed-country-ireland'),
	('seed-brand-dulcolax', 'seed-country-israel'),
	('seed-brand-dulcolax', 'seed-country-italy'),
	('seed-brand-dulcolax', 'seed-country-japan'),
	('seed-brand-dulcolax', 'seed-country-kazakhstan'),
	('seed-brand-dulcolax', 'seed-country-latvia'),
	('seed-brand-dulcolax', 'seed-country-lithuania'),
	('seed-brand-dulcolax', 'seed-country-luxembourg'),
	('seed-brand-dulcolax', 'seed-country-malaysia'),
	('seed-brand-dulcolax', 'seed-country-mexico'),
	('seed-brand-dulcolax', 'seed-country-montenegro'),
	('seed-brand-dulcolax', 'seed-country-netherlands'),
	('seed-brand-dulcolax', 'seed-country-new-zealand'),
	('seed-brand-dulcolax', 'seed-country-norway'),
	('seed-brand-dulcolax', 'seed-country-pakistan'),
	('seed-brand-dulcolax', 'seed-country-peru'),
	('seed-brand-dulcolax', 'seed-country-philippines'),
	('seed-brand-dulcolax', 'seed-country-poland'),
	('seed-brand-dulcolax', 'seed-country-portugal'),
	('seed-brand-dulcolax', 'seed-country-romania'),
	('seed-brand-dulcolax', 'seed-country-russia'),
	('seed-brand-dulcolax', 'seed-country-saudi-arabia'),
	('seed-brand-dulcolax', 'seed-country-serbia'),
	('seed-brand-dulcolax', 'seed-country-singapore'),
	('seed-brand-dulcolax', 'seed-country-slovakia'),
	('seed-brand-dulcolax', 'seed-country-south-africa'),
	('seed-brand-dulcolax', 'seed-country-south-korea'),
	('seed-brand-dulcolax', 'seed-country-spain'),
	('seed-brand-dulcolax', 'seed-country-sweden'),
	('seed-brand-dulcolax', 'seed-country-switzerland'),
	('seed-brand-dulcolax', 'seed-country-thailand'),
	('seed-brand-dulcolax', 'seed-country-turkey'),
	('seed-brand-dulcolax', 'seed-country-ukraine'),
	('seed-brand-dulcolax', 'seed-country-united-arab-emirates'),
	('seed-brand-dulcolax', 'seed-country-united-kingdom'),
	('seed-brand-dulcolax', 'seed-country-united-states'),
	('seed-brand-dulcolax', 'seed-country-uruguay'),
	('seed-brand-dulcolax', 'seed-country-uzbekistan'),
	('seed-brand-dulcolax', 'seed-country-venezuela'),
	('seed-brand-dulcolax', 'seed-country-vietnam'),
	('seed-brand-dulconatural', 'seed-country-argentina'),
	('seed-brand-dulconatural', 'seed-country-australia'),
	('seed-brand-dulconatural', 'seed-country-austria'),
	('seed-brand-dulconatural', 'seed-country-azerbaijan'),
	('seed-brand-dulconatural', 'seed-country-belarus'),
	('seed-brand-dulconatural', 'seed-country-belgium'),
	('seed-brand-dulconatural', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-dulconatural', 'seed-country-brazil'),
	('seed-brand-dulconatural', 'seed-country-bulgaria'),
	('seed-brand-dulconatural', 'seed-country-burundi'),
	('seed-brand-dulconatural', 'seed-country-cambodia'),
	('seed-brand-dulconatural', 'seed-country-canada'),
	('seed-brand-dulconatural', 'seed-country-chile'),
	('seed-brand-dulconatural', 'seed-country-china'),
	('seed-brand-dulconatural', 'seed-country-colombia'),
	('seed-brand-dulconatural', 'seed-country-croatia'),
	('seed-brand-dulconatural', 'seed-country-czech-republic'),
	('seed-brand-dulconatural', 'seed-country-denmark'),
	('seed-brand-dulconatural', 'seed-country-dominican-republic'),
	('seed-brand-dulconatural', 'seed-country-ecuador'),
	('seed-brand-dulconatural', 'seed-country-egypt'),
	('seed-brand-dulconatural', 'seed-country-estonia'),
	('seed-brand-dulconatural', 'seed-country-finland'),
	('seed-brand-dulconatural', 'seed-country-france'),
	('seed-brand-dulconatural', 'seed-country-georgia'),
	('seed-brand-dulconatural', 'seed-country-germany'),
	('seed-brand-dulconatural', 'seed-country-greece'),
	('seed-brand-dulconatural', 'seed-country-hong-kong'),
	('seed-brand-dulconatural', 'seed-country-hungary'),
	('seed-brand-dulconatural', 'seed-country-india'),
	('seed-brand-dulconatural', 'seed-country-indonesia'),
	('seed-brand-dulconatural', 'seed-country-ireland');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-dulconatural', 'seed-country-israel'),
	('seed-brand-dulconatural', 'seed-country-italy'),
	('seed-brand-dulconatural', 'seed-country-japan'),
	('seed-brand-dulconatural', 'seed-country-kazakhstan'),
	('seed-brand-dulconatural', 'seed-country-latvia'),
	('seed-brand-dulconatural', 'seed-country-lithuania'),
	('seed-brand-dulconatural', 'seed-country-luxembourg'),
	('seed-brand-dulconatural', 'seed-country-malaysia'),
	('seed-brand-dulconatural', 'seed-country-mexico'),
	('seed-brand-dulconatural', 'seed-country-montenegro'),
	('seed-brand-dulconatural', 'seed-country-netherlands'),
	('seed-brand-dulconatural', 'seed-country-new-zealand'),
	('seed-brand-dulconatural', 'seed-country-norway'),
	('seed-brand-dulconatural', 'seed-country-pakistan'),
	('seed-brand-dulconatural', 'seed-country-peru'),
	('seed-brand-dulconatural', 'seed-country-philippines'),
	('seed-brand-dulconatural', 'seed-country-poland'),
	('seed-brand-dulconatural', 'seed-country-portugal'),
	('seed-brand-dulconatural', 'seed-country-romania'),
	('seed-brand-dulconatural', 'seed-country-russia'),
	('seed-brand-dulconatural', 'seed-country-saudi-arabia'),
	('seed-brand-dulconatural', 'seed-country-serbia'),
	('seed-brand-dulconatural', 'seed-country-singapore'),
	('seed-brand-dulconatural', 'seed-country-slovakia'),
	('seed-brand-dulconatural', 'seed-country-south-africa'),
	('seed-brand-dulconatural', 'seed-country-south-korea'),
	('seed-brand-dulconatural', 'seed-country-spain'),
	('seed-brand-dulconatural', 'seed-country-sweden'),
	('seed-brand-dulconatural', 'seed-country-switzerland'),
	('seed-brand-dulconatural', 'seed-country-thailand'),
	('seed-brand-dulconatural', 'seed-country-turkey'),
	('seed-brand-dulconatural', 'seed-country-ukraine'),
	('seed-brand-dulconatural', 'seed-country-united-arab-emirates'),
	('seed-brand-dulconatural', 'seed-country-united-kingdom'),
	('seed-brand-dulconatural', 'seed-country-united-states'),
	('seed-brand-dulconatural', 'seed-country-uruguay'),
	('seed-brand-dulconatural', 'seed-country-uzbekistan'),
	('seed-brand-dulconatural', 'seed-country-venezuela'),
	('seed-brand-dulconatural', 'seed-country-vietnam'),
	('seed-brand-dulcoplant', 'seed-country-denmark'),
	('seed-brand-dulcoplant', 'seed-country-sweden'),
	('seed-brand-dulcosoft', 'seed-country-argentina'),
	('seed-brand-dulcosoft', 'seed-country-austria'),
	('seed-brand-dulcosoft', 'seed-country-brazil'),
	('seed-brand-dulcosoft', 'seed-country-czech-republic'),
	('seed-brand-dulcosoft', 'seed-country-france'),
	('seed-brand-dulcosoft', 'seed-country-germany'),
	('seed-brand-dulcosoft', 'seed-country-hungary'),
	('seed-brand-dulcosoft', 'seed-country-india'),
	('seed-brand-dulcosoft', 'seed-country-luxembourg'),
	('seed-brand-dulcosoft', 'seed-country-malaysia'),
	('seed-brand-dulcosoft', 'seed-country-norway'),
	('seed-brand-dulcosoft', 'seed-country-poland'),
	('seed-brand-dulcosoft', 'seed-country-romania'),
	('seed-brand-dulcosoft', 'seed-country-slovakia'),
	('seed-brand-dulcosoft', 'seed-country-turkey'),
	('seed-brand-dulcosoft', 'seed-country-united-states'),
	('seed-brand-dulcosoft', 'seed-country-uruguay'),
	('seed-brand-endiaron', 'seed-country-czech-republic'),
	('seed-brand-enterogermina', 'seed-country-argentina'),
	('seed-brand-enterogermina', 'seed-country-australia'),
	('seed-brand-enterogermina', 'seed-country-austria'),
	('seed-brand-enterogermina', 'seed-country-azerbaijan'),
	('seed-brand-enterogermina', 'seed-country-belarus'),
	('seed-brand-enterogermina', 'seed-country-belgium'),
	('seed-brand-enterogermina', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-enterogermina', 'seed-country-brazil'),
	('seed-brand-enterogermina', 'seed-country-bulgaria'),
	('seed-brand-enterogermina', 'seed-country-burundi'),
	('seed-brand-enterogermina', 'seed-country-cambodia'),
	('seed-brand-enterogermina', 'seed-country-canada'),
	('seed-brand-enterogermina', 'seed-country-chile'),
	('seed-brand-enterogermina', 'seed-country-china'),
	('seed-brand-enterogermina', 'seed-country-colombia'),
	('seed-brand-enterogermina', 'seed-country-croatia'),
	('seed-brand-enterogermina', 'seed-country-czech-republic'),
	('seed-brand-enterogermina', 'seed-country-denmark'),
	('seed-brand-enterogermina', 'seed-country-dominican-republic'),
	('seed-brand-enterogermina', 'seed-country-ecuador'),
	('seed-brand-enterogermina', 'seed-country-egypt'),
	('seed-brand-enterogermina', 'seed-country-estonia'),
	('seed-brand-enterogermina', 'seed-country-finland'),
	('seed-brand-enterogermina', 'seed-country-france'),
	('seed-brand-enterogermina', 'seed-country-georgia'),
	('seed-brand-enterogermina', 'seed-country-germany'),
	('seed-brand-enterogermina', 'seed-country-greece'),
	('seed-brand-enterogermina', 'seed-country-hong-kong'),
	('seed-brand-enterogermina', 'seed-country-hungary'),
	('seed-brand-enterogermina', 'seed-country-india'),
	('seed-brand-enterogermina', 'seed-country-indonesia'),
	('seed-brand-enterogermina', 'seed-country-ireland'),
	('seed-brand-enterogermina', 'seed-country-israel'),
	('seed-brand-enterogermina', 'seed-country-italy'),
	('seed-brand-enterogermina', 'seed-country-japan'),
	('seed-brand-enterogermina', 'seed-country-kazakhstan'),
	('seed-brand-enterogermina', 'seed-country-latvia'),
	('seed-brand-enterogermina', 'seed-country-lithuania'),
	('seed-brand-enterogermina', 'seed-country-luxembourg'),
	('seed-brand-enterogermina', 'seed-country-malaysia'),
	('seed-brand-enterogermina', 'seed-country-mexico');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-enterogermina', 'seed-country-montenegro'),
	('seed-brand-enterogermina', 'seed-country-netherlands'),
	('seed-brand-enterogermina', 'seed-country-new-zealand'),
	('seed-brand-enterogermina', 'seed-country-norway'),
	('seed-brand-enterogermina', 'seed-country-pakistan'),
	('seed-brand-enterogermina', 'seed-country-peru'),
	('seed-brand-enterogermina', 'seed-country-philippines'),
	('seed-brand-enterogermina', 'seed-country-poland'),
	('seed-brand-enterogermina', 'seed-country-portugal'),
	('seed-brand-enterogermina', 'seed-country-romania'),
	('seed-brand-enterogermina', 'seed-country-russia'),
	('seed-brand-enterogermina', 'seed-country-saudi-arabia'),
	('seed-brand-enterogermina', 'seed-country-serbia'),
	('seed-brand-enterogermina', 'seed-country-singapore'),
	('seed-brand-enterogermina', 'seed-country-slovakia'),
	('seed-brand-enterogermina', 'seed-country-south-africa'),
	('seed-brand-enterogermina', 'seed-country-south-korea'),
	('seed-brand-enterogermina', 'seed-country-spain'),
	('seed-brand-enterogermina', 'seed-country-sweden'),
	('seed-brand-enterogermina', 'seed-country-switzerland'),
	('seed-brand-enterogermina', 'seed-country-thailand'),
	('seed-brand-enterogermina', 'seed-country-turkey'),
	('seed-brand-enterogermina', 'seed-country-ukraine'),
	('seed-brand-enterogermina', 'seed-country-united-arab-emirates'),
	('seed-brand-enterogermina', 'seed-country-united-kingdom'),
	('seed-brand-enterogermina', 'seed-country-united-states'),
	('seed-brand-enterogermina', 'seed-country-uruguay'),
	('seed-brand-enterogermina', 'seed-country-uzbekistan'),
	('seed-brand-enterogermina', 'seed-country-venezuela'),
	('seed-brand-enterogermina', 'seed-country-vietnam'),
	('seed-brand-essentiale', 'seed-country-argentina'),
	('seed-brand-essentiale', 'seed-country-australia'),
	('seed-brand-essentiale', 'seed-country-austria'),
	('seed-brand-essentiale', 'seed-country-azerbaijan'),
	('seed-brand-essentiale', 'seed-country-belarus'),
	('seed-brand-essentiale', 'seed-country-belgium'),
	('seed-brand-essentiale', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-essentiale', 'seed-country-brazil'),
	('seed-brand-essentiale', 'seed-country-bulgaria'),
	('seed-brand-essentiale', 'seed-country-burundi'),
	('seed-brand-essentiale', 'seed-country-cambodia'),
	('seed-brand-essentiale', 'seed-country-canada'),
	('seed-brand-essentiale', 'seed-country-chile'),
	('seed-brand-essentiale', 'seed-country-china'),
	('seed-brand-essentiale', 'seed-country-colombia'),
	('seed-brand-essentiale', 'seed-country-croatia'),
	('seed-brand-essentiale', 'seed-country-czech-republic'),
	('seed-brand-essentiale', 'seed-country-denmark'),
	('seed-brand-essentiale', 'seed-country-dominican-republic'),
	('seed-brand-essentiale', 'seed-country-ecuador'),
	('seed-brand-essentiale', 'seed-country-egypt'),
	('seed-brand-essentiale', 'seed-country-estonia'),
	('seed-brand-essentiale', 'seed-country-finland'),
	('seed-brand-essentiale', 'seed-country-france'),
	('seed-brand-essentiale', 'seed-country-georgia'),
	('seed-brand-essentiale', 'seed-country-germany'),
	('seed-brand-essentiale', 'seed-country-greece'),
	('seed-brand-essentiale', 'seed-country-hong-kong'),
	('seed-brand-essentiale', 'seed-country-hungary'),
	('seed-brand-essentiale', 'seed-country-india'),
	('seed-brand-essentiale', 'seed-country-indonesia'),
	('seed-brand-essentiale', 'seed-country-ireland'),
	('seed-brand-essentiale', 'seed-country-israel'),
	('seed-brand-essentiale', 'seed-country-italy'),
	('seed-brand-essentiale', 'seed-country-japan'),
	('seed-brand-essentiale', 'seed-country-kazakhstan'),
	('seed-brand-essentiale', 'seed-country-latvia'),
	('seed-brand-essentiale', 'seed-country-lithuania'),
	('seed-brand-essentiale', 'seed-country-luxembourg'),
	('seed-brand-ibalgin', 'seed-country-italy'),
	('seed-brand-essentiale', 'seed-country-malaysia'),
	('seed-brand-essentiale', 'seed-country-mexico'),
	('seed-brand-essentiale', 'seed-country-montenegro'),
	('seed-brand-essentiale', 'seed-country-netherlands'),
	('seed-brand-essentiale', 'seed-country-new-zealand'),
	('seed-brand-essentiale', 'seed-country-norway'),
	('seed-brand-essentiale', 'seed-country-pakistan'),
	('seed-brand-essentiale', 'seed-country-peru'),
	('seed-brand-essentiale', 'seed-country-philippines'),
	('seed-brand-essentiale', 'seed-country-poland'),
	('seed-brand-essentiale', 'seed-country-portugal'),
	('seed-brand-essentiale', 'seed-country-romania'),
	('seed-brand-essentiale', 'seed-country-russia'),
	('seed-brand-essentiale', 'seed-country-saudi-arabia'),
	('seed-brand-essentiale', 'seed-country-serbia'),
	('seed-brand-essentiale', 'seed-country-singapore'),
	('seed-brand-essentiale', 'seed-country-slovakia'),
	('seed-brand-essentiale', 'seed-country-south-africa'),
	('seed-brand-essentiale', 'seed-country-south-korea'),
	('seed-brand-essentiale', 'seed-country-spain'),
	('seed-brand-essentiale', 'seed-country-sweden'),
	('seed-brand-essentiale', 'seed-country-switzerland'),
	('seed-brand-essentiale', 'seed-country-thailand'),
	('seed-brand-essentiale', 'seed-country-turkey'),
	('seed-brand-essentiale', 'seed-country-ukraine'),
	('seed-brand-essentiale', 'seed-country-united-arab-emirates'),
	('seed-brand-essentiale', 'seed-country-united-kingdom'),
	('seed-brand-essentiale', 'seed-country-united-states'),
	('seed-brand-essentiale', 'seed-country-uruguay'),
	('seed-brand-essentiale', 'seed-country-uzbekistan');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-essentiale', 'seed-country-venezuela'),
	('seed-brand-essentiale', 'seed-country-vietnam'),
	('seed-brand-eve', 'seed-country-japan'),
	('seed-brand-festal', 'seed-country-ukraine'),
	('seed-brand-finalgon', 'seed-country-russia'),
	('seed-brand-flomax', 'seed-country-united-states'),
	('seed-brand-gammelodiprane', 'seed-country-argentina'),
	('seed-brand-gammelodiprane', 'seed-country-australia'),
	('seed-brand-gammelodiprane', 'seed-country-austria'),
	('seed-brand-gammelodiprane', 'seed-country-azerbaijan'),
	('seed-brand-gammelodiprane', 'seed-country-belarus'),
	('seed-brand-gammelodiprane', 'seed-country-belgium'),
	('seed-brand-gammelodiprane', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-gammelodiprane', 'seed-country-brazil'),
	('seed-brand-gammelodiprane', 'seed-country-bulgaria'),
	('seed-brand-gammelodiprane', 'seed-country-burundi'),
	('seed-brand-gammelodiprane', 'seed-country-cambodia'),
	('seed-brand-gammelodiprane', 'seed-country-canada'),
	('seed-brand-gammelodiprane', 'seed-country-chile'),
	('seed-brand-gammelodiprane', 'seed-country-china'),
	('seed-brand-gammelodiprane', 'seed-country-colombia'),
	('seed-brand-gammelodiprane', 'seed-country-croatia'),
	('seed-brand-gammelodiprane', 'seed-country-czech-republic'),
	('seed-brand-gammelodiprane', 'seed-country-denmark'),
	('seed-brand-gammelodiprane', 'seed-country-dominican-republic'),
	('seed-brand-gammelodiprane', 'seed-country-ecuador'),
	('seed-brand-gammelodiprane', 'seed-country-egypt'),
	('seed-brand-gammelodiprane', 'seed-country-estonia'),
	('seed-brand-gammelodiprane', 'seed-country-finland'),
	('seed-brand-gammelodiprane', 'seed-country-france'),
	('seed-brand-gammelodiprane', 'seed-country-georgia'),
	('seed-brand-gammelodiprane', 'seed-country-germany'),
	('seed-brand-gammelodiprane', 'seed-country-greece'),
	('seed-brand-gammelodiprane', 'seed-country-hong-kong'),
	('seed-brand-gammelodiprane', 'seed-country-hungary'),
	('seed-brand-gammelodiprane', 'seed-country-india'),
	('seed-brand-gammelodiprane', 'seed-country-indonesia'),
	('seed-brand-gammelodiprane', 'seed-country-ireland'),
	('seed-brand-gammelodiprane', 'seed-country-israel'),
	('seed-brand-gammelodiprane', 'seed-country-italy'),
	('seed-brand-gammelodiprane', 'seed-country-japan'),
	('seed-brand-gammelodiprane', 'seed-country-kazakhstan'),
	('seed-brand-gammelodiprane', 'seed-country-latvia'),
	('seed-brand-gammelodiprane', 'seed-country-lithuania'),
	('seed-brand-gammelodiprane', 'seed-country-luxembourg'),
	('seed-brand-gammelodiprane', 'seed-country-malaysia'),
	('seed-brand-gammelodiprane', 'seed-country-mexico'),
	('seed-brand-gammelodiprane', 'seed-country-montenegro'),
	('seed-brand-gammelodiprane', 'seed-country-netherlands'),
	('seed-brand-gammelodiprane', 'seed-country-new-zealand'),
	('seed-brand-gammelodiprane', 'seed-country-norway'),
	('seed-brand-gammelodiprane', 'seed-country-pakistan'),
	('seed-brand-gammelodiprane', 'seed-country-peru'),
	('seed-brand-gammelodiprane', 'seed-country-philippines'),
	('seed-brand-gammelodiprane', 'seed-country-poland'),
	('seed-brand-gammelodiprane', 'seed-country-portugal'),
	('seed-brand-gammelodiprane', 'seed-country-romania'),
	('seed-brand-gammelodiprane', 'seed-country-russia'),
	('seed-brand-gammelodiprane', 'seed-country-saudi-arabia'),
	('seed-brand-gammelodiprane', 'seed-country-serbia'),
	('seed-brand-gammelodiprane', 'seed-country-singapore'),
	('seed-brand-gammelodiprane', 'seed-country-slovakia'),
	('seed-brand-gammelodiprane', 'seed-country-south-africa'),
	('seed-brand-gammelodiprane', 'seed-country-south-korea'),
	('seed-brand-gammelodiprane', 'seed-country-spain'),
	('seed-brand-gammelodiprane', 'seed-country-sweden'),
	('seed-brand-gammelodiprane', 'seed-country-switzerland'),
	('seed-brand-gammelodiprane', 'seed-country-thailand'),
	('seed-brand-gammelodiprane', 'seed-country-turkey'),
	('seed-brand-gammelodiprane', 'seed-country-ukraine'),
	('seed-brand-gammelodiprane', 'seed-country-united-arab-emirates'),
	('seed-brand-gammelodiprane', 'seed-country-united-kingdom'),
	('seed-brand-gammelodiprane', 'seed-country-united-states'),
	('seed-brand-gammelodiprane', 'seed-country-uruguay'),
	('seed-brand-gammelodiprane', 'seed-country-uzbekistan'),
	('seed-brand-gammelodiprane', 'seed-country-venezuela'),
	('seed-brand-gammelodiprane', 'seed-country-vietnam'),
	('seed-brand-gelicart', 'seed-country-peru'),
	('seed-brand-goldbond', 'seed-country-canada'),
	('seed-brand-goldbond', 'seed-country-united-states'),
	('seed-brand-guttalax', 'seed-country-argentina'),
	('seed-brand-guttalax', 'seed-country-australia'),
	('seed-brand-guttalax', 'seed-country-austria'),
	('seed-brand-guttalax', 'seed-country-azerbaijan'),
	('seed-brand-guttalax', 'seed-country-belarus'),
	('seed-brand-guttalax', 'seed-country-belgium'),
	('seed-brand-guttalax', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-guttalax', 'seed-country-brazil'),
	('seed-brand-guttalax', 'seed-country-bulgaria'),
	('seed-brand-guttalax', 'seed-country-burundi'),
	('seed-brand-guttalax', 'seed-country-cambodia'),
	('seed-brand-guttalax', 'seed-country-canada'),
	('seed-brand-guttalax', 'seed-country-chile'),
	('seed-brand-guttalax', 'seed-country-china'),
	('seed-brand-guttalax', 'seed-country-colombia'),
	('seed-brand-guttalax', 'seed-country-croatia'),
	('seed-brand-guttalax', 'seed-country-czech-republic'),
	('seed-brand-guttalax', 'seed-country-denmark'),
	('seed-brand-guttalax', 'seed-country-dominican-republic'),
	('seed-brand-guttalax', 'seed-country-ecuador');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-guttalax', 'seed-country-egypt'),
	('seed-brand-guttalax', 'seed-country-estonia'),
	('seed-brand-guttalax', 'seed-country-finland'),
	('seed-brand-guttalax', 'seed-country-france'),
	('seed-brand-guttalax', 'seed-country-georgia'),
	('seed-brand-guttalax', 'seed-country-germany'),
	('seed-brand-guttalax', 'seed-country-greece'),
	('seed-brand-guttalax', 'seed-country-hong-kong'),
	('seed-brand-guttalax', 'seed-country-hungary'),
	('seed-brand-guttalax', 'seed-country-india'),
	('seed-brand-guttalax', 'seed-country-indonesia'),
	('seed-brand-guttalax', 'seed-country-ireland'),
	('seed-brand-guttalax', 'seed-country-israel'),
	('seed-brand-guttalax', 'seed-country-italy'),
	('seed-brand-guttalax', 'seed-country-japan'),
	('seed-brand-guttalax', 'seed-country-kazakhstan'),
	('seed-brand-guttalax', 'seed-country-latvia'),
	('seed-brand-guttalax', 'seed-country-lithuania'),
	('seed-brand-guttalax', 'seed-country-luxembourg'),
	('seed-brand-guttalax', 'seed-country-malaysia'),
	('seed-brand-guttalax', 'seed-country-mexico'),
	('seed-brand-guttalax', 'seed-country-montenegro'),
	('seed-brand-guttalax', 'seed-country-netherlands'),
	('seed-brand-guttalax', 'seed-country-new-zealand'),
	('seed-brand-guttalax', 'seed-country-norway'),
	('seed-brand-guttalax', 'seed-country-pakistan'),
	('seed-brand-guttalax', 'seed-country-peru'),
	('seed-brand-guttalax', 'seed-country-philippines'),
	('seed-brand-guttalax', 'seed-country-poland'),
	('seed-brand-guttalax', 'seed-country-portugal'),
	('seed-brand-guttalax', 'seed-country-romania'),
	('seed-brand-guttalax', 'seed-country-russia'),
	('seed-brand-guttalax', 'seed-country-saudi-arabia'),
	('seed-brand-guttalax', 'seed-country-serbia'),
	('seed-brand-guttalax', 'seed-country-singapore'),
	('seed-brand-guttalax', 'seed-country-slovakia'),
	('seed-brand-guttalax', 'seed-country-south-africa'),
	('seed-brand-guttalax', 'seed-country-south-korea'),
	('seed-brand-guttalax', 'seed-country-spain'),
	('seed-brand-guttalax', 'seed-country-sweden'),
	('seed-brand-guttalax', 'seed-country-switzerland'),
	('seed-brand-guttalax', 'seed-country-thailand'),
	('seed-brand-guttalax', 'seed-country-turkey'),
	('seed-brand-guttalax', 'seed-country-ukraine'),
	('seed-brand-guttalax', 'seed-country-united-arab-emirates'),
	('seed-brand-guttalax', 'seed-country-united-kingdom'),
	('seed-brand-guttalax', 'seed-country-united-states'),
	('seed-brand-guttalax', 'seed-country-uruguay'),
	('seed-brand-guttalax', 'seed-country-uzbekistan'),
	('seed-brand-guttalax', 'seed-country-venezuela'),
	('seed-brand-guttalax', 'seed-country-vietnam'),
	('seed-brand-histiacil', 'seed-country-mexico'),
	('seed-brand-ibalgin', 'seed-country-argentina'),
	('seed-brand-ibalgin', 'seed-country-australia'),
	('seed-brand-ibalgin', 'seed-country-austria'),
	('seed-brand-ibalgin', 'seed-country-azerbaijan'),
	('seed-brand-ibalgin', 'seed-country-belarus'),
	('seed-brand-ibalgin', 'seed-country-belgium'),
	('seed-brand-ibalgin', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-ibalgin', 'seed-country-brazil'),
	('seed-brand-ibalgin', 'seed-country-bulgaria'),
	('seed-brand-ibalgin', 'seed-country-burundi'),
	('seed-brand-ibalgin', 'seed-country-cambodia'),
	('seed-brand-ibalgin', 'seed-country-canada'),
	('seed-brand-ibalgin', 'seed-country-chile'),
	('seed-brand-ibalgin', 'seed-country-china'),
	('seed-brand-ibalgin', 'seed-country-colombia'),
	('seed-brand-ibalgin', 'seed-country-croatia'),
	('seed-brand-ibalgin', 'seed-country-czech-republic'),
	('seed-brand-ibalgin', 'seed-country-denmark'),
	('seed-brand-ibalgin', 'seed-country-dominican-republic'),
	('seed-brand-ibalgin', 'seed-country-ecuador'),
	('seed-brand-ibalgin', 'seed-country-egypt'),
	('seed-brand-ibalgin', 'seed-country-estonia'),
	('seed-brand-ibalgin', 'seed-country-finland'),
	('seed-brand-ibalgin', 'seed-country-france'),
	('seed-brand-ibalgin', 'seed-country-georgia'),
	('seed-brand-ibalgin', 'seed-country-germany'),
	('seed-brand-ibalgin', 'seed-country-greece'),
	('seed-brand-ibalgin', 'seed-country-hong-kong'),
	('seed-brand-ibalgin', 'seed-country-hungary'),
	('seed-brand-ibalgin', 'seed-country-india'),
	('seed-brand-ibalgin', 'seed-country-indonesia'),
	('seed-brand-ibalgin', 'seed-country-ireland'),
	('seed-brand-ibalgin', 'seed-country-israel'),
	('seed-brand-ibalgin', 'seed-country-japan'),
	('seed-brand-ibalgin', 'seed-country-kazakhstan'),
	('seed-brand-ibalgin', 'seed-country-latvia'),
	('seed-brand-ibalgin', 'seed-country-lithuania'),
	('seed-brand-ibalgin', 'seed-country-luxembourg'),
	('seed-brand-ibalgin', 'seed-country-malaysia'),
	('seed-brand-ibalgin', 'seed-country-mexico'),
	('seed-brand-ibalgin', 'seed-country-montenegro'),
	('seed-brand-ibalgin', 'seed-country-netherlands'),
	('seed-brand-ibalgin', 'seed-country-new-zealand'),
	('seed-brand-ibalgin', 'seed-country-norway'),
	('seed-brand-ibalgin', 'seed-country-pakistan'),
	('seed-brand-ibalgin', 'seed-country-peru'),
	('seed-brand-ibalgin', 'seed-country-philippines'),
	('seed-brand-ibalgin', 'seed-country-poland');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-ibalgin', 'seed-country-portugal'),
	('seed-brand-ibalgin', 'seed-country-romania'),
	('seed-brand-ibalgin', 'seed-country-russia'),
	('seed-brand-ibalgin', 'seed-country-saudi-arabia'),
	('seed-brand-ibalgin', 'seed-country-serbia'),
	('seed-brand-ibalgin', 'seed-country-singapore'),
	('seed-brand-ibalgin', 'seed-country-slovakia'),
	('seed-brand-ibalgin', 'seed-country-south-africa'),
	('seed-brand-ibalgin', 'seed-country-south-korea'),
	('seed-brand-ibalgin', 'seed-country-spain'),
	('seed-brand-ibalgin', 'seed-country-sweden'),
	('seed-brand-ibalgin', 'seed-country-switzerland'),
	('seed-brand-ibalgin', 'seed-country-thailand'),
	('seed-brand-ibalgin', 'seed-country-turkey'),
	('seed-brand-ibalgin', 'seed-country-ukraine'),
	('seed-brand-ibalgin', 'seed-country-united-arab-emirates'),
	('seed-brand-ibalgin', 'seed-country-united-kingdom'),
	('seed-brand-ibalgin', 'seed-country-united-states'),
	('seed-brand-ibalgin', 'seed-country-uruguay'),
	('seed-brand-ibalgin', 'seed-country-uzbekistan'),
	('seed-brand-ibalgin', 'seed-country-venezuela'),
	('seed-brand-ibalgin', 'seed-country-vietnam'),
	('seed-brand-ibolex', 'seed-country-czech-republic'),
	('seed-brand-ibolex', 'seed-country-slovakia'),
	('seed-brand-ibuflam', 'seed-country-germany'),
	('seed-brand-icyhot', 'seed-country-argentina'),
	('seed-brand-icyhot', 'seed-country-australia'),
	('seed-brand-icyhot', 'seed-country-austria'),
	('seed-brand-icyhot', 'seed-country-azerbaijan'),
	('seed-brand-icyhot', 'seed-country-belarus'),
	('seed-brand-icyhot', 'seed-country-belgium'),
	('seed-brand-icyhot', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-icyhot', 'seed-country-brazil'),
	('seed-brand-icyhot', 'seed-country-bulgaria'),
	('seed-brand-icyhot', 'seed-country-burundi'),
	('seed-brand-icyhot', 'seed-country-cambodia'),
	('seed-brand-icyhot', 'seed-country-canada'),
	('seed-brand-icyhot', 'seed-country-chile'),
	('seed-brand-icyhot', 'seed-country-china'),
	('seed-brand-icyhot', 'seed-country-colombia'),
	('seed-brand-icyhot', 'seed-country-croatia'),
	('seed-brand-icyhot', 'seed-country-czech-republic'),
	('seed-brand-icyhot', 'seed-country-denmark'),
	('seed-brand-icyhot', 'seed-country-dominican-republic'),
	('seed-brand-icyhot', 'seed-country-ecuador'),
	('seed-brand-icyhot', 'seed-country-egypt'),
	('seed-brand-icyhot', 'seed-country-estonia'),
	('seed-brand-icyhot', 'seed-country-finland'),
	('seed-brand-icyhot', 'seed-country-france'),
	('seed-brand-icyhot', 'seed-country-georgia'),
	('seed-brand-icyhot', 'seed-country-germany'),
	('seed-brand-icyhot', 'seed-country-greece'),
	('seed-brand-icyhot', 'seed-country-hong-kong'),
	('seed-brand-icyhot', 'seed-country-hungary'),
	('seed-brand-icyhot', 'seed-country-india'),
	('seed-brand-icyhot', 'seed-country-indonesia'),
	('seed-brand-icyhot', 'seed-country-ireland'),
	('seed-brand-icyhot', 'seed-country-israel'),
	('seed-brand-icyhot', 'seed-country-italy'),
	('seed-brand-icyhot', 'seed-country-japan'),
	('seed-brand-icyhot', 'seed-country-kazakhstan'),
	('seed-brand-icyhot', 'seed-country-latvia'),
	('seed-brand-icyhot', 'seed-country-lithuania'),
	('seed-brand-icyhot', 'seed-country-luxembourg'),
	('seed-brand-icyhot', 'seed-country-malaysia'),
	('seed-brand-icyhot', 'seed-country-mexico'),
	('seed-brand-icyhot', 'seed-country-montenegro'),
	('seed-brand-icyhot', 'seed-country-netherlands'),
	('seed-brand-icyhot', 'seed-country-new-zealand'),
	('seed-brand-icyhot', 'seed-country-norway'),
	('seed-brand-icyhot', 'seed-country-pakistan'),
	('seed-brand-icyhot', 'seed-country-peru'),
	('seed-brand-icyhot', 'seed-country-philippines'),
	('seed-brand-icyhot', 'seed-country-poland'),
	('seed-brand-icyhot', 'seed-country-portugal'),
	('seed-brand-icyhot', 'seed-country-romania'),
	('seed-brand-icyhot', 'seed-country-russia'),
	('seed-brand-icyhot', 'seed-country-saudi-arabia'),
	('seed-brand-icyhot', 'seed-country-serbia'),
	('seed-brand-icyhot', 'seed-country-singapore'),
	('seed-brand-icyhot', 'seed-country-slovakia'),
	('seed-brand-icyhot', 'seed-country-south-africa'),
	('seed-brand-icyhot', 'seed-country-south-korea'),
	('seed-brand-icyhot', 'seed-country-spain'),
	('seed-brand-icyhot', 'seed-country-sweden'),
	('seed-brand-icyhot', 'seed-country-switzerland'),
	('seed-brand-icyhot', 'seed-country-thailand'),
	('seed-brand-icyhot', 'seed-country-turkey'),
	('seed-brand-icyhot', 'seed-country-ukraine'),
	('seed-brand-icyhot', 'seed-country-united-arab-emirates'),
	('seed-brand-icyhot', 'seed-country-united-kingdom'),
	('seed-brand-icyhot', 'seed-country-united-states'),
	('seed-brand-icyhot', 'seed-country-uruguay'),
	('seed-brand-icyhot', 'seed-country-uzbekistan'),
	('seed-brand-icyhot', 'seed-country-venezuela'),
	('seed-brand-icyhot', 'seed-country-vietnam'),
	('seed-brand-initv', 'seed-country-argentina'),
	('seed-brand-initv', 'seed-country-australia'),
	('seed-brand-initv', 'seed-country-austria'),
	('seed-brand-initv', 'seed-country-azerbaijan');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-initv', 'seed-country-belarus'),
	('seed-brand-initv', 'seed-country-belgium'),
	('seed-brand-initv', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-initv', 'seed-country-brazil'),
	('seed-brand-initv', 'seed-country-bulgaria'),
	('seed-brand-initv', 'seed-country-burundi'),
	('seed-brand-initv', 'seed-country-cambodia'),
	('seed-brand-initv', 'seed-country-canada'),
	('seed-brand-initv', 'seed-country-chile'),
	('seed-brand-initv', 'seed-country-china'),
	('seed-brand-initv', 'seed-country-colombia'),
	('seed-brand-initv', 'seed-country-croatia'),
	('seed-brand-initv', 'seed-country-czech-republic'),
	('seed-brand-initv', 'seed-country-denmark'),
	('seed-brand-initv', 'seed-country-dominican-republic'),
	('seed-brand-initv', 'seed-country-ecuador'),
	('seed-brand-initv', 'seed-country-egypt'),
	('seed-brand-initv', 'seed-country-estonia'),
	('seed-brand-initv', 'seed-country-finland'),
	('seed-brand-initv', 'seed-country-france'),
	('seed-brand-initv', 'seed-country-georgia'),
	('seed-brand-initv', 'seed-country-germany'),
	('seed-brand-initv', 'seed-country-greece'),
	('seed-brand-initv', 'seed-country-hong-kong'),
	('seed-brand-initv', 'seed-country-hungary'),
	('seed-brand-initv', 'seed-country-india'),
	('seed-brand-initv', 'seed-country-indonesia'),
	('seed-brand-initv', 'seed-country-ireland'),
	('seed-brand-initv', 'seed-country-israel'),
	('seed-brand-initv', 'seed-country-italy'),
	('seed-brand-initv', 'seed-country-japan'),
	('seed-brand-initv', 'seed-country-kazakhstan'),
	('seed-brand-initv', 'seed-country-latvia'),
	('seed-brand-initv', 'seed-country-lithuania'),
	('seed-brand-initv', 'seed-country-luxembourg'),
	('seed-brand-initv', 'seed-country-malaysia'),
	('seed-brand-initv', 'seed-country-mexico'),
	('seed-brand-initv', 'seed-country-montenegro'),
	('seed-brand-initv', 'seed-country-netherlands'),
	('seed-brand-initv', 'seed-country-new-zealand'),
	('seed-brand-initv', 'seed-country-norway'),
	('seed-brand-initv', 'seed-country-pakistan'),
	('seed-brand-initv', 'seed-country-peru'),
	('seed-brand-initv', 'seed-country-philippines'),
	('seed-brand-initv', 'seed-country-poland'),
	('seed-brand-initv', 'seed-country-portugal'),
	('seed-brand-initv', 'seed-country-romania'),
	('seed-brand-initv', 'seed-country-russia'),
	('seed-brand-initv', 'seed-country-saudi-arabia'),
	('seed-brand-initv', 'seed-country-serbia'),
	('seed-brand-initv', 'seed-country-singapore'),
	('seed-brand-initv', 'seed-country-slovakia'),
	('seed-brand-initv', 'seed-country-south-africa'),
	('seed-brand-initv', 'seed-country-south-korea'),
	('seed-brand-initv', 'seed-country-spain'),
	('seed-brand-initv', 'seed-country-sweden'),
	('seed-brand-initv', 'seed-country-switzerland'),
	('seed-brand-initv', 'seed-country-thailand'),
	('seed-brand-initv', 'seed-country-turkey'),
	('seed-brand-initv', 'seed-country-ukraine'),
	('seed-brand-initv', 'seed-country-united-arab-emirates'),
	('seed-brand-initv', 'seed-country-united-kingdom'),
	('seed-brand-initv', 'seed-country-united-states'),
	('seed-brand-initv', 'seed-country-uruguay'),
	('seed-brand-initv', 'seed-country-uzbekistan'),
	('seed-brand-initv', 'seed-country-venezuela'),
	('seed-brand-initv', 'seed-country-vietnam'),
	('seed-brand-ipraalox', 'seed-country-argentina'),
	('seed-brand-ipraalox', 'seed-country-australia'),
	('seed-brand-ipraalox', 'seed-country-austria'),
	('seed-brand-ipraalox', 'seed-country-azerbaijan'),
	('seed-brand-ipraalox', 'seed-country-belarus'),
	('seed-brand-ipraalox', 'seed-country-belgium'),
	('seed-brand-ipraalox', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-ipraalox', 'seed-country-brazil'),
	('seed-brand-ipraalox', 'seed-country-bulgaria'),
	('seed-brand-ipraalox', 'seed-country-burundi'),
	('seed-brand-ipraalox', 'seed-country-cambodia'),
	('seed-brand-ipraalox', 'seed-country-canada'),
	('seed-brand-ipraalox', 'seed-country-chile'),
	('seed-brand-ipraalox', 'seed-country-china'),
	('seed-brand-ipraalox', 'seed-country-colombia'),
	('seed-brand-ipraalox', 'seed-country-croatia'),
	('seed-brand-ipraalox', 'seed-country-czech-republic'),
	('seed-brand-ipraalox', 'seed-country-denmark'),
	('seed-brand-ipraalox', 'seed-country-dominican-republic'),
	('seed-brand-ipraalox', 'seed-country-ecuador'),
	('seed-brand-ipraalox', 'seed-country-egypt'),
	('seed-brand-ipraalox', 'seed-country-estonia'),
	('seed-brand-ipraalox', 'seed-country-finland'),
	('seed-brand-ipraalox', 'seed-country-france'),
	('seed-brand-ipraalox', 'seed-country-georgia'),
	('seed-brand-ipraalox', 'seed-country-germany'),
	('seed-brand-ipraalox', 'seed-country-greece'),
	('seed-brand-ipraalox', 'seed-country-hong-kong'),
	('seed-brand-ipraalox', 'seed-country-hungary'),
	('seed-brand-ipraalox', 'seed-country-india'),
	('seed-brand-ipraalox', 'seed-country-indonesia'),
	('seed-brand-ipraalox', 'seed-country-ireland'),
	('seed-brand-ipraalox', 'seed-country-israel');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-ipraalox', 'seed-country-italy'),
	('seed-brand-ipraalox', 'seed-country-japan'),
	('seed-brand-ipraalox', 'seed-country-kazakhstan'),
	('seed-brand-ipraalox', 'seed-country-latvia'),
	('seed-brand-ipraalox', 'seed-country-lithuania'),
	('seed-brand-ipraalox', 'seed-country-luxembourg'),
	('seed-brand-ipraalox', 'seed-country-malaysia'),
	('seed-brand-ipraalox', 'seed-country-mexico'),
	('seed-brand-ipraalox', 'seed-country-montenegro'),
	('seed-brand-ipraalox', 'seed-country-netherlands'),
	('seed-brand-ipraalox', 'seed-country-new-zealand'),
	('seed-brand-ipraalox', 'seed-country-norway'),
	('seed-brand-ipraalox', 'seed-country-pakistan'),
	('seed-brand-ipraalox', 'seed-country-peru'),
	('seed-brand-ipraalox', 'seed-country-philippines'),
	('seed-brand-ipraalox', 'seed-country-poland'),
	('seed-brand-ipraalox', 'seed-country-portugal'),
	('seed-brand-ipraalox', 'seed-country-romania'),
	('seed-brand-ipraalox', 'seed-country-russia'),
	('seed-brand-ipraalox', 'seed-country-saudi-arabia'),
	('seed-brand-ipraalox', 'seed-country-serbia'),
	('seed-brand-ipraalox', 'seed-country-singapore'),
	('seed-brand-ipraalox', 'seed-country-slovakia'),
	('seed-brand-ipraalox', 'seed-country-south-africa'),
	('seed-brand-ipraalox', 'seed-country-south-korea'),
	('seed-brand-ipraalox', 'seed-country-spain'),
	('seed-brand-ipraalox', 'seed-country-sweden'),
	('seed-brand-ipraalox', 'seed-country-switzerland'),
	('seed-brand-ipraalox', 'seed-country-thailand'),
	('seed-brand-ipraalox', 'seed-country-turkey'),
	('seed-brand-ipraalox', 'seed-country-ukraine'),
	('seed-brand-ipraalox', 'seed-country-united-arab-emirates'),
	('seed-brand-ipraalox', 'seed-country-united-kingdom'),
	('seed-brand-ipraalox', 'seed-country-united-states'),
	('seed-brand-ipraalox', 'seed-country-uruguay'),
	('seed-brand-ipraalox', 'seed-country-uzbekistan'),
	('seed-brand-ipraalox', 'seed-country-venezuela'),
	('seed-brand-ipraalox', 'seed-country-vietnam'),
	('seed-brand-iprafeine', 'seed-country-argentina'),
	('seed-brand-iprafeine', 'seed-country-australia'),
	('seed-brand-iprafeine', 'seed-country-austria'),
	('seed-brand-iprafeine', 'seed-country-azerbaijan'),
	('seed-brand-iprafeine', 'seed-country-belarus'),
	('seed-brand-iprafeine', 'seed-country-belgium'),
	('seed-brand-iprafeine', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-iprafeine', 'seed-country-brazil'),
	('seed-brand-iprafeine', 'seed-country-bulgaria'),
	('seed-brand-iprafeine', 'seed-country-burundi'),
	('seed-brand-iprafeine', 'seed-country-cambodia'),
	('seed-brand-iprafeine', 'seed-country-canada'),
	('seed-brand-iprafeine', 'seed-country-chile'),
	('seed-brand-iprafeine', 'seed-country-china'),
	('seed-brand-iprafeine', 'seed-country-colombia'),
	('seed-brand-iprafeine', 'seed-country-croatia'),
	('seed-brand-iprafeine', 'seed-country-czech-republic'),
	('seed-brand-iprafeine', 'seed-country-denmark'),
	('seed-brand-iprafeine', 'seed-country-dominican-republic'),
	('seed-brand-iprafeine', 'seed-country-ecuador'),
	('seed-brand-iprafeine', 'seed-country-egypt'),
	('seed-brand-iprafeine', 'seed-country-estonia'),
	('seed-brand-iprafeine', 'seed-country-finland'),
	('seed-brand-iprafeine', 'seed-country-france'),
	('seed-brand-iprafeine', 'seed-country-georgia'),
	('seed-brand-iprafeine', 'seed-country-germany'),
	('seed-brand-iprafeine', 'seed-country-greece'),
	('seed-brand-iprafeine', 'seed-country-hong-kong'),
	('seed-brand-iprafeine', 'seed-country-hungary'),
	('seed-brand-iprafeine', 'seed-country-india'),
	('seed-brand-iprafeine', 'seed-country-indonesia'),
	('seed-brand-iprafeine', 'seed-country-ireland'),
	('seed-brand-iprafeine', 'seed-country-israel'),
	('seed-brand-iprafeine', 'seed-country-italy'),
	('seed-brand-iprafeine', 'seed-country-japan'),
	('seed-brand-iprafeine', 'seed-country-kazakhstan'),
	('seed-brand-iprafeine', 'seed-country-latvia'),
	('seed-brand-iprafeine', 'seed-country-lithuania'),
	('seed-brand-iprafeine', 'seed-country-luxembourg'),
	('seed-brand-iprafeine', 'seed-country-malaysia'),
	('seed-brand-iprafeine', 'seed-country-mexico'),
	('seed-brand-iprafeine', 'seed-country-montenegro'),
	('seed-brand-iprafeine', 'seed-country-netherlands'),
	('seed-brand-iprafeine', 'seed-country-new-zealand'),
	('seed-brand-iprafeine', 'seed-country-norway'),
	('seed-brand-iprafeine', 'seed-country-pakistan'),
	('seed-brand-iprafeine', 'seed-country-peru'),
	('seed-brand-iprafeine', 'seed-country-philippines'),
	('seed-brand-iprafeine', 'seed-country-poland'),
	('seed-brand-iprafeine', 'seed-country-portugal'),
	('seed-brand-iprafeine', 'seed-country-romania'),
	('seed-brand-iprafeine', 'seed-country-russia'),
	('seed-brand-iprafeine', 'seed-country-saudi-arabia'),
	('seed-brand-iprafeine', 'seed-country-serbia'),
	('seed-brand-iprafeine', 'seed-country-singapore'),
	('seed-brand-iprafeine', 'seed-country-slovakia'),
	('seed-brand-iprafeine', 'seed-country-south-africa'),
	('seed-brand-iprafeine', 'seed-country-south-korea'),
	('seed-brand-iprafeine', 'seed-country-spain'),
	('seed-brand-iprafeine', 'seed-country-sweden'),
	('seed-brand-iprafeine', 'seed-country-switzerland'),
	('seed-brand-iprafeine', 'seed-country-thailand');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-iprafeine', 'seed-country-turkey'),
	('seed-brand-iprafeine', 'seed-country-ukraine'),
	('seed-brand-iprafeine', 'seed-country-united-arab-emirates'),
	('seed-brand-iprafeine', 'seed-country-united-kingdom'),
	('seed-brand-iprafeine', 'seed-country-united-states'),
	('seed-brand-iprafeine', 'seed-country-uruguay'),
	('seed-brand-iprafeine', 'seed-country-uzbekistan'),
	('seed-brand-iprafeine', 'seed-country-venezuela'),
	('seed-brand-iprafeine', 'seed-country-vietnam'),
	('seed-brand-lactacyd', 'seed-country-argentina'),
	('seed-brand-lactacyd', 'seed-country-australia'),
	('seed-brand-lactacyd', 'seed-country-austria'),
	('seed-brand-lactacyd', 'seed-country-azerbaijan'),
	('seed-brand-lactacyd', 'seed-country-belarus'),
	('seed-brand-lactacyd', 'seed-country-belgium'),
	('seed-brand-lactacyd', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-lactacyd', 'seed-country-brazil'),
	('seed-brand-lactacyd', 'seed-country-bulgaria'),
	('seed-brand-lactacyd', 'seed-country-burundi'),
	('seed-brand-lactacyd', 'seed-country-cambodia'),
	('seed-brand-lactacyd', 'seed-country-canada'),
	('seed-brand-lactacyd', 'seed-country-chile'),
	('seed-brand-lactacyd', 'seed-country-china'),
	('seed-brand-lactacyd', 'seed-country-colombia'),
	('seed-brand-lactacyd', 'seed-country-croatia'),
	('seed-brand-lactacyd', 'seed-country-czech-republic'),
	('seed-brand-lactacyd', 'seed-country-denmark'),
	('seed-brand-lactacyd', 'seed-country-dominican-republic'),
	('seed-brand-lactacyd', 'seed-country-ecuador'),
	('seed-brand-lactacyd', 'seed-country-egypt'),
	('seed-brand-lactacyd', 'seed-country-estonia'),
	('seed-brand-lactacyd', 'seed-country-finland'),
	('seed-brand-lactacyd', 'seed-country-france'),
	('seed-brand-lactacyd', 'seed-country-georgia'),
	('seed-brand-lactacyd', 'seed-country-germany'),
	('seed-brand-lactacyd', 'seed-country-greece'),
	('seed-brand-lactacyd', 'seed-country-hong-kong'),
	('seed-brand-lactacyd', 'seed-country-hungary'),
	('seed-brand-lactacyd', 'seed-country-india'),
	('seed-brand-lactacyd', 'seed-country-indonesia'),
	('seed-brand-lactacyd', 'seed-country-ireland'),
	('seed-brand-lactacyd', 'seed-country-israel'),
	('seed-brand-lactacyd', 'seed-country-italy'),
	('seed-brand-lactacyd', 'seed-country-japan'),
	('seed-brand-lactacyd', 'seed-country-kazakhstan'),
	('seed-brand-lactacyd', 'seed-country-latvia'),
	('seed-brand-lactacyd', 'seed-country-lithuania'),
	('seed-brand-lactacyd', 'seed-country-luxembourg'),
	('seed-brand-lactacyd', 'seed-country-malaysia'),
	('seed-brand-lactacyd', 'seed-country-mexico'),
	('seed-brand-lactacyd', 'seed-country-montenegro'),
	('seed-brand-lactacyd', 'seed-country-netherlands'),
	('seed-brand-lactacyd', 'seed-country-new-zealand'),
	('seed-brand-lactacyd', 'seed-country-norway'),
	('seed-brand-lactacyd', 'seed-country-pakistan'),
	('seed-brand-lactacyd', 'seed-country-peru'),
	('seed-brand-lactacyd', 'seed-country-philippines'),
	('seed-brand-lactacyd', 'seed-country-poland'),
	('seed-brand-lactacyd', 'seed-country-portugal'),
	('seed-brand-lactacyd', 'seed-country-romania'),
	('seed-brand-lactacyd', 'seed-country-russia'),
	('seed-brand-lactacyd', 'seed-country-saudi-arabia'),
	('seed-brand-lactacyd', 'seed-country-serbia'),
	('seed-brand-lactacyd', 'seed-country-singapore'),
	('seed-brand-lactacyd', 'seed-country-slovakia'),
	('seed-brand-lactacyd', 'seed-country-south-africa'),
	('seed-brand-lactacyd', 'seed-country-south-korea'),
	('seed-brand-lactacyd', 'seed-country-spain'),
	('seed-brand-lactacyd', 'seed-country-sweden'),
	('seed-brand-lactacyd', 'seed-country-switzerland'),
	('seed-brand-lactacyd', 'seed-country-thailand'),
	('seed-brand-lactacyd', 'seed-country-turkey'),
	('seed-brand-lactacyd', 'seed-country-ukraine'),
	('seed-brand-lactacyd', 'seed-country-united-arab-emirates'),
	('seed-brand-lactacyd', 'seed-country-united-kingdom'),
	('seed-brand-lactacyd', 'seed-country-united-states'),
	('seed-brand-lactacyd', 'seed-country-uruguay'),
	('seed-brand-lactacyd', 'seed-country-uzbekistan'),
	('seed-brand-lactacyd', 'seed-country-venezuela'),
	('seed-brand-lactacyd', 'seed-country-vietnam'),
	('seed-brand-lanzor', 'seed-country-germany'),
	('seed-brand-lasolvan', 'seed-country-russia'),
	('seed-brand-laxoberal', 'seed-country-germany'),
	('seed-brand-lizipaina', 'seed-country-spain'),
	('seed-brand-lysopaine', 'seed-country-france'),
	('seed-brand-lysopaine', 'seed-country-turkey'),
	('seed-brand-maalox', 'seed-country-argentina'),
	('seed-brand-maalox', 'seed-country-australia'),
	('seed-brand-maalox', 'seed-country-austria'),
	('seed-brand-maalox', 'seed-country-azerbaijan'),
	('seed-brand-maalox', 'seed-country-belarus'),
	('seed-brand-maalox', 'seed-country-belgium'),
	('seed-brand-maalox', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-maalox', 'seed-country-brazil'),
	('seed-brand-maalox', 'seed-country-bulgaria'),
	('seed-brand-maalox', 'seed-country-burundi'),
	('seed-brand-maalox', 'seed-country-cambodia'),
	('seed-brand-maalox', 'seed-country-canada'),
	('seed-brand-maalox', 'seed-country-chile'),
	('seed-brand-maalox', 'seed-country-china');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-maalox', 'seed-country-colombia'),
	('seed-brand-maalox', 'seed-country-croatia'),
	('seed-brand-maalox', 'seed-country-czech-republic'),
	('seed-brand-maalox', 'seed-country-denmark'),
	('seed-brand-maalox', 'seed-country-dominican-republic'),
	('seed-brand-maalox', 'seed-country-ecuador'),
	('seed-brand-maalox', 'seed-country-egypt'),
	('seed-brand-maalox', 'seed-country-estonia'),
	('seed-brand-maalox', 'seed-country-finland'),
	('seed-brand-maalox', 'seed-country-france'),
	('seed-brand-maalox', 'seed-country-georgia'),
	('seed-brand-maalox', 'seed-country-germany'),
	('seed-brand-maalox', 'seed-country-greece'),
	('seed-brand-maalox', 'seed-country-hong-kong'),
	('seed-brand-maalox', 'seed-country-hungary'),
	('seed-brand-maalox', 'seed-country-india'),
	('seed-brand-maalox', 'seed-country-indonesia'),
	('seed-brand-maalox', 'seed-country-ireland'),
	('seed-brand-maalox', 'seed-country-israel'),
	('seed-brand-maalox', 'seed-country-italy'),
	('seed-brand-maalox', 'seed-country-japan'),
	('seed-brand-maalox', 'seed-country-kazakhstan'),
	('seed-brand-maalox', 'seed-country-latvia'),
	('seed-brand-maalox', 'seed-country-lithuania'),
	('seed-brand-maalox', 'seed-country-luxembourg'),
	('seed-brand-maalox', 'seed-country-malaysia'),
	('seed-brand-maalox', 'seed-country-mexico'),
	('seed-brand-maalox', 'seed-country-montenegro'),
	('seed-brand-maalox', 'seed-country-netherlands'),
	('seed-brand-maalox', 'seed-country-new-zealand'),
	('seed-brand-maalox', 'seed-country-norway'),
	('seed-brand-maalox', 'seed-country-pakistan'),
	('seed-brand-maalox', 'seed-country-peru'),
	('seed-brand-maalox', 'seed-country-philippines'),
	('seed-brand-maalox', 'seed-country-poland'),
	('seed-brand-maalox', 'seed-country-portugal'),
	('seed-brand-maalox', 'seed-country-romania'),
	('seed-brand-maalox', 'seed-country-russia'),
	('seed-brand-maalox', 'seed-country-saudi-arabia'),
	('seed-brand-maalox', 'seed-country-serbia'),
	('seed-brand-maalox', 'seed-country-singapore'),
	('seed-brand-maalox', 'seed-country-slovakia'),
	('seed-brand-maalox', 'seed-country-south-africa'),
	('seed-brand-maalox', 'seed-country-south-korea'),
	('seed-brand-maalox', 'seed-country-spain'),
	('seed-brand-maalox', 'seed-country-sweden'),
	('seed-brand-maalox', 'seed-country-switzerland'),
	('seed-brand-maalox', 'seed-country-thailand'),
	('seed-brand-maalox', 'seed-country-turkey'),
	('seed-brand-maalox', 'seed-country-ukraine'),
	('seed-brand-maalox', 'seed-country-united-arab-emirates'),
	('seed-brand-maalox', 'seed-country-united-kingdom'),
	('seed-brand-maalox', 'seed-country-united-states'),
	('seed-brand-maalox', 'seed-country-uruguay'),
	('seed-brand-maalox', 'seed-country-uzbekistan'),
	('seed-brand-maalox', 'seed-country-venezuela'),
	('seed-brand-maalox', 'seed-country-vietnam'),
	('seed-brand-magneb6', 'seed-country-argentina'),
	('seed-brand-magneb6', 'seed-country-australia'),
	('seed-brand-magneb6', 'seed-country-austria'),
	('seed-brand-magneb6', 'seed-country-azerbaijan'),
	('seed-brand-magneb6', 'seed-country-belarus'),
	('seed-brand-magneb6', 'seed-country-belgium'),
	('seed-brand-magneb6', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-magneb6', 'seed-country-brazil'),
	('seed-brand-magneb6', 'seed-country-bulgaria'),
	('seed-brand-magneb6', 'seed-country-burundi'),
	('seed-brand-magneb6', 'seed-country-cambodia'),
	('seed-brand-magneb6', 'seed-country-canada'),
	('seed-brand-magneb6', 'seed-country-chile'),
	('seed-brand-magneb6', 'seed-country-china'),
	('seed-brand-magneb6', 'seed-country-colombia'),
	('seed-brand-magneb6', 'seed-country-croatia'),
	('seed-brand-magneb6', 'seed-country-czech-republic'),
	('seed-brand-magneb6', 'seed-country-denmark'),
	('seed-brand-magneb6', 'seed-country-dominican-republic'),
	('seed-brand-magneb6', 'seed-country-ecuador'),
	('seed-brand-magneb6', 'seed-country-egypt'),
	('seed-brand-magneb6', 'seed-country-estonia'),
	('seed-brand-magneb6', 'seed-country-finland'),
	('seed-brand-magneb6', 'seed-country-france'),
	('seed-brand-magneb6', 'seed-country-georgia'),
	('seed-brand-magneb6', 'seed-country-germany'),
	('seed-brand-magneb6', 'seed-country-greece'),
	('seed-brand-magneb6', 'seed-country-hong-kong'),
	('seed-brand-magneb6', 'seed-country-hungary'),
	('seed-brand-magneb6', 'seed-country-india'),
	('seed-brand-magneb6', 'seed-country-indonesia'),
	('seed-brand-magneb6', 'seed-country-ireland'),
	('seed-brand-magneb6', 'seed-country-israel'),
	('seed-brand-magneb6', 'seed-country-italy'),
	('seed-brand-magneb6', 'seed-country-japan'),
	('seed-brand-magneb6', 'seed-country-kazakhstan'),
	('seed-brand-magneb6', 'seed-country-latvia'),
	('seed-brand-magneb6', 'seed-country-lithuania'),
	('seed-brand-magneb6', 'seed-country-luxembourg'),
	('seed-brand-magneb6', 'seed-country-malaysia'),
	('seed-brand-magneb6', 'seed-country-mexico'),
	('seed-brand-magneb6', 'seed-country-montenegro'),
	('seed-brand-magneb6', 'seed-country-netherlands');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-magneb6', 'seed-country-new-zealand'),
	('seed-brand-magneb6', 'seed-country-norway'),
	('seed-brand-magneb6', 'seed-country-pakistan'),
	('seed-brand-magneb6', 'seed-country-peru'),
	('seed-brand-magneb6', 'seed-country-philippines'),
	('seed-brand-magneb6', 'seed-country-poland'),
	('seed-brand-magneb6', 'seed-country-portugal'),
	('seed-brand-magneb6', 'seed-country-romania'),
	('seed-brand-magneb6', 'seed-country-russia'),
	('seed-brand-magneb6', 'seed-country-saudi-arabia'),
	('seed-brand-magneb6', 'seed-country-serbia'),
	('seed-brand-magneb6', 'seed-country-singapore'),
	('seed-brand-magneb6', 'seed-country-slovakia'),
	('seed-brand-magneb6', 'seed-country-south-africa'),
	('seed-brand-magneb6', 'seed-country-south-korea'),
	('seed-brand-magneb6', 'seed-country-spain'),
	('seed-brand-magneb6', 'seed-country-sweden'),
	('seed-brand-magneb6', 'seed-country-switzerland'),
	('seed-brand-magneb6', 'seed-country-thailand'),
	('seed-brand-magneb6', 'seed-country-turkey'),
	('seed-brand-magneb6', 'seed-country-ukraine'),
	('seed-brand-magneb6', 'seed-country-united-arab-emirates'),
	('seed-brand-magneb6', 'seed-country-united-kingdom'),
	('seed-brand-magneb6', 'seed-country-united-states'),
	('seed-brand-magneb6', 'seed-country-uruguay'),
	('seed-brand-magneb6', 'seed-country-uzbekistan'),
	('seed-brand-magneb6', 'seed-country-venezuela'),
	('seed-brand-magneb6', 'seed-country-vietnam'),
	('seed-brand-magnevie', 'seed-country-argentina'),
	('seed-brand-magnevie', 'seed-country-australia'),
	('seed-brand-magnevie', 'seed-country-austria'),
	('seed-brand-magnevie', 'seed-country-azerbaijan'),
	('seed-brand-magnevie', 'seed-country-belarus'),
	('seed-brand-magnevie', 'seed-country-belgium'),
	('seed-brand-magnevie', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-magnevie', 'seed-country-brazil'),
	('seed-brand-magnevie', 'seed-country-bulgaria'),
	('seed-brand-magnevie', 'seed-country-burundi'),
	('seed-brand-magnevie', 'seed-country-cambodia'),
	('seed-brand-magnevie', 'seed-country-canada'),
	('seed-brand-magnevie', 'seed-country-chile'),
	('seed-brand-magnevie', 'seed-country-china'),
	('seed-brand-magnevie', 'seed-country-colombia'),
	('seed-brand-magnevie', 'seed-country-croatia'),
	('seed-brand-magnevie', 'seed-country-czech-republic'),
	('seed-brand-magnevie', 'seed-country-denmark'),
	('seed-brand-magnevie', 'seed-country-dominican-republic'),
	('seed-brand-magnevie', 'seed-country-ecuador'),
	('seed-brand-magnevie', 'seed-country-egypt'),
	('seed-brand-magnevie', 'seed-country-estonia'),
	('seed-brand-magnevie', 'seed-country-finland'),
	('seed-brand-magnevie', 'seed-country-france'),
	('seed-brand-magnevie', 'seed-country-georgia'),
	('seed-brand-magnevie', 'seed-country-germany'),
	('seed-brand-magnevie', 'seed-country-greece'),
	('seed-brand-magnevie', 'seed-country-hong-kong'),
	('seed-brand-magnevie', 'seed-country-hungary'),
	('seed-brand-magnevie', 'seed-country-india'),
	('seed-brand-magnevie', 'seed-country-indonesia'),
	('seed-brand-magnevie', 'seed-country-ireland'),
	('seed-brand-magnevie', 'seed-country-israel'),
	('seed-brand-magnevie', 'seed-country-italy'),
	('seed-brand-magnevie', 'seed-country-japan'),
	('seed-brand-magnevie', 'seed-country-kazakhstan'),
	('seed-brand-magnevie', 'seed-country-latvia'),
	('seed-brand-magnevie', 'seed-country-lithuania'),
	('seed-brand-magnevie', 'seed-country-luxembourg'),
	('seed-brand-magnevie', 'seed-country-malaysia'),
	('seed-brand-magnevie', 'seed-country-mexico'),
	('seed-brand-magnevie', 'seed-country-montenegro'),
	('seed-brand-magnevie', 'seed-country-netherlands'),
	('seed-brand-magnevie', 'seed-country-new-zealand'),
	('seed-brand-magnevie', 'seed-country-norway'),
	('seed-brand-magnevie', 'seed-country-pakistan'),
	('seed-brand-magnevie', 'seed-country-peru'),
	('seed-brand-magnevie', 'seed-country-philippines'),
	('seed-brand-magnevie', 'seed-country-poland'),
	('seed-brand-magnevie', 'seed-country-portugal'),
	('seed-brand-magnevie', 'seed-country-romania'),
	('seed-brand-magnevie', 'seed-country-russia'),
	('seed-brand-magnevie', 'seed-country-saudi-arabia'),
	('seed-brand-magnevie', 'seed-country-serbia'),
	('seed-brand-magnevie', 'seed-country-singapore'),
	('seed-brand-magnevie', 'seed-country-slovakia'),
	('seed-brand-magnevie', 'seed-country-south-africa'),
	('seed-brand-magnevie', 'seed-country-south-korea'),
	('seed-brand-magnevie', 'seed-country-spain'),
	('seed-brand-magnevie', 'seed-country-sweden'),
	('seed-brand-magnevie', 'seed-country-switzerland'),
	('seed-brand-magnevie', 'seed-country-thailand'),
	('seed-brand-magnevie', 'seed-country-turkey'),
	('seed-brand-magnevie', 'seed-country-ukraine'),
	('seed-brand-magnevie', 'seed-country-united-arab-emirates'),
	('seed-brand-magnevie', 'seed-country-united-kingdom'),
	('seed-brand-magnevie', 'seed-country-united-states'),
	('seed-brand-magnevie', 'seed-country-uruguay'),
	('seed-brand-magnevie', 'seed-country-uzbekistan'),
	('seed-brand-magnevie', 'seed-country-venezuela'),
	('seed-brand-magnevie', 'seed-country-vietnam'),
	('seed-brand-maxilase', 'seed-country-argentina');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-maxilase', 'seed-country-australia'),
	('seed-brand-maxilase', 'seed-country-austria'),
	('seed-brand-maxilase', 'seed-country-azerbaijan'),
	('seed-brand-maxilase', 'seed-country-belarus'),
	('seed-brand-maxilase', 'seed-country-belgium'),
	('seed-brand-maxilase', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-maxilase', 'seed-country-brazil'),
	('seed-brand-maxilase', 'seed-country-bulgaria'),
	('seed-brand-maxilase', 'seed-country-burundi'),
	('seed-brand-maxilase', 'seed-country-cambodia'),
	('seed-brand-maxilase', 'seed-country-canada'),
	('seed-brand-maxilase', 'seed-country-chile'),
	('seed-brand-maxilase', 'seed-country-china'),
	('seed-brand-maxilase', 'seed-country-colombia'),
	('seed-brand-maxilase', 'seed-country-croatia'),
	('seed-brand-maxilase', 'seed-country-czech-republic'),
	('seed-brand-maxilase', 'seed-country-denmark'),
	('seed-brand-maxilase', 'seed-country-dominican-republic'),
	('seed-brand-maxilase', 'seed-country-ecuador'),
	('seed-brand-maxilase', 'seed-country-egypt'),
	('seed-brand-maxilase', 'seed-country-estonia'),
	('seed-brand-maxilase', 'seed-country-finland'),
	('seed-brand-maxilase', 'seed-country-france'),
	('seed-brand-maxilase', 'seed-country-georgia'),
	('seed-brand-maxilase', 'seed-country-germany'),
	('seed-brand-maxilase', 'seed-country-greece'),
	('seed-brand-maxilase', 'seed-country-hong-kong'),
	('seed-brand-maxilase', 'seed-country-hungary'),
	('seed-brand-maxilase', 'seed-country-india'),
	('seed-brand-maxilase', 'seed-country-indonesia'),
	('seed-brand-maxilase', 'seed-country-ireland'),
	('seed-brand-maxilase', 'seed-country-israel'),
	('seed-brand-maxilase', 'seed-country-italy'),
	('seed-brand-maxilase', 'seed-country-japan'),
	('seed-brand-maxilase', 'seed-country-kazakhstan'),
	('seed-brand-maxilase', 'seed-country-latvia'),
	('seed-brand-maxilase', 'seed-country-lithuania'),
	('seed-brand-maxilase', 'seed-country-luxembourg'),
	('seed-brand-maxilase', 'seed-country-malaysia'),
	('seed-brand-maxilase', 'seed-country-mexico'),
	('seed-brand-maxilase', 'seed-country-montenegro'),
	('seed-brand-maxilase', 'seed-country-netherlands'),
	('seed-brand-maxilase', 'seed-country-new-zealand'),
	('seed-brand-maxilase', 'seed-country-norway'),
	('seed-brand-maxilase', 'seed-country-pakistan'),
	('seed-brand-maxilase', 'seed-country-peru'),
	('seed-brand-maxilase', 'seed-country-philippines'),
	('seed-brand-maxilase', 'seed-country-poland'),
	('seed-brand-maxilase', 'seed-country-portugal'),
	('seed-brand-maxilase', 'seed-country-romania'),
	('seed-brand-maxilase', 'seed-country-russia'),
	('seed-brand-maxilase', 'seed-country-saudi-arabia'),
	('seed-brand-maxilase', 'seed-country-serbia'),
	('seed-brand-maxilase', 'seed-country-singapore'),
	('seed-brand-maxilase', 'seed-country-slovakia'),
	('seed-brand-maxilase', 'seed-country-south-africa'),
	('seed-brand-maxilase', 'seed-country-south-korea'),
	('seed-brand-maxilase', 'seed-country-spain'),
	('seed-brand-maxilase', 'seed-country-sweden'),
	('seed-brand-maxilase', 'seed-country-switzerland'),
	('seed-brand-maxilase', 'seed-country-thailand'),
	('seed-brand-maxilase', 'seed-country-turkey'),
	('seed-brand-maxilase', 'seed-country-ukraine'),
	('seed-brand-maxilase', 'seed-country-united-arab-emirates'),
	('seed-brand-maxilase', 'seed-country-united-kingdom'),
	('seed-brand-maxilase', 'seed-country-united-states'),
	('seed-brand-maxilase', 'seed-country-uruguay'),
	('seed-brand-maxilase', 'seed-country-uzbekistan'),
	('seed-brand-maxilase', 'seed-country-venezuela'),
	('seed-brand-maxilase', 'seed-country-vietnam'),
	('seed-brand-migralgin', 'seed-country-czech-republic'),
	('seed-brand-mobility', 'seed-country-hong-kong'),
	('seed-brand-mucoangin', 'seed-country-argentina'),
	('seed-brand-mucoangin', 'seed-country-australia'),
	('seed-brand-mucoangin', 'seed-country-austria'),
	('seed-brand-mucoangin', 'seed-country-azerbaijan'),
	('seed-brand-mucoangin', 'seed-country-belarus'),
	('seed-brand-mucoangin', 'seed-country-belgium'),
	('seed-brand-mucoangin', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-mucoangin', 'seed-country-brazil'),
	('seed-brand-mucoangin', 'seed-country-bulgaria'),
	('seed-brand-mucoangin', 'seed-country-burundi'),
	('seed-brand-mucoangin', 'seed-country-cambodia'),
	('seed-brand-mucoangin', 'seed-country-canada'),
	('seed-brand-mucoangin', 'seed-country-chile'),
	('seed-brand-mucoangin', 'seed-country-china'),
	('seed-brand-mucoangin', 'seed-country-colombia'),
	('seed-brand-mucoangin', 'seed-country-croatia'),
	('seed-brand-mucoangin', 'seed-country-czech-republic'),
	('seed-brand-mucoangin', 'seed-country-denmark'),
	('seed-brand-mucoangin', 'seed-country-dominican-republic'),
	('seed-brand-mucoangin', 'seed-country-ecuador'),
	('seed-brand-mucoangin', 'seed-country-egypt'),
	('seed-brand-mucoangin', 'seed-country-estonia'),
	('seed-brand-mucoangin', 'seed-country-finland'),
	('seed-brand-mucoangin', 'seed-country-france'),
	('seed-brand-mucoangin', 'seed-country-georgia'),
	('seed-brand-mucoangin', 'seed-country-germany'),
	('seed-brand-mucoangin', 'seed-country-greece'),
	('seed-brand-mucoangin', 'seed-country-hong-kong');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-mucoangin', 'seed-country-hungary'),
	('seed-brand-mucoangin', 'seed-country-india'),
	('seed-brand-mucoangin', 'seed-country-indonesia'),
	('seed-brand-mucoangin', 'seed-country-ireland'),
	('seed-brand-mucoangin', 'seed-country-israel'),
	('seed-brand-mucoangin', 'seed-country-italy'),
	('seed-brand-mucoangin', 'seed-country-japan'),
	('seed-brand-mucoangin', 'seed-country-kazakhstan'),
	('seed-brand-mucoangin', 'seed-country-latvia'),
	('seed-brand-mucoangin', 'seed-country-lithuania'),
	('seed-brand-mucoangin', 'seed-country-luxembourg'),
	('seed-brand-mucoangin', 'seed-country-malaysia'),
	('seed-brand-mucoangin', 'seed-country-mexico'),
	('seed-brand-mucoangin', 'seed-country-montenegro'),
	('seed-brand-mucoangin', 'seed-country-netherlands'),
	('seed-brand-mucoangin', 'seed-country-new-zealand'),
	('seed-brand-mucoangin', 'seed-country-norway'),
	('seed-brand-mucoangin', 'seed-country-pakistan'),
	('seed-brand-mucoangin', 'seed-country-peru'),
	('seed-brand-mucoangin', 'seed-country-philippines'),
	('seed-brand-mucoangin', 'seed-country-poland'),
	('seed-brand-mucoangin', 'seed-country-portugal'),
	('seed-brand-mucoangin', 'seed-country-romania'),
	('seed-brand-mucoangin', 'seed-country-russia'),
	('seed-brand-mucoangin', 'seed-country-saudi-arabia'),
	('seed-brand-mucoangin', 'seed-country-serbia'),
	('seed-brand-mucoangin', 'seed-country-singapore'),
	('seed-brand-mucoangin', 'seed-country-slovakia'),
	('seed-brand-mucoangin', 'seed-country-south-africa'),
	('seed-brand-mucoangin', 'seed-country-south-korea'),
	('seed-brand-mucoangin', 'seed-country-spain'),
	('seed-brand-mucoangin', 'seed-country-sweden'),
	('seed-brand-mucoangin', 'seed-country-switzerland'),
	('seed-brand-mucoangin', 'seed-country-thailand'),
	('seed-brand-mucoangin', 'seed-country-turkey'),
	('seed-brand-mucoangin', 'seed-country-ukraine'),
	('seed-brand-mucoangin', 'seed-country-united-arab-emirates'),
	('seed-brand-mucoangin', 'seed-country-united-kingdom'),
	('seed-brand-mucoangin', 'seed-country-united-states'),
	('seed-brand-mucoangin', 'seed-country-uruguay'),
	('seed-brand-mucoangin', 'seed-country-uzbekistan'),
	('seed-brand-mucoangin', 'seed-country-venezuela'),
	('seed-brand-mucoangin', 'seed-country-vietnam'),
	('seed-brand-muconasal', 'seed-country-argentina'),
	('seed-brand-muconasal', 'seed-country-australia'),
	('seed-brand-muconasal', 'seed-country-austria'),
	('seed-brand-muconasal', 'seed-country-azerbaijan'),
	('seed-brand-muconasal', 'seed-country-belarus'),
	('seed-brand-muconasal', 'seed-country-belgium'),
	('seed-brand-muconasal', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-muconasal', 'seed-country-brazil'),
	('seed-brand-muconasal', 'seed-country-bulgaria'),
	('seed-brand-muconasal', 'seed-country-burundi'),
	('seed-brand-muconasal', 'seed-country-cambodia'),
	('seed-brand-muconasal', 'seed-country-canada'),
	('seed-brand-muconasal', 'seed-country-chile'),
	('seed-brand-muconasal', 'seed-country-china'),
	('seed-brand-muconasal', 'seed-country-colombia'),
	('seed-brand-muconasal', 'seed-country-croatia'),
	('seed-brand-muconasal', 'seed-country-czech-republic'),
	('seed-brand-muconasal', 'seed-country-denmark'),
	('seed-brand-muconasal', 'seed-country-dominican-republic'),
	('seed-brand-muconasal', 'seed-country-ecuador'),
	('seed-brand-muconasal', 'seed-country-egypt'),
	('seed-brand-muconasal', 'seed-country-estonia'),
	('seed-brand-muconasal', 'seed-country-finland'),
	('seed-brand-muconasal', 'seed-country-france'),
	('seed-brand-muconasal', 'seed-country-georgia'),
	('seed-brand-muconasal', 'seed-country-germany'),
	('seed-brand-muconasal', 'seed-country-greece'),
	('seed-brand-muconasal', 'seed-country-hong-kong'),
	('seed-brand-muconasal', 'seed-country-hungary'),
	('seed-brand-muconasal', 'seed-country-india'),
	('seed-brand-muconasal', 'seed-country-indonesia'),
	('seed-brand-muconasal', 'seed-country-ireland'),
	('seed-brand-muconasal', 'seed-country-israel'),
	('seed-brand-muconasal', 'seed-country-italy'),
	('seed-brand-muconasal', 'seed-country-japan'),
	('seed-brand-muconasal', 'seed-country-kazakhstan'),
	('seed-brand-muconasal', 'seed-country-latvia'),
	('seed-brand-muconasal', 'seed-country-lithuania'),
	('seed-brand-muconasal', 'seed-country-luxembourg'),
	('seed-brand-muconasal', 'seed-country-malaysia'),
	('seed-brand-muconasal', 'seed-country-mexico'),
	('seed-brand-muconasal', 'seed-country-montenegro'),
	('seed-brand-muconasal', 'seed-country-netherlands'),
	('seed-brand-muconasal', 'seed-country-new-zealand'),
	('seed-brand-muconasal', 'seed-country-norway'),
	('seed-brand-muconasal', 'seed-country-pakistan'),
	('seed-brand-muconasal', 'seed-country-peru'),
	('seed-brand-muconasal', 'seed-country-philippines'),
	('seed-brand-muconasal', 'seed-country-poland'),
	('seed-brand-muconasal', 'seed-country-portugal'),
	('seed-brand-muconasal', 'seed-country-romania'),
	('seed-brand-muconasal', 'seed-country-russia'),
	('seed-brand-muconasal', 'seed-country-saudi-arabia'),
	('seed-brand-muconasal', 'seed-country-serbia'),
	('seed-brand-muconasal', 'seed-country-singapore'),
	('seed-brand-muconasal', 'seed-country-slovakia'),
	('seed-brand-muconasal', 'seed-country-south-africa');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-muconasal', 'seed-country-south-korea'),
	('seed-brand-muconasal', 'seed-country-spain'),
	('seed-brand-muconasal', 'seed-country-sweden'),
	('seed-brand-muconasal', 'seed-country-switzerland'),
	('seed-brand-muconasal', 'seed-country-thailand'),
	('seed-brand-muconasal', 'seed-country-turkey'),
	('seed-brand-muconasal', 'seed-country-ukraine'),
	('seed-brand-muconasal', 'seed-country-united-arab-emirates'),
	('seed-brand-muconasal', 'seed-country-united-kingdom'),
	('seed-brand-muconasal', 'seed-country-united-states'),
	('seed-brand-muconasal', 'seed-country-uruguay'),
	('seed-brand-muconasal', 'seed-country-uzbekistan'),
	('seed-brand-muconasal', 'seed-country-venezuela'),
	('seed-brand-muconasal', 'seed-country-vietnam'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-argentina'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-australia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-austria'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-azerbaijan'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-belarus'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-belgium'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-brazil'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-bulgaria'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-burundi'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-cambodia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-canada'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-chile'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-china'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-colombia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-croatia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-czech-republic'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-denmark'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-dominican-republic'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-ecuador'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-egypt'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-estonia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-finland'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-france'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-georgia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-germany'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-greece'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-hong-kong'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-hungary'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-india'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-indonesia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-ireland'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-israel'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-italy'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-japan'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-kazakhstan'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-latvia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-lithuania'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-luxembourg'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-malaysia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-mexico'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-montenegro'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-netherlands'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-new-zealand'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-norway'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-pakistan'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-peru'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-philippines'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-poland'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-portugal'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-romania'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-russia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-saudi-arabia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-serbia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-singapore'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-slovakia'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-south-africa'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-south-korea'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-spain'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-sweden'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-switzerland'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-thailand'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-turkey'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-ukraine'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-united-arab-emirates'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-united-kingdom'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-united-states'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-uruguay'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-uzbekistan'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-venezuela'),
	('seed-brand-mucosan-mucosolvan', 'seed-country-vietnam'),
	('seed-brand-mucosin', 'seed-country-latvia'),
	('seed-brand-mucosin', 'seed-country-lithuania'),
	('seed-brand-mucosin', 'seed-country-ukraine'),
	('seed-brand-nasacort', 'seed-country-canada'),
	('seed-brand-nasacort', 'seed-country-germany'),
	('seed-brand-nasacort', 'seed-country-netherlands'),
	('seed-brand-nasacort', 'seed-country-united-states'),
	('seed-brand-nature-s-own', 'seed-country-australia'),
	('seed-brand-nature-s-own', 'seed-country-new-zealand'),
	('seed-brand-nospa', 'seed-country-argentina'),
	('seed-brand-nospa', 'seed-country-australia'),
	('seed-brand-nospa', 'seed-country-austria'),
	('seed-brand-nospa', 'seed-country-azerbaijan'),
	('seed-brand-nospa', 'seed-country-belarus'),
	('seed-brand-nospa', 'seed-country-belgium');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-nospa', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-nospa', 'seed-country-brazil'),
	('seed-brand-nospa', 'seed-country-bulgaria'),
	('seed-brand-nospa', 'seed-country-burundi'),
	('seed-brand-nospa', 'seed-country-cambodia'),
	('seed-brand-nospa', 'seed-country-canada'),
	('seed-brand-nospa', 'seed-country-chile'),
	('seed-brand-nospa', 'seed-country-china'),
	('seed-brand-nospa', 'seed-country-colombia'),
	('seed-brand-nospa', 'seed-country-croatia'),
	('seed-brand-nospa', 'seed-country-czech-republic'),
	('seed-brand-nospa', 'seed-country-denmark'),
	('seed-brand-nospa', 'seed-country-dominican-republic'),
	('seed-brand-nospa', 'seed-country-ecuador'),
	('seed-brand-nospa', 'seed-country-egypt'),
	('seed-brand-nospa', 'seed-country-estonia'),
	('seed-brand-nospa', 'seed-country-finland'),
	('seed-brand-nospa', 'seed-country-france'),
	('seed-brand-nospa', 'seed-country-georgia'),
	('seed-brand-nospa', 'seed-country-germany'),
	('seed-brand-nospa', 'seed-country-greece'),
	('seed-brand-nospa', 'seed-country-hong-kong'),
	('seed-brand-nospa', 'seed-country-hungary'),
	('seed-brand-nospa', 'seed-country-india'),
	('seed-brand-nospa', 'seed-country-indonesia'),
	('seed-brand-nospa', 'seed-country-ireland'),
	('seed-brand-nospa', 'seed-country-israel'),
	('seed-brand-nospa', 'seed-country-italy'),
	('seed-brand-nospa', 'seed-country-japan'),
	('seed-brand-nospa', 'seed-country-kazakhstan'),
	('seed-brand-nospa', 'seed-country-latvia'),
	('seed-brand-nospa', 'seed-country-lithuania'),
	('seed-brand-nospa', 'seed-country-luxembourg'),
	('seed-brand-nospa', 'seed-country-malaysia'),
	('seed-brand-nospa', 'seed-country-mexico'),
	('seed-brand-nospa', 'seed-country-montenegro'),
	('seed-brand-nospa', 'seed-country-netherlands'),
	('seed-brand-nospa', 'seed-country-new-zealand'),
	('seed-brand-nospa', 'seed-country-norway'),
	('seed-brand-nospa', 'seed-country-pakistan'),
	('seed-brand-nospa', 'seed-country-peru'),
	('seed-brand-nospa', 'seed-country-philippines'),
	('seed-brand-nospa', 'seed-country-poland'),
	('seed-brand-nospa', 'seed-country-portugal'),
	('seed-brand-nospa', 'seed-country-romania'),
	('seed-brand-nospa', 'seed-country-russia'),
	('seed-brand-nospa', 'seed-country-saudi-arabia'),
	('seed-brand-nospa', 'seed-country-serbia'),
	('seed-brand-nospa', 'seed-country-singapore'),
	('seed-brand-nospa', 'seed-country-slovakia'),
	('seed-brand-nospa', 'seed-country-south-africa'),
	('seed-brand-nospa', 'seed-country-south-korea'),
	('seed-brand-nospa', 'seed-country-spain'),
	('seed-brand-nospa', 'seed-country-sweden'),
	('seed-brand-nospa', 'seed-country-switzerland'),
	('seed-brand-nospa', 'seed-country-thailand'),
	('seed-brand-nospa', 'seed-country-turkey'),
	('seed-brand-nospa', 'seed-country-ukraine'),
	('seed-brand-nospa', 'seed-country-united-arab-emirates'),
	('seed-brand-nospa', 'seed-country-united-kingdom'),
	('seed-brand-nospa', 'seed-country-united-states'),
	('seed-brand-nospa', 'seed-country-uruguay'),
	('seed-brand-nospa', 'seed-country-uzbekistan'),
	('seed-brand-nospa', 'seed-country-venezuela'),
	('seed-brand-nospa', 'seed-country-vietnam'),
	('seed-brand-novalgina', 'seed-country-argentina'),
	('seed-brand-novalgina', 'seed-country-australia'),
	('seed-brand-novalgina', 'seed-country-austria'),
	('seed-brand-novalgina', 'seed-country-azerbaijan'),
	('seed-brand-novalgina', 'seed-country-belarus'),
	('seed-brand-novalgina', 'seed-country-belgium'),
	('seed-brand-novalgina', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-novalgina', 'seed-country-brazil'),
	('seed-brand-novalgina', 'seed-country-bulgaria'),
	('seed-brand-novalgina', 'seed-country-burundi'),
	('seed-brand-novalgina', 'seed-country-cambodia'),
	('seed-brand-novalgina', 'seed-country-canada'),
	('seed-brand-novalgina', 'seed-country-chile'),
	('seed-brand-novalgina', 'seed-country-china'),
	('seed-brand-novalgina', 'seed-country-colombia'),
	('seed-brand-novalgina', 'seed-country-croatia'),
	('seed-brand-novalgina', 'seed-country-czech-republic'),
	('seed-brand-novalgina', 'seed-country-denmark'),
	('seed-brand-novalgina', 'seed-country-dominican-republic'),
	('seed-brand-novalgina', 'seed-country-ecuador'),
	('seed-brand-novalgina', 'seed-country-egypt'),
	('seed-brand-novalgina', 'seed-country-estonia'),
	('seed-brand-novalgina', 'seed-country-finland'),
	('seed-brand-novalgina', 'seed-country-france'),
	('seed-brand-novalgina', 'seed-country-georgia'),
	('seed-brand-novalgina', 'seed-country-germany'),
	('seed-brand-novalgina', 'seed-country-greece'),
	('seed-brand-novalgina', 'seed-country-hong-kong'),
	('seed-brand-novalgina', 'seed-country-hungary'),
	('seed-brand-novalgina', 'seed-country-india'),
	('seed-brand-novalgina', 'seed-country-indonesia'),
	('seed-brand-novalgina', 'seed-country-ireland'),
	('seed-brand-novalgina', 'seed-country-israel'),
	('seed-brand-novalgina', 'seed-country-italy'),
	('seed-brand-novalgina', 'seed-country-japan');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-novalgina', 'seed-country-kazakhstan'),
	('seed-brand-novalgina', 'seed-country-latvia'),
	('seed-brand-novalgina', 'seed-country-lithuania'),
	('seed-brand-novalgina', 'seed-country-luxembourg'),
	('seed-brand-novalgina', 'seed-country-malaysia'),
	('seed-brand-novalgina', 'seed-country-mexico'),
	('seed-brand-novalgina', 'seed-country-montenegro'),
	('seed-brand-novalgina', 'seed-country-netherlands'),
	('seed-brand-novalgina', 'seed-country-new-zealand'),
	('seed-brand-novalgina', 'seed-country-norway'),
	('seed-brand-novalgina', 'seed-country-pakistan'),
	('seed-brand-novalgina', 'seed-country-peru'),
	('seed-brand-novalgina', 'seed-country-philippines'),
	('seed-brand-novalgina', 'seed-country-poland'),
	('seed-brand-novalgina', 'seed-country-portugal'),
	('seed-brand-novalgina', 'seed-country-romania'),
	('seed-brand-novalgina', 'seed-country-russia'),
	('seed-brand-novalgina', 'seed-country-saudi-arabia'),
	('seed-brand-novalgina', 'seed-country-serbia'),
	('seed-brand-novalgina', 'seed-country-singapore'),
	('seed-brand-novalgina', 'seed-country-slovakia'),
	('seed-brand-novalgina', 'seed-country-south-africa'),
	('seed-brand-novalgina', 'seed-country-south-korea'),
	('seed-brand-novalgina', 'seed-country-spain'),
	('seed-brand-novalgina', 'seed-country-sweden'),
	('seed-brand-novalgina', 'seed-country-switzerland'),
	('seed-brand-novalgina', 'seed-country-thailand'),
	('seed-brand-novalgina', 'seed-country-turkey'),
	('seed-brand-novalgina', 'seed-country-ukraine'),
	('seed-brand-novalgina', 'seed-country-united-arab-emirates'),
	('seed-brand-novalgina', 'seed-country-united-kingdom'),
	('seed-brand-novalgina', 'seed-country-united-states'),
	('seed-brand-novalgina', 'seed-country-uruguay'),
	('seed-brand-novalgina', 'seed-country-uzbekistan'),
	('seed-brand-novalgina', 'seed-country-venezuela'),
	('seed-brand-novalgina', 'seed-country-vietnam'),
	('seed-brand-novanight', 'seed-country-argentina'),
	('seed-brand-novanight', 'seed-country-australia'),
	('seed-brand-novanight', 'seed-country-austria'),
	('seed-brand-novanight', 'seed-country-azerbaijan'),
	('seed-brand-novanight', 'seed-country-belarus'),
	('seed-brand-novanight', 'seed-country-belgium'),
	('seed-brand-novanight', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-novanight', 'seed-country-brazil'),
	('seed-brand-novanight', 'seed-country-bulgaria'),
	('seed-brand-novanight', 'seed-country-burundi'),
	('seed-brand-novanight', 'seed-country-cambodia'),
	('seed-brand-novanight', 'seed-country-canada'),
	('seed-brand-novanight', 'seed-country-chile'),
	('seed-brand-novanight', 'seed-country-china'),
	('seed-brand-novanight', 'seed-country-colombia'),
	('seed-brand-novanight', 'seed-country-croatia'),
	('seed-brand-novanight', 'seed-country-czech-republic'),
	('seed-brand-novanight', 'seed-country-denmark'),
	('seed-brand-novanight', 'seed-country-dominican-republic'),
	('seed-brand-novanight', 'seed-country-ecuador'),
	('seed-brand-novanight', 'seed-country-egypt'),
	('seed-brand-novanight', 'seed-country-estonia'),
	('seed-brand-novanight', 'seed-country-finland'),
	('seed-brand-novanight', 'seed-country-france'),
	('seed-brand-novanight', 'seed-country-georgia'),
	('seed-brand-novanight', 'seed-country-germany'),
	('seed-brand-novanight', 'seed-country-greece'),
	('seed-brand-novanight', 'seed-country-hong-kong'),
	('seed-brand-novanight', 'seed-country-hungary'),
	('seed-brand-novanight', 'seed-country-india'),
	('seed-brand-novanight', 'seed-country-indonesia'),
	('seed-brand-novanight', 'seed-country-ireland'),
	('seed-brand-novanight', 'seed-country-israel'),
	('seed-brand-novanight', 'seed-country-italy'),
	('seed-brand-novanight', 'seed-country-japan'),
	('seed-brand-novanight', 'seed-country-kazakhstan'),
	('seed-brand-novanight', 'seed-country-latvia'),
	('seed-brand-novanight', 'seed-country-lithuania'),
	('seed-brand-novanight', 'seed-country-luxembourg'),
	('seed-brand-novanight', 'seed-country-malaysia'),
	('seed-brand-novanight', 'seed-country-mexico'),
	('seed-brand-novanight', 'seed-country-montenegro'),
	('seed-brand-novanight', 'seed-country-netherlands'),
	('seed-brand-novanight', 'seed-country-new-zealand'),
	('seed-brand-novanight', 'seed-country-norway'),
	('seed-brand-novanight', 'seed-country-pakistan'),
	('seed-brand-novanight', 'seed-country-peru'),
	('seed-brand-novanight', 'seed-country-philippines'),
	('seed-brand-novanight', 'seed-country-poland'),
	('seed-brand-novanight', 'seed-country-portugal'),
	('seed-brand-novanight', 'seed-country-romania'),
	('seed-brand-novanight', 'seed-country-russia'),
	('seed-brand-novanight', 'seed-country-saudi-arabia'),
	('seed-brand-novanight', 'seed-country-serbia'),
	('seed-brand-novanight', 'seed-country-singapore'),
	('seed-brand-novanight', 'seed-country-slovakia'),
	('seed-brand-novanight', 'seed-country-south-africa'),
	('seed-brand-novanight', 'seed-country-south-korea'),
	('seed-brand-novanight', 'seed-country-spain'),
	('seed-brand-novanight', 'seed-country-sweden'),
	('seed-brand-novanight', 'seed-country-switzerland'),
	('seed-brand-novanight', 'seed-country-thailand'),
	('seed-brand-novanight', 'seed-country-turkey'),
	('seed-brand-novanight', 'seed-country-ukraine');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-novanight', 'seed-country-united-arab-emirates'),
	('seed-brand-novanight', 'seed-country-united-kingdom'),
	('seed-brand-novanight', 'seed-country-united-states'),
	('seed-brand-novanight', 'seed-country-uruguay'),
	('seed-brand-novanight', 'seed-country-uzbekistan'),
	('seed-brand-novanight', 'seed-country-venezuela'),
	('seed-brand-novanight', 'seed-country-vietnam'),
	('seed-brand-opella', 'seed-country-argentina'),
	('seed-brand-opella', 'seed-country-australia'),
	('seed-brand-opella', 'seed-country-austria'),
	('seed-brand-opella', 'seed-country-azerbaijan'),
	('seed-brand-opella', 'seed-country-belarus'),
	('seed-brand-opella', 'seed-country-belgium'),
	('seed-brand-opella', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-opella', 'seed-country-brazil'),
	('seed-brand-opella', 'seed-country-bulgaria'),
	('seed-brand-opella', 'seed-country-burundi'),
	('seed-brand-opella', 'seed-country-cambodia'),
	('seed-brand-opella', 'seed-country-canada'),
	('seed-brand-opella', 'seed-country-chile'),
	('seed-brand-opella', 'seed-country-china'),
	('seed-brand-opella', 'seed-country-colombia'),
	('seed-brand-opella', 'seed-country-croatia'),
	('seed-brand-opella', 'seed-country-czech-republic'),
	('seed-brand-opella', 'seed-country-denmark'),
	('seed-brand-opella', 'seed-country-dominican-republic'),
	('seed-brand-opella', 'seed-country-ecuador'),
	('seed-brand-opella', 'seed-country-egypt'),
	('seed-brand-opella', 'seed-country-estonia'),
	('seed-brand-opella', 'seed-country-finland'),
	('seed-brand-opella', 'seed-country-france'),
	('seed-brand-opella', 'seed-country-georgia'),
	('seed-brand-opella', 'seed-country-germany'),
	('seed-brand-opella', 'seed-country-greece'),
	('seed-brand-opella', 'seed-country-hong-kong'),
	('seed-brand-opella', 'seed-country-hungary'),
	('seed-brand-opella', 'seed-country-india'),
	('seed-brand-opella', 'seed-country-indonesia'),
	('seed-brand-opella', 'seed-country-ireland'),
	('seed-brand-opella', 'seed-country-israel'),
	('seed-brand-opella', 'seed-country-italy'),
	('seed-brand-opella', 'seed-country-japan'),
	('seed-brand-opella', 'seed-country-kazakhstan'),
	('seed-brand-opella', 'seed-country-latvia'),
	('seed-brand-opella', 'seed-country-lithuania'),
	('seed-brand-opella', 'seed-country-luxembourg'),
	('seed-brand-opella', 'seed-country-malaysia'),
	('seed-brand-opella', 'seed-country-mexico'),
	('seed-brand-opella', 'seed-country-montenegro'),
	('seed-brand-opella', 'seed-country-netherlands'),
	('seed-brand-opella', 'seed-country-new-zealand'),
	('seed-brand-opella', 'seed-country-norway'),
	('seed-brand-opella', 'seed-country-pakistan'),
	('seed-brand-opella', 'seed-country-peru'),
	('seed-brand-opella', 'seed-country-philippines'),
	('seed-brand-opella', 'seed-country-poland'),
	('seed-brand-opella', 'seed-country-portugal'),
	('seed-brand-opella', 'seed-country-romania'),
	('seed-brand-opella', 'seed-country-russia'),
	('seed-brand-opella', 'seed-country-saudi-arabia'),
	('seed-brand-opella', 'seed-country-serbia'),
	('seed-brand-opella', 'seed-country-singapore'),
	('seed-brand-opella', 'seed-country-slovakia'),
	('seed-brand-opella', 'seed-country-south-africa'),
	('seed-brand-opella', 'seed-country-south-korea'),
	('seed-brand-opella', 'seed-country-spain'),
	('seed-brand-opella', 'seed-country-sweden'),
	('seed-brand-opella', 'seed-country-switzerland'),
	('seed-brand-opella', 'seed-country-thailand'),
	('seed-brand-opella', 'seed-country-turkey'),
	('seed-brand-opella', 'seed-country-ukraine'),
	('seed-brand-opella', 'seed-country-united-arab-emirates'),
	('seed-brand-opella', 'seed-country-united-kingdom'),
	('seed-brand-opella', 'seed-country-united-states'),
	('seed-brand-opella', 'seed-country-uruguay'),
	('seed-brand-opella', 'seed-country-uzbekistan'),
	('seed-brand-opella', 'seed-country-venezuela'),
	('seed-brand-opella', 'seed-country-vietnam'),
	('seed-brand-oscal', 'seed-country-brazil'),
	('seed-brand-ostelin', 'seed-country-argentina'),
	('seed-brand-ostelin', 'seed-country-australia'),
	('seed-brand-ostelin', 'seed-country-austria'),
	('seed-brand-ostelin', 'seed-country-azerbaijan'),
	('seed-brand-ostelin', 'seed-country-belarus'),
	('seed-brand-ostelin', 'seed-country-belgium'),
	('seed-brand-ostelin', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-ostelin', 'seed-country-brazil'),
	('seed-brand-ostelin', 'seed-country-bulgaria'),
	('seed-brand-ostelin', 'seed-country-burundi'),
	('seed-brand-ostelin', 'seed-country-cambodia'),
	('seed-brand-ostelin', 'seed-country-canada'),
	('seed-brand-ostelin', 'seed-country-chile'),
	('seed-brand-ostelin', 'seed-country-china'),
	('seed-brand-ostelin', 'seed-country-colombia'),
	('seed-brand-ostelin', 'seed-country-croatia'),
	('seed-brand-ostelin', 'seed-country-czech-republic'),
	('seed-brand-ostelin', 'seed-country-denmark'),
	('seed-brand-ostelin', 'seed-country-dominican-republic'),
	('seed-brand-ostelin', 'seed-country-ecuador'),
	('seed-brand-ostelin', 'seed-country-egypt');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-ostelin', 'seed-country-estonia'),
	('seed-brand-ostelin', 'seed-country-finland'),
	('seed-brand-ostelin', 'seed-country-france'),
	('seed-brand-ostelin', 'seed-country-georgia'),
	('seed-brand-ostelin', 'seed-country-germany'),
	('seed-brand-ostelin', 'seed-country-greece'),
	('seed-brand-ostelin', 'seed-country-hong-kong'),
	('seed-brand-ostelin', 'seed-country-hungary'),
	('seed-brand-ostelin', 'seed-country-india'),
	('seed-brand-ostelin', 'seed-country-indonesia'),
	('seed-brand-ostelin', 'seed-country-ireland'),
	('seed-brand-ostelin', 'seed-country-israel'),
	('seed-brand-ostelin', 'seed-country-italy'),
	('seed-brand-ostelin', 'seed-country-japan'),
	('seed-brand-ostelin', 'seed-country-kazakhstan'),
	('seed-brand-ostelin', 'seed-country-latvia'),
	('seed-brand-ostelin', 'seed-country-lithuania'),
	('seed-brand-ostelin', 'seed-country-luxembourg'),
	('seed-brand-ostelin', 'seed-country-malaysia'),
	('seed-brand-ostelin', 'seed-country-mexico'),
	('seed-brand-ostelin', 'seed-country-montenegro'),
	('seed-brand-ostelin', 'seed-country-netherlands'),
	('seed-brand-ostelin', 'seed-country-new-zealand'),
	('seed-brand-ostelin', 'seed-country-norway'),
	('seed-brand-ostelin', 'seed-country-pakistan'),
	('seed-brand-ostelin', 'seed-country-peru'),
	('seed-brand-ostelin', 'seed-country-philippines'),
	('seed-brand-ostelin', 'seed-country-poland'),
	('seed-brand-ostelin', 'seed-country-portugal'),
	('seed-brand-ostelin', 'seed-country-romania'),
	('seed-brand-ostelin', 'seed-country-russia'),
	('seed-brand-ostelin', 'seed-country-saudi-arabia'),
	('seed-brand-ostelin', 'seed-country-serbia'),
	('seed-brand-ostelin', 'seed-country-singapore'),
	('seed-brand-ostelin', 'seed-country-slovakia'),
	('seed-brand-ostelin', 'seed-country-south-africa'),
	('seed-brand-ostelin', 'seed-country-south-korea'),
	('seed-brand-ostelin', 'seed-country-spain'),
	('seed-brand-ostelin', 'seed-country-sweden'),
	('seed-brand-ostelin', 'seed-country-switzerland'),
	('seed-brand-ostelin', 'seed-country-thailand'),
	('seed-brand-ostelin', 'seed-country-turkey'),
	('seed-brand-ostelin', 'seed-country-ukraine'),
	('seed-brand-ostelin', 'seed-country-united-arab-emirates'),
	('seed-brand-ostelin', 'seed-country-united-kingdom'),
	('seed-brand-ostelin', 'seed-country-united-states'),
	('seed-brand-ostelin', 'seed-country-uruguay'),
	('seed-brand-ostelin', 'seed-country-uzbekistan'),
	('seed-brand-ostelin', 'seed-country-venezuela'),
	('seed-brand-ostelin', 'seed-country-vietnam'),
	('seed-brand-paralen', 'seed-country-argentina'),
	('seed-brand-paralen', 'seed-country-australia'),
	('seed-brand-paralen', 'seed-country-austria'),
	('seed-brand-paralen', 'seed-country-azerbaijan'),
	('seed-brand-paralen', 'seed-country-belarus'),
	('seed-brand-paralen', 'seed-country-belgium'),
	('seed-brand-paralen', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-paralen', 'seed-country-brazil'),
	('seed-brand-paralen', 'seed-country-bulgaria'),
	('seed-brand-paralen', 'seed-country-burundi'),
	('seed-brand-paralen', 'seed-country-cambodia'),
	('seed-brand-paralen', 'seed-country-canada'),
	('seed-brand-paralen', 'seed-country-chile'),
	('seed-brand-paralen', 'seed-country-china'),
	('seed-brand-paralen', 'seed-country-colombia'),
	('seed-brand-paralen', 'seed-country-croatia'),
	('seed-brand-paralen', 'seed-country-czech-republic'),
	('seed-brand-paralen', 'seed-country-denmark'),
	('seed-brand-paralen', 'seed-country-dominican-republic'),
	('seed-brand-paralen', 'seed-country-ecuador'),
	('seed-brand-paralen', 'seed-country-egypt'),
	('seed-brand-paralen', 'seed-country-estonia'),
	('seed-brand-paralen', 'seed-country-finland'),
	('seed-brand-paralen', 'seed-country-france'),
	('seed-brand-paralen', 'seed-country-georgia'),
	('seed-brand-paralen', 'seed-country-germany'),
	('seed-brand-paralen', 'seed-country-greece'),
	('seed-brand-paralen', 'seed-country-hong-kong'),
	('seed-brand-paralen', 'seed-country-hungary'),
	('seed-brand-paralen', 'seed-country-india'),
	('seed-brand-paralen', 'seed-country-indonesia'),
	('seed-brand-paralen', 'seed-country-ireland'),
	('seed-brand-paralen', 'seed-country-israel'),
	('seed-brand-paralen', 'seed-country-italy'),
	('seed-brand-paralen', 'seed-country-japan'),
	('seed-brand-paralen', 'seed-country-kazakhstan'),
	('seed-brand-paralen', 'seed-country-latvia'),
	('seed-brand-paralen', 'seed-country-lithuania'),
	('seed-brand-paralen', 'seed-country-luxembourg'),
	('seed-brand-paralen', 'seed-country-malaysia'),
	('seed-brand-paralen', 'seed-country-mexico'),
	('seed-brand-paralen', 'seed-country-montenegro'),
	('seed-brand-paralen', 'seed-country-netherlands'),
	('seed-brand-paralen', 'seed-country-new-zealand'),
	('seed-brand-paralen', 'seed-country-norway'),
	('seed-brand-paralen', 'seed-country-pakistan'),
	('seed-brand-paralen', 'seed-country-peru'),
	('seed-brand-paralen', 'seed-country-philippines'),
	('seed-brand-paralen', 'seed-country-poland'),
	('seed-brand-paralen', 'seed-country-portugal');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-paralen', 'seed-country-romania'),
	('seed-brand-paralen', 'seed-country-russia'),
	('seed-brand-paralen', 'seed-country-saudi-arabia'),
	('seed-brand-paralen', 'seed-country-serbia'),
	('seed-brand-paralen', 'seed-country-singapore'),
	('seed-brand-paralen', 'seed-country-slovakia'),
	('seed-brand-paralen', 'seed-country-south-africa'),
	('seed-brand-paralen', 'seed-country-south-korea'),
	('seed-brand-paralen', 'seed-country-spain'),
	('seed-brand-paralen', 'seed-country-sweden'),
	('seed-brand-paralen', 'seed-country-switzerland'),
	('seed-brand-paralen', 'seed-country-thailand'),
	('seed-brand-paralen', 'seed-country-turkey'),
	('seed-brand-paralen', 'seed-country-ukraine'),
	('seed-brand-paralen', 'seed-country-united-arab-emirates'),
	('seed-brand-paralen', 'seed-country-united-kingdom'),
	('seed-brand-paralen', 'seed-country-united-states'),
	('seed-brand-paralen', 'seed-country-uruguay'),
	('seed-brand-paralen', 'seed-country-uzbekistan'),
	('seed-brand-paralen', 'seed-country-venezuela'),
	('seed-brand-paralen', 'seed-country-vietnam'),
	('seed-brand-pharmaton', 'seed-country-argentina'),
	('seed-brand-pharmaton', 'seed-country-australia'),
	('seed-brand-pharmaton', 'seed-country-austria'),
	('seed-brand-pharmaton', 'seed-country-azerbaijan'),
	('seed-brand-pharmaton', 'seed-country-belarus'),
	('seed-brand-pharmaton', 'seed-country-belgium'),
	('seed-brand-pharmaton', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-pharmaton', 'seed-country-brazil'),
	('seed-brand-pharmaton', 'seed-country-bulgaria'),
	('seed-brand-pharmaton', 'seed-country-burundi'),
	('seed-brand-pharmaton', 'seed-country-cambodia'),
	('seed-brand-pharmaton', 'seed-country-canada'),
	('seed-brand-pharmaton', 'seed-country-chile'),
	('seed-brand-pharmaton', 'seed-country-china'),
	('seed-brand-pharmaton', 'seed-country-colombia'),
	('seed-brand-pharmaton', 'seed-country-croatia'),
	('seed-brand-pharmaton', 'seed-country-czech-republic'),
	('seed-brand-pharmaton', 'seed-country-denmark'),
	('seed-brand-pharmaton', 'seed-country-dominican-republic'),
	('seed-brand-pharmaton', 'seed-country-ecuador'),
	('seed-brand-pharmaton', 'seed-country-egypt'),
	('seed-brand-pharmaton', 'seed-country-estonia'),
	('seed-brand-pharmaton', 'seed-country-finland'),
	('seed-brand-pharmaton', 'seed-country-france'),
	('seed-brand-pharmaton', 'seed-country-georgia'),
	('seed-brand-pharmaton', 'seed-country-germany'),
	('seed-brand-pharmaton', 'seed-country-greece'),
	('seed-brand-pharmaton', 'seed-country-hong-kong'),
	('seed-brand-pharmaton', 'seed-country-hungary'),
	('seed-brand-pharmaton', 'seed-country-india'),
	('seed-brand-pharmaton', 'seed-country-indonesia'),
	('seed-brand-pharmaton', 'seed-country-ireland'),
	('seed-brand-pharmaton', 'seed-country-israel'),
	('seed-brand-pharmaton', 'seed-country-italy'),
	('seed-brand-pharmaton', 'seed-country-japan'),
	('seed-brand-pharmaton', 'seed-country-kazakhstan'),
	('seed-brand-pharmaton', 'seed-country-latvia'),
	('seed-brand-pharmaton', 'seed-country-lithuania'),
	('seed-brand-pharmaton', 'seed-country-luxembourg'),
	('seed-brand-pharmaton', 'seed-country-malaysia'),
	('seed-brand-pharmaton', 'seed-country-mexico'),
	('seed-brand-pharmaton', 'seed-country-montenegro'),
	('seed-brand-pharmaton', 'seed-country-netherlands'),
	('seed-brand-pharmaton', 'seed-country-new-zealand'),
	('seed-brand-pharmaton', 'seed-country-norway'),
	('seed-brand-pharmaton', 'seed-country-pakistan'),
	('seed-brand-pharmaton', 'seed-country-peru'),
	('seed-brand-pharmaton', 'seed-country-philippines'),
	('seed-brand-pharmaton', 'seed-country-poland'),
	('seed-brand-pharmaton', 'seed-country-portugal'),
	('seed-brand-pharmaton', 'seed-country-romania'),
	('seed-brand-pharmaton', 'seed-country-russia'),
	('seed-brand-pharmaton', 'seed-country-saudi-arabia'),
	('seed-brand-pharmaton', 'seed-country-serbia'),
	('seed-brand-pharmaton', 'seed-country-singapore'),
	('seed-brand-pharmaton', 'seed-country-slovakia'),
	('seed-brand-pharmaton', 'seed-country-south-africa'),
	('seed-brand-pharmaton', 'seed-country-south-korea'),
	('seed-brand-pharmaton', 'seed-country-spain'),
	('seed-brand-pharmaton', 'seed-country-sweden'),
	('seed-brand-pharmaton', 'seed-country-switzerland'),
	('seed-brand-pharmaton', 'seed-country-thailand'),
	('seed-brand-pharmaton', 'seed-country-turkey'),
	('seed-brand-pharmaton', 'seed-country-ukraine'),
	('seed-brand-pharmaton', 'seed-country-united-arab-emirates'),
	('seed-brand-pharmaton', 'seed-country-united-kingdom'),
	('seed-brand-pharmaton', 'seed-country-united-states'),
	('seed-brand-pharmaton', 'seed-country-uruguay'),
	('seed-brand-pharmaton', 'seed-country-uzbekistan'),
	('seed-brand-pharmaton', 'seed-country-venezuela'),
	('seed-brand-pharmaton', 'seed-country-vietnam'),
	('seed-brand-phenergan', 'seed-country-ireland'),
	('seed-brand-phosphalugel', 'seed-country-vietnam'),
	('seed-brand-physiomer', 'seed-country-france'),
	('seed-brand-phytoxil', 'seed-country-france'),
	('seed-brand-quarelin', 'seed-country-hungary'),
	('seed-brand-rhinospray', 'seed-country-argentina'),
	('seed-brand-rhinospray', 'seed-country-australia'),
	('seed-brand-rhinospray', 'seed-country-austria');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-rhinospray', 'seed-country-azerbaijan'),
	('seed-brand-rhinospray', 'seed-country-belarus'),
	('seed-brand-rhinospray', 'seed-country-belgium'),
	('seed-brand-rhinospray', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-rhinospray', 'seed-country-brazil'),
	('seed-brand-rhinospray', 'seed-country-bulgaria'),
	('seed-brand-rhinospray', 'seed-country-burundi'),
	('seed-brand-rhinospray', 'seed-country-cambodia'),
	('seed-brand-rhinospray', 'seed-country-canada'),
	('seed-brand-rhinospray', 'seed-country-chile'),
	('seed-brand-rhinospray', 'seed-country-china'),
	('seed-brand-rhinospray', 'seed-country-colombia'),
	('seed-brand-rhinospray', 'seed-country-croatia'),
	('seed-brand-rhinospray', 'seed-country-czech-republic'),
	('seed-brand-rhinospray', 'seed-country-denmark'),
	('seed-brand-rhinospray', 'seed-country-dominican-republic'),
	('seed-brand-rhinospray', 'seed-country-ecuador'),
	('seed-brand-rhinospray', 'seed-country-egypt'),
	('seed-brand-rhinospray', 'seed-country-estonia'),
	('seed-brand-rhinospray', 'seed-country-finland'),
	('seed-brand-rhinospray', 'seed-country-france'),
	('seed-brand-rhinospray', 'seed-country-georgia'),
	('seed-brand-rhinospray', 'seed-country-germany'),
	('seed-brand-rhinospray', 'seed-country-greece'),
	('seed-brand-rhinospray', 'seed-country-hong-kong'),
	('seed-brand-rhinospray', 'seed-country-hungary'),
	('seed-brand-rhinospray', 'seed-country-india'),
	('seed-brand-rhinospray', 'seed-country-indonesia'),
	('seed-brand-rhinospray', 'seed-country-ireland'),
	('seed-brand-rhinospray', 'seed-country-israel'),
	('seed-brand-rhinospray', 'seed-country-italy'),
	('seed-brand-rhinospray', 'seed-country-japan'),
	('seed-brand-rhinospray', 'seed-country-kazakhstan'),
	('seed-brand-rhinospray', 'seed-country-latvia'),
	('seed-brand-rhinospray', 'seed-country-lithuania'),
	('seed-brand-rhinospray', 'seed-country-luxembourg'),
	('seed-brand-rhinospray', 'seed-country-malaysia'),
	('seed-brand-rhinospray', 'seed-country-mexico'),
	('seed-brand-rhinospray', 'seed-country-montenegro'),
	('seed-brand-rhinospray', 'seed-country-netherlands'),
	('seed-brand-rhinospray', 'seed-country-new-zealand'),
	('seed-brand-rhinospray', 'seed-country-norway'),
	('seed-brand-rhinospray', 'seed-country-pakistan'),
	('seed-brand-rhinospray', 'seed-country-peru'),
	('seed-brand-rhinospray', 'seed-country-philippines'),
	('seed-brand-rhinospray', 'seed-country-poland'),
	('seed-brand-rhinospray', 'seed-country-portugal'),
	('seed-brand-rhinospray', 'seed-country-romania'),
	('seed-brand-rhinospray', 'seed-country-russia'),
	('seed-brand-rhinospray', 'seed-country-saudi-arabia'),
	('seed-brand-rhinospray', 'seed-country-serbia'),
	('seed-brand-rhinospray', 'seed-country-singapore'),
	('seed-brand-rhinospray', 'seed-country-slovakia'),
	('seed-brand-rhinospray', 'seed-country-south-africa'),
	('seed-brand-rhinospray', 'seed-country-south-korea'),
	('seed-brand-rhinospray', 'seed-country-spain'),
	('seed-brand-rhinospray', 'seed-country-sweden'),
	('seed-brand-rhinospray', 'seed-country-switzerland'),
	('seed-brand-rhinospray', 'seed-country-thailand'),
	('seed-brand-rhinospray', 'seed-country-turkey'),
	('seed-brand-rhinospray', 'seed-country-ukraine'),
	('seed-brand-rhinospray', 'seed-country-united-arab-emirates'),
	('seed-brand-rhinospray', 'seed-country-united-kingdom'),
	('seed-brand-rhinospray', 'seed-country-united-states'),
	('seed-brand-rhinospray', 'seed-country-uruguay'),
	('seed-brand-rhinospray', 'seed-country-uzbekistan'),
	('seed-brand-rhinospray', 'seed-country-venezuela'),
	('seed-brand-rhinospray', 'seed-country-vietnam'),
	('seed-brand-selsun-blue', 'seed-country-australia'),
	('seed-brand-selsun-blue', 'seed-country-canada'),
	('seed-brand-selsun-blue', 'seed-country-pakistan'),
	('seed-brand-selsun-blue', 'seed-country-united-states'),
	('seed-brand-sinuberase', 'seed-country-mexico'),
	('seed-brand-targifor', 'seed-country-brazil'),
	('seed-brand-thomapyrin', 'seed-country-germany'),
	('seed-brand-toplexil', 'seed-country-argentina'),
	('seed-brand-toplexil', 'seed-country-australia'),
	('seed-brand-toplexil', 'seed-country-austria'),
	('seed-brand-toplexil', 'seed-country-azerbaijan'),
	('seed-brand-toplexil', 'seed-country-belarus'),
	('seed-brand-toplexil', 'seed-country-belgium'),
	('seed-brand-toplexil', 'seed-country-bosnia-and-herzegovina'),
	('seed-brand-toplexil', 'seed-country-brazil'),
	('seed-brand-toplexil', 'seed-country-bulgaria'),
	('seed-brand-toplexil', 'seed-country-burundi'),
	('seed-brand-toplexil', 'seed-country-cambodia'),
	('seed-brand-toplexil', 'seed-country-canada'),
	('seed-brand-toplexil', 'seed-country-chile'),
	('seed-brand-toplexil', 'seed-country-china'),
	('seed-brand-toplexil', 'seed-country-colombia'),
	('seed-brand-toplexil', 'seed-country-croatia'),
	('seed-brand-toplexil', 'seed-country-czech-republic'),
	('seed-brand-toplexil', 'seed-country-denmark'),
	('seed-brand-toplexil', 'seed-country-dominican-republic'),
	('seed-brand-toplexil', 'seed-country-ecuador'),
	('seed-brand-toplexil', 'seed-country-egypt'),
	('seed-brand-toplexil', 'seed-country-estonia'),
	('seed-brand-toplexil', 'seed-country-finland'),
	('seed-brand-toplexil', 'seed-country-france'),
	('seed-brand-toplexil', 'seed-country-georgia');
INSERT INTO public.brand_country_availability (brand_id, country_id) VALUES
	('seed-brand-toplexil', 'seed-country-germany'),
	('seed-brand-toplexil', 'seed-country-greece'),
	('seed-brand-toplexil', 'seed-country-hong-kong'),
	('seed-brand-toplexil', 'seed-country-hungary'),
	('seed-brand-toplexil', 'seed-country-india'),
	('seed-brand-toplexil', 'seed-country-indonesia'),
	('seed-brand-toplexil', 'seed-country-ireland'),
	('seed-brand-toplexil', 'seed-country-israel'),
	('seed-brand-toplexil', 'seed-country-italy'),
	('seed-brand-toplexil', 'seed-country-japan'),
	('seed-brand-toplexil', 'seed-country-kazakhstan'),
	('seed-brand-toplexil', 'seed-country-latvia'),
	('seed-brand-toplexil', 'seed-country-lithuania'),
	('seed-brand-toplexil', 'seed-country-luxembourg'),
	('seed-brand-toplexil', 'seed-country-malaysia'),
	('seed-brand-toplexil', 'seed-country-mexico'),
	('seed-brand-toplexil', 'seed-country-montenegro'),
	('seed-brand-toplexil', 'seed-country-netherlands'),
	('seed-brand-toplexil', 'seed-country-new-zealand'),
	('seed-brand-toplexil', 'seed-country-norway'),
	('seed-brand-toplexil', 'seed-country-pakistan'),
	('seed-brand-toplexil', 'seed-country-peru'),
	('seed-brand-toplexil', 'seed-country-philippines'),
	('seed-brand-toplexil', 'seed-country-poland'),
	('seed-brand-toplexil', 'seed-country-portugal'),
	('seed-brand-toplexil', 'seed-country-romania'),
	('seed-brand-toplexil', 'seed-country-russia'),
	('seed-brand-toplexil', 'seed-country-saudi-arabia'),
	('seed-brand-toplexil', 'seed-country-serbia'),
	('seed-brand-toplexil', 'seed-country-singapore'),
	('seed-brand-toplexil', 'seed-country-slovakia'),
	('seed-brand-toplexil', 'seed-country-south-africa'),
	('seed-brand-toplexil', 'seed-country-south-korea'),
	('seed-brand-toplexil', 'seed-country-spain'),
	('seed-brand-toplexil', 'seed-country-sweden'),
	('seed-brand-toplexil', 'seed-country-switzerland'),
	('seed-brand-toplexil', 'seed-country-thailand'),
	('seed-brand-toplexil', 'seed-country-turkey'),
	('seed-brand-toplexil', 'seed-country-ukraine'),
	('seed-brand-toplexil', 'seed-country-united-arab-emirates'),
	('seed-brand-toplexil', 'seed-country-united-kingdom'),
	('seed-brand-toplexil', 'seed-country-united-states'),
	('seed-brand-toplexil', 'seed-country-uruguay'),
	('seed-brand-toplexil', 'seed-country-uzbekistan'),
	('seed-brand-toplexil', 'seed-country-venezuela'),
	('seed-brand-toplexil', 'seed-country-vietnam'),
	('seed-brand-unisom', 'seed-country-united-states'),
	('seed-brand-xyzal', 'seed-country-united-states'),
	('seed-brand-zantac', 'seed-country-united-states');


--
-- Data for Name: control_definition; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.control_definition (id, control_code, active, created_by_user_id, created_at, updated_at) VALUES
	('e200352e-0c7e-44a8-99d9-ee26022158eb', 'ACCESS-02_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('ffda744c-fb35-4f8d-aec4-d1b6432f3df5', 'B&R-01_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('43625c0a-b585-4b1a-b2b3-e456187f8965', 'BC-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('da8a52ab-2fc3-4f99-8728-62c2ffef289f', 'BC-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('39730620-298d-47f0-a3a6-07c807e251b3', 'RES-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('752438e6-14b0-46e0-83f1-980f8de92c5b', 'RES-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('b609db82-c28e-4a50-ad00-89eca8327616', 'RES-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5843c09a-3dfe-41c3-87ef-5d677f72dfe6', 'RES-04', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('2b3668f2-14c9-4ffe-9bb2-173d2983d07b', 'DP-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('181f3c6d-f4d8-4582-ba3e-990a25de96f3', 'DP-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f050e6d6-32ac-4749-b217-7b079e739ea4', 'DEL-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('9f7ef809-87e9-4f33-8aca-0753a3357f7e', 'DEL-10', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('50612162-2854-4558-8a23-f6241f7a2c48', 'DEL-13_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('c57c3e99-c9a0-4890-ade1-4e3d06463548', 'DEL-14', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('81f8fd1e-d226-462e-afa8-9ef1a2c5d07b', 'DEL-15', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5f9afb33-fa7f-4193-9eec-76bb84f92a1c', 'DEL-16', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('620478d8-cc17-4a45-83a9-0d2da737e6ac', 'DEL-17', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('d2b2151a-ca2b-4cc6-80c7-a8d69aabadc3', 'DEL-18', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('55c1a526-c20f-4bcc-88f1-ccf5f804f5c0', 'QUAL-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('923877ba-497e-45e7-9378-14841db4eeb5', 'QUAL-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5113db89-d701-4833-ba41-0861b6d78b8d', 'QUAL-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('2f809e49-063f-4de8-aeb2-6238dfd023ef', 'RISK-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5cfb7e3c-6f86-4f12-8faa-cf3a20b3ef1f', 'SEC-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('d6a4f79e-9f17-4da1-9765-3ba5291ddb97', 'SEC-02_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('1a86ec24-95f5-4310-9369-f5b93d33a91b', 'SEC-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('865139a5-726a-4402-a3ac-eceaf051bf86', 'SEC-04', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5963099b-6be9-4ec1-96db-a7471d87c5d7', 'SEC-05', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('690a3006-2358-42da-8075-912a062b66b1', 'SEC-06', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('c86b0c27-30fb-405f-acbd-a392d8c8a43b', 'SEC-07', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f59a8266-784b-48e9-a903-d228e39fc23e', 'SUP-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('86b82cdf-84dd-4ee6-bc8f-6ee5698cd4fd', 'SUP-02_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('d2596b40-4456-4c7e-ad89-e990b34d9b1b', 'SUP-03_SIC', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5c9909da-bdba-47eb-88ba-af66890170f7', 'SUP-04', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('58de171c-5cb9-4b32-9d78-060b76aaa29f', 'DEL-19', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('538c492c-245b-490a-86cd-39ce496831b4', 'DEL-20', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f6e69665-74c5-47f3-8fe0-8387631fd439', 'DEL-21', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('1a2d005c-4d48-4d90-b479-673720b2b191', 'DEL-22', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('e39c24d2-dc35-4be0-827d-e305640a236b', 'MONIT-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('828802e9-318d-4d12-a854-9786209e4e63', 'MONIT-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('a0405e56-a891-44df-828e-55daf4675d09', 'MONIT-04', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('9ce48c02-47c1-4232-91ce-0f9d6469c7f4', 'DEL-23', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('010a40d2-eae8-4d61-b2bf-d0e4d8589d64', 'DEL-24', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079');


--
-- Data for Name: control_definition_version; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.control_definition_version (id, control_definition_id, version_number, catalog_version_key, version_reason, owner_team, it_process, slc_phase, attestation_type, statement, objective, source_of_truth, targeted_evidence, attestation_guidance, applicability_type, trigger_rule, created_by_user_id, created_at, updated_at, auto_attestation_rule, revalidation_interval_months, reviewer_team, assessment_template_key, evidence_required) VALUES
	('c3325357-be7f-44c0-8dff-738d61d652ec', 'e200352e-0c7e-44a8-99d9-ee26022158eb', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_ACCESS', 'RUN', 'APPROVAL_REQUIRED', 'Activities Review for privileged accesses', 'Activities performed by IT members with privileged accesses must be reviewed :
- For GxP regulated digital solution, the review of activities must be covered as applicable by the audit trail review
- For SOX & CSRD regulated digital solution, activities of IT accounts with extended rights (e.g. Firefighters, Privileged accounts) which can have impacts on SOX/CSRD data must be reviewed and documented at least annually.', '1. GQCMS-QU-STD-0000452-User Access Management Controls: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/867621
2. DFC-QU-STD-0000298-Access Control: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/581828
3. DIG-CO-SOP-0015241-SAP Security Baseline: https://opella-connect.veevavault.com/ui/#permalink=V190000000JN001
4. DFC-QU-SOP-0087024-Business Application Access Management: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/738198', '* Audit trail review record/report for GxP-regulated digital solutions, covering activities performed under privileged access
* Documented review log for SOX/CSRD-regulated solutions, covering extended-rights accounts (e.g. Firefighter, Privileged accounts), performed and evidenced at least annually* Reviewer sign-off/approval confirming the review was completed (name, date, scope covered)
* Record of any anomalies or inappropriate activity identified during the review, with follow-up/remediation evidence
* List of in-scope privileged/extended-rights accounts at the time of review, to confirm completeness of coverage', 'When attesting this control, consider the following:
 
 -Is a review of activities performed with IT privileged accesses conducted and documented for GxP, SOX and CSRD digital solutions?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'CYBERSECURITY', NULL, true),
	('8d0cbb09-c6b9-432b-a7be-37fc71377920', 'ffda744c-fb35-4f8d-aec4-d1b6432f3df5', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'DEPLOY', 'APPROVAL_REQUIRED', 'Backup implementation', 'Digital solutions must have backup implemented (scheduled, executed and monitored) to meet business needs.', 'DFC-QU-SOP-0086073-Backup and Restore - Infrastructure: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/477883', 'Backup requirements describing all the components to be backed up with the required SLA documented and implemented with effective monitoring in place.', 'When attesting this control, consider the following:

Back-up set up:
- Is backup specification documented for the digital solution using the backup specification template?
- Is the backup configured?

Monitoring and logs:
- Is the backup monitoring effective and are failures captured?
- Are the logs traceable and retained for ≥ 6 months?

- For digital solution hosted externally, are back up requirements covered in the contractual clauses with the Third Party?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, 'CYBERSECURITY', NULL, true),
	('5faccb24-f44e-41c6-904d-87f701c3d059', '43625c0a-b585-4b1a-b2b3-e456187f8965', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Business Continuity', 'A business continuity management process must be defined (e.g., Business Continuity Plan) at business process level with adequate measures established and tested (including Disaster Recovery strategy activation if applicable) to ensure business operations during digital solution’s unavailability (e.g., disasters). This process must be maintained and regularly reviewed to ensure its effectiveness and accuracy.', '1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009
2. QUA-CO-OPE-0093984-Business Continuity Plan for GxP Computerized Systems: https://opella-connect.veevavault.com/ui/#permalink=V190000000EQ023', 'Actionable business continuity plan describing how the business activities will be executed in case of digital solution''s unavailability.', 'When attesting this control, consider the following:

* Is a Business Continuity Plan (BCP) defined at the business process level for this digital solution?
* Does the BCP describe adequate measure to sustain business activities during the solutions'' unavailability (e.g. manual workarounds, alternate processes)?
* For applicable solutions: does the BCP include Disaster Recovery strategy activation steps?
* Is the BCP reviewed and updated on a regular cadence to ensure it remains accurate and effective (e.g. after solution changes, org changes, or prior test findings)?
* Is the BCP readily accessible to the people who would need to execute it during an actual disruption?
* Any digital solution without a maintained, tested BCP - or with a BCP that hasn''t been reviewed within its required cycle - should be treated as non-complaint.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('5c7dbc4f-a71c-4df8-9699-5fc60b7455e6', 'da8a52ab-2fc3-4f99-8728-62c2ffef289f', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Alternate Procedures and Continuity Measures', 'Ensure business continuity can be maintained when the digital solution becomes unavailable.', 'DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard
SECU-CO-MAN-0000101-Business Continuity Management Policy', 'Documented alternate procedures
Business Continuity Plan
Work instructions
Training material
Exercise or test results
Evidence of periodic review and update
Corrective actions arising from continuity exercises', 'When attesting this control, consider the following:

Documentation
Are alternative procedures documented for the affected business activities?
Are the procedures sufficiently detailed for users to execute them without relying on undocumented knowledge?
Are roles and responsibilities clearly defined?
Availability
Are the documented procedures available to the personnel who would need to execute them during a disruption?
Can the procedures be accessed if the digital solution is unavailable?
Training
Have relevant personnel been trained on the alternative procedures?
Is training evidence available?
Testing
Have the alternative procedures been exercised, tested, or used in practice?
Were the exercises documented?
Were lessons learned captured?
Maintenance
Have the procedures been reviewed within the defined review cycle?
Have changes in processes, systems, suppliers, or organization been reflected in the procedures?
Effectiveness
Would the alternative procedures allow the business activity to continue for the expected disruption period?
Are there significant manual dependencies or bottlenecks that could prevent successful execution?
Were any issues identified during testing remediated and tracked to closure?

Non-Compliance Indicators

The control should be considered non-compliant when:

No alternative procedure exists.
Procedures are undocumented.
Procedures have never been tested.
Personnel are unaware of the procedures.
Procedures are outdated or no longer applicable.
Significant deficiencies identified during testing remain unresolved.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('8f6b96d0-8200-437b-a610-d4e78a2bf51e', '620478d8-cc17-4a45-83a9-0d2da737e6ac', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Output Evaluation', 'AI outputs shall be evaluated against predefined acceptance criteria before release.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Evaluation Report, UAT Results, Test Evidence', 'Have AI outputs been evaluated before deployment? Have acceptance criteria been defined and approved? Has testing been performed using representative business scenarios? Have evaluation results been documented and reviewed? Are identified issues tracked and resolved before release?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('f567134d-070e-4b4c-9e43-41d17dbb97b7', '39730620-298d-47f0-a3a6-07c807e251b3', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Recovery Time Objective Demonstration', 'Vital digital solutions shall demonstrate through testing and documented evidence that recovery can be completed within the approved Recovery Time Objective.', 'DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard
SECU-CO-MAN-0000101-Business Continuity Management Policy', 'Recovery exercise
Recovery exercise report
Recovery timings documented: Start time, End time, Measured RTO
Data recovery validated
Deviations documented and remediated', 'When attesting this control, consider the following:
Recovery Performance
Has recovery been timed?
Was recovery completed within the approved RTO (Platinum RTO ≤2; Gold RTO ≤ 4 hours)?
Was the approved RPO achieved (≤ 15 mins)?
Were all critical services, data and integrations restored?
Were all critical services restored?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('41719211-e676-4118-a1b4-cb8cdc547d62', '752438e6-14b0-46e0-83f1-980f8de92c5b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Critical Dependency Identification and Recovery Sequencing', 'Dependencies required for recovery shall be identified, documented, and included in recovery procedures and testing activities.', 'DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard
SECU-CO-MAN-0000101-Business Continuity Management Policy', 'Dependency map
Recovery sequence
Architecture documentation', 'When attesting this control, consider the following:

Dependency Identification
Have all business, technical, infrastructure, security, data, identity, network, integration, and third-party dependencies required for operation and recovery of the digital solution been identified?
Are dependencies documented in architecture diagrams, recovery procedures, or dependency inventories?
Does the dependency inventory include both internal and external services?
Single Points of Failure
Have potential single points of failure been identified and assessed?
Have mitigation measures been implemented, documented, or formally accepted through risk management processes?
Recovery Sequence
Is the recovery sequence documented?
Does the recovery sequence identify which systems, services, databases, integrations, and infrastructure components must be recovered first?
Is the recovery order consistent with the documented recovery procedures?
Recovery Objectives
Are dependency recovery objectives aligned with the digital solution''s Recovery Time Objective (RTO) and Recovery Point Objective (RPO)?
Could any dependency prevent achievement of the approved recovery objectives?
Third-Party Dependencies
For externally provided services, are supplier recovery responsibilities documented?
Has the supplier demonstrated recovery capability through testing, assurance reports, or contractual commitments?
Evidence Quality
Is there evidence that dependency information has been reviewed and updated following significant architecture, supplier, or infrastructure changes?
Non-Compliance Indicators

The control should be considered non-compliant if:

Critical dependencies are unknown or undocumented.
Recovery sequencing is not defined.
Dependency recovery objectives exceed the solution''s approved RTO or RPO.
Single points of failure have not been assessed.
Recovery relies on undocumented supplier capabilities.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('2b4e68bd-2ea7-4232-b135-dc44db5e2d70', 'b609db82-c28e-4a50-ad00-89eca8327616', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Vital Application Recovery Readiness Review', 'Ensure recovery objectives and recovery capabilities are defined, implemented, tested, and aligned with the assigned Recovery Tier and Business Criticality classification of the digital solution.', 'DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard
SECU-CO-MAN-0000101-Business Continuity Management Policy', 'Annual review report
Action tracking
Updated DR documentation', 'When attesting this control, consider the following:
Recovery Asset Protection
Are recovery assets identified and documented?
Do recovery assets include backups, configurations, infrastructure definitions, application components, scripts, documentation, recovery credentials, and recovery environments where applicable?
Are recovery assets protected from unauthorized modification or deletion?
Recovery Environment
Is a recovery environment available and documented?
Can recovery activities be executed independently from a compromised production environment?
Are recovery procedures clearly documented?
Recovery Credentials
Are recovery accounts and credentials protected and managed appropriately?
Can recovery activities still be performed if production privileged accounts are unavailable or compromised?
Recovery Integrity
Are processes defined to verify the integrity and validity of recovered systems, data, and configurations?
Does the recovery process include validation activities before restored services are returned to operation?
Testing and Validation
Has the recovery design been tested?
Do test results demonstrate successful recovery of the required components?
Were recovery issues identified during testing tracked and remediated?
Recovery Objective Achievement
Does available evidence demonstrate that the cyber recovery design can support the approved Recovery Time Objective (RTO) and Recovery Point Objective (RPO)?
For Vital applications, does the design demonstrate capability to support Platinum recovery requirements?
Third-Party Recovery
For externally hosted or supplier-supported solutions, has evidence been reviewed demonstrating the supplier''s ability to support recovery requirements?
Are responsibilities clearly documented through a Shared Responsibility Model?

Compliance Indicators
Pass
Recovery Tier assigned.
RTO and RPO defined.
Recovery capability documented.
Recovery capability tested or validated.
No material open recovery gaps.

Conditional Pass
Recovery capability exists.
Minor documentation, testing, or remediation gaps remain.
Defined action plan exists.

Fail
Recovery Tier not assigned.
Recovery objectives undefined.
Recovery capability not documented.
No evidence of recovery validation.
Material recovery gaps remain unmanaged.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'CYBERSECURITY', NULL, true),
	('f4c19bbc-3b83-4822-9aaf-3f5284fabccc', '5843c09a-3dfe-41c3-87ef-5d677f72dfe6', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_CONTINUITY', 'BUILD', 'APPROVAL_REQUIRED', 'Recovery Objective Validation', 'Ensure the digital solution can demonstrably recover within approved recovery objectives and that recovery capabilities remain effective throughout the solution lifecycle.', 'DIG-CO-OPE-0293533-Corporate Digital Service Continuity and Disaster Recovery Standard
SECU-CO-MAN-0000101-Business Continuity Management Policy', 'Recovery test reports
Disaster Recovery exercise reports
Measured recovery duration
Measured data recovery point
Recovery validation evidence
Recovery improvement actions
Test result approvals
Supplier recovery testing evidence (where applicable)', 'When attesting this control, consider the following:

Recovery Testing
Has a recovery exercise been performed?
Was the recovery exercise completed using documented recovery procedures?
Was the exercise representative of the recovery scenario being evaluated?
Recovery Time Objective (RTO)
Was the actual recovery duration measured?
Did the digital solution achieve the approved Recovery Time Objective?
If the approved RTO was not achieved, was a remediation plan documented?
Recovery Point Objective (RPO)
Was the actual data recovery point measured?
Did the digital solution achieve the approved Recovery Point Objective?
Was any data loss within the approved tolerance?
Recovery Scope
Were all critical solution components recovered?
Were critical data, configurations, interfaces, integrations, and supporting services included in the recovery validation?
Were dependencies recovered and operational?
Business Validation
Was business functionality validated following recovery?
Were business users involved where appropriate?
Was the recovered solution demonstrated to be fit for use?
Remediation and Continuous Improvement
Were recovery issues, delays, or failures documented?
Were corrective actions assigned and tracked?
Has evidence of remediation been reviewed when required?
Third-Party Recovery

For supplier-supported solutions:

Has supplier recovery evidence been reviewed?
Has the supplier demonstrated recovery capability consistent with contractual commitments?
Are supplier recovery responsibilities clearly documented?
Non-Compliance Indicators

This control should be considered non-compliant if:

Recovery exercises have not been performed.
Recovery objectives cannot be demonstrated.
Recovery time was not measured.
Recovery point was not measured.
Recovery exceeded approved objectives without remediation.
Critical components were not included in testing.
Recovery evidence is unavailable.
Supplier recovery capabilities cannot be demonstrated where applicable.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('d66cd55a-434b-4b56-b8f2-ecddd0d22928', '2b3668f2-14c9-4ffe-9bb2-173d2983d07b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_RISK', 'PLAN', 'SELF_ATTESTATION', 'Execute Personal Data Privacy Assessment', 'The  the digital solution must undergo a privacy Data Asset Assessment (DAA) to evaluate compliance with privacy requirements.', '1. EBI-CO-STD-0000410-Opella Data Privacy Standard (v1.0)
https://opella-connect.veevavault.com/ui/#permalink=V190000000KB037

2. Privacy Hub
https://sanofi.sharepoint.com/sites/opella-compliance-site/SitePages/Work-with-personal-data-v1.0.aspx?CT=1736934649051&OR=OWA-NT-Mail&CID=47d9fdb6-098e-ddca-947b-ad4f41eab8f3', 'Personal Data Privacy Assessment documented in OneTrust.', '1. The digital solution is inventoried as "digital asset" in the Opella Privacy Care (One Trust) asset inventory
2. A Digital Asset Assessment exists and it is either in status "Completed" or "Completed with open risks"
3. If the Digital Asset Assessment is "completed with open risks", all the risks must be in a status different from "Ongoing mitigation" (Avoided, Reduced, Accepted, Expired or Materialized)', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'DATA_PRIVACY', NULL, true),
	('fa410512-c11f-4cb0-b07d-387a9f249424', '181f3c6d-f4d8-4582-ba3e-990a25de96f3', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_RISK', 'PLAN', 'SELF_ATTESTATION', 'Complete Privacy Compliance Declaratoin', 'The owner of the digital solution must self attest compliance with a list of requirements, depending on the type of the digital solution', '1. EBI-CO-STD-0000410-Opella Data Privacy Standard (v1.0)
https://opella-connect.veevavault.com/ui/#permalink=V190000000KB037

2. Privacy Hub
https://sanofi.sharepoint.com/sites/opella-compliance-site/SitePages/Work-with-personal-data-v1.0.aspx?CT=1736934649051&OR=OWA-NT-Mail&CID=47d9fdb6-098e-ddca-947b-ad4f41eab8f4', 'Privacy Compliance declaration in the risk profiling tool', 'The owner of the Digital Property must self-attest compliance with certain requirements depending on the digital property type, as a mandatory pre-condition for go-live approval

For all Digital Solutions, this will be captured in OneTrust when the Digital Assessment is performed.', 'ALWAYS', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'DATA_PRIVACY', 'DATA_PRIVACY_SELF_ASSESSMENT_V1', false),
	('b2e48e71-45b0-453f-a0e5-b256fcbafd10', 'f050e6d6-32ac-4749-b217-7b079e739ea4', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'Gather Requirements', 'The digital solution must have a defined set of requirements that describe the functional (i.e., business-process related) and non-functional (e.g., Audit Trail, Electronic Record, Electronic Signature, Data Privacy, Cybersecurity) needs to satisfy the business. All requirements must be specific, measurable, achievable, realistic and testable (SMART).', 'DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009', 'The requirements the digital solution must meet, including the list of requirements supporting the business process, as well as the applicable non functional requirements.
E.g.: Epic and user stories in Jira, Requirements in HP ALM, Requirement document in Connect CMS...', 'When attesting this control, consider the following:

* Are both functional (business-process related) and non-functional requirements (e.g. Audit Trail, Electronic Record, Electronic Signature, Data Privacy, Cybersecurity) documented for the digital solution?
* Is each requirement specific, measurable, achievable, realistic, and testable (SMART)?
* Are requirements captured and traceable in the appropriate tool for the solution (e.g. Epics/user stories in JIRA, requirements in HP ALM, requirement document in Connect CMS)?
* Is there evidence requirements were reviewed/approved by the appropriate business and IT stakeholders before design/build began?
* Are requirements complete relative to the business process being supported, with no material gaps identified later in the lifecycle?
* Any digital solution where requirements are missing, non-SMART, or not traceable to a recognized system of record should be treated as noncompliant', 'ALWAYS', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'PRODUCT_PROJECT_DELIVERY', NULL, true),
	('d547532e-7a61-4062-8140-f2c4d5cc52ff', '9f7ef809-87e9-4f33-8aca-0753a3357f7e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'Ensure Traceability', 'The digital solution must have traceability by linking requirements to its specifications and testing artifacts.', 'DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009', 'Matrix demonstrating traceability between the requirements, specifications and tests.', 'When attesting this control, consider the following: 

* Is a traceability matrix in place linking each requirement to its corresponding specification(s)?
* Does the matrix also link each requirement/specification to its corresponding test artifact (test case/script)?
* Is coverage complete - i.e can every requirement be traced through to a specification and a test, with no orphaned requirements or untested specifications?
* Is the traceability matrix kept current as requirements, specifications, or test artifacts change throughout the lifecycle?
* Can the matrix be used to demonstrate full lifecycle coverage during an audit or inspection (particularly for GxP solutions)?
* Any digital solution where requirements cannot be traced end-to-end to specifications and tests should be treated as non-compliant.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'PRODUCT_PROJECT_DELIVERY', NULL, true),
	('90f490ed-4ac7-40a1-b47b-44f47f4c7653', '50612162-2854-4558-8a23-f6241f7a2c48', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_DELIVERY', 'DEPLOY', 'APPROVAL_REQUIRED', 'Authorize for Use', 'A summary of controls execution (as per the defined control strategy) must be documented to authorize the usage of the digital solution. Deviations from the controls strategy must be justified. For unresolved deviations, actions plans must be recorded to monitor their resolutions until closure.', 'DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009', 'Summary of the Control/Validation Strategy execution, including at least:
 - all the applicable controls and their achivement''s details
 - deviations from the strategy with associated justification and action plan to remediate them
- the readiness status of the operational & maintenance processes
- decision to authorize the usage of the digital solution
E.g.: Authorization for use, Release report', 'When attesting this control, consider the following:

- Has a summary of controls executed been documented?
- Are all controls defined in the control strategy implemented? If not, are deviations justified?
- For any unresolved deviations, is there an action plan defined with an assigned owner and due date?
- Based on their impact, are there any unresolved deviation that would block the authorization for use?
- Have operational readiness activities been properly executed to ensure the digital solution is ready for operation?
- Has a comprehensive review of control execution, deviations, and operational readiness been conducted to make an informed decision on authorizing the usage of the digital solution?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'PRODUCT_PROJECT_DELIVERY', NULL, true),
	('3c05a484-0beb-4d6d-9d8e-4eda0cfdddeb', 'c57c3e99-c9a0-4890-ade1-4e3d06463548', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'Execute Digital Properties Process', 'The digital solution identified as digital property must adhere to the Digital Properties process.', 'DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/860315', 'Reference of the digital solution recorded in Digital Property Registry.', 'Reference of the digital solution recorded in Digital Property Registry.', 'ALWAYS', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', '{"outcomeKey": "PROPERTY_TYPE", "acceptedValues": ["WEBSITE", "SOCIAL", "MOBILE_APP", "CHATBOT"]}', NULL, NULL, NULL, false),
	('223b640e-39cd-49af-bbff-5afc4fd6b95c', '81f8fd1e-d226-462e-afa8-9ef1a2c5d07b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Risk Assessment', 'The AI solution risk assessment shall be documented and approved before deployment.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Completed AI Risk Assessment, approval record', 'Has an AI risk assessment been completed before deployment? Has the solution been classified according to the applicable AI risk categories? Have significant risks, limitations, and mitigation measures been documented? Has the AI risk assessment been reviewed and approved by the appropriate stakeholders?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('ebb02637-8715-442e-b3d5-08f21b42b85f', '5f9afb33-fa7f-4193-9eec-76bb84f92a1c', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Documentation', 'The AI solution shall have documented intended purpose, architecture, limitations, risks and usage instructions.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'AI Solution Documentation, Architecture Diagram', 'Is the intended purpose of the AI solution documented? Are the architecture, AI models, data sources, knowledge sources, and integrations documented? Are the known limitations, assumptions, and risks documented? Are user instructions and operating procedures available? Is documentation maintained throughout the solution lifecycle?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('b9ebc098-36b3-489d-b7b3-5bee27315cfb', 'd2b2151a-ca2b-4cc6-80c7-a8d69aabadc3', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Human Oversight Design', 'Human oversight mechanisms shall be documented and implemented when required by the AI risk classification.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Design Documentation, User Procedures', 'Are human oversight mechanisms defined and documented? Can users intervene, challenge, approve, or override AI outputs when required? Are roles and responsibilities for oversight clearly defined? Is evidence of human approval or review retained where applicable?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('3cb7862b-29eb-4a10-b49b-18fcfb431b4c', '55c1a526-c20f-4bcc-88f1-ccf5f804f5c0', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_QUALITY', 'RUN', 'APPROVAL_REQUIRED', 'Records Retention', 'Records generated throughout the digital solution lifecycle (e.g Specifications, Access Request records etc) must be maintained and retained as per the Opella Record Retention Schedule that defines the retention period.', 'DFC-QU-GOP-0000296-Project & System Lifecycle: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/484176', '*Inventory/list of records generated throughout the digital solution lifecycle (e.g Specifications, Access Request records, test evidence, CRs, etc)
*Record retention log or archive index mapping each record type to its defined retention period per the Opella Record Retention Schedule
*Evidence records are stored in a manner that ensures they remain accessible and legible for their full retention period
* Disposal/destruction record for any documents reaching end of retention, showing this was executed per the schedule (not ad hoc)', 'When attesting this control, consider the following:

* Have all record types generated throughout the digital solution lifecycle been identified and mapped to the Opella Record Retention Schedule?
* Are records actually being retained for the period defined in the schedule (not shorter and not definitely without justification)?
* Are records stored in a format/location that keeps them accessible and legible throughout the retention period?
* Where retention periods have lapsed, was disposal handled per the defined process (not informal deletion)?
* Any record type missing a defined retention period, or retained/disposed of outside the schedule, should be treated as non-compliant.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'QUALITY', NULL, true),
	('cffb536f-9ca8-4295-b899-b1a3fe46c67f', '923877ba-497e-45e7-9378-14841db4eeb5', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_QUALITY', 'RUN', 'APPROVAL_REQUIRED', 'Deviation', 'Detected or potential GxP-related compliance failures impacting a digital solution must be reported as a Quality Event. Each event must be assessed with respect to GxP/Regulatory compliance, Product impact, and Safety, Patients, Data reliability. The associated action plans supporting resolution must be tracked as Corrective Actions and/or Preventive Actions (CAPAs).
 
Note: For Quality Events reported as non-significant deviations, a Corrective Action and/or Preventive Action is not required.', '1. GQCMS-QU-GOP-0000518-Management of Deviations in QualiPSO: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/741670
2. GQCMS-QU-GOP-0000286-Escalation of Quality Events and Management of Quality Alerts: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/470603
3. GQCMS-QU-GOP-0000595-Corrective Action, Preventive Action and Effectiveness Check Management: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/856185', '* Quality Event record documenting the detected or potential GxP-related compliance failure
* Assessment documentation covering GxP/Regulatory compliance impact, Product impact, and Safety/Patients/Data reliability impact
* For significant deviations: CAPA record(s) tracking the associated action plan through to resolution
*For on-significant deviations: documented rationale confirming CAPA was correctly determined not required
* Escalation record, where the Quality Event required escalation per the Management of Quality Alerts process', 'When attesting this control, consider the following:

* Was the GxP-related compliance failure reported as a Quality Event in a timely manner?
* Was the event assessed against all required dimensions - GxP/Regulatory compliance, Product impact, and Safety/Patients/Data reliability?
* For deviations assessed as significant: was a CAPA created and tracked to resolution?
* For deviations assessed as non-significant: is the "CAPA not required" determination documented and justified, not just assumed?
* Was escalation triggered where the eent met escalation criteria?
* Any GxP-related compliance failure not reported as a Quality Event, or missing a documented significance assessment, should be treated as non-compliant.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'QUALITY', NULL, true),
	('50382738-488b-478b-8043-077129bb37f5', '5113db89-d701-4833-ba41-0861b6d78b8d', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_QUALITY', 'RUN', 'APPROVAL_REQUIRED', 'Corrective Action Preventive Action', 'The remediation of detected or potential failures of a digital  solution to comply with applicable regulatory (e.g. GxP, SOX, CSRD) or Opella requirements  must be tracked and monitored until completion to ensure timely and committed resolution.', 'QUA-CO-SOP-0010049-Management of CAPA and Effectiveness:', '* CAPA record(s) tracking remediation of detected/potential failures against applicable regulatory requirements (GxP, SOX, CSRD) or Opella requirements
* Action plan with defined owner, due date, and remediation steps
* Status tracking evidence showing CAPA progress until completion (not just opened and left open)
* Effectiveness check record confirming the corrective/prevventive action actually resolved the underlying issue
* Escalation or overdue - CAPA report, where applicable, showing timely resolution was monitored', 'When attesting this control, consider the following:

* Is every CAPA arising from a detected or potential failure tracked with an assigned owner and due date?
* Is CAPA status monitored and updated until formal completion/closure?
* Was an effectiveness check performed to confirm the corrective/preventive action resolved the root cause (not just closed administratively)?
* Are overdue CAPAs identified and escalated per the defined process?
* Any CAPA left open past its due date without escalation, or closed without an effectiveness check, should be treated as non-compliant.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'QUALITY', NULL, true),
	('39ec7361-5ee2-4cdb-9f49-19fb76c9c236', '690a3006-2358-42da-8075-912a062b66b1', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'China Digital Compliance Requirement', 'If the digital solution is used in China:
It must comply with laws and regulations under China''s cyber security and data security regime.

For digital solutions hosted outside Mainland China: If No personal information or only Technical Personal data is collected from Mainland China, this control is not applicable. Otherwise a China Cross-Border Data Transfer – Personal Information (CBDT-PI) risk review must be included.

For digital solutions hosted in Mainland China: this control must be addressed.', 'QU-GOP-0001332 China Digital Compliance Framework: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/8565258', 'Requestor to contact GRC team - CyberGRC@Opella.com for further instructions', 'Requestor to contact GRC team - CyberGRC@Opella.com for further instructions', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["USED_IN_CHINA"], "operator": "IN", "outcomeKey": "TERRITORIAL_COMPLIANCE_EXTENSION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('65aac8bc-0d74-4cad-8c3d-8158a78b39f7', '2f809e49-063f-4de8-aeb2-6238dfd023ef', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_RISK', 'BUILD', 'APPROVAL_REQUIRED', 'Assess Functional Risk', 'The digital solution''s functions or components must be assessed for potential risks to business, patient safety, product quality, data integrity, and regulatory compliance in the event of a failure. The assessment determines the depth of expected tests or verifications to ensure these risks are controlled.', '1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009', 'The risk assessment of the digital solution''s functionalities or components, describing the impact in case of failure and level of testing or verification required.
E.g.: Risk issue in JIRA, Risk record in HP ALM, Functional Risk Assessment in Connect CMS...).', 'When attesting this control, consider the following: 

* Has a risk assessment been performed for the digital solution''s functionalities or components, describing the impact in case of failure?
* Does the assessment determine the appropriate level of testing or verification required based on the identified risk?
* Is the risk assessment recorded in the appropriate tool for the solution (eg. Risk issue in Jira, Risk record in HP ALM, Functional Risk Assessment in Connect CMS)?
* Does the assessment cover all functionalities/components in scope, with no material gaps?
* Is there evidence the resulting testing/verification level was actually applied downstream (eg. traceable to the test strategy)?
* Any functionality or component without a documented functional risk assessment, or where the assigned testing rigor doesn''t match the assessed risk, should be treated as non-compliant.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('d12bc0a6-bfc9-459e-8b8a-08d72426f39b', '5cfb7e3c-6f86-4f12-8faa-cf3a20b3ef1f', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Threat Modeling', 'Threats must be identified so that risky scenarios can be understood and mitigated.', 'QU-STD-0000469 Secure Development of Applications: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/910529', 'Cybersecurity Threat assessment describing the cyber security risks which can impact the digital solution and the mitigition plan.', 'Create a Security Architecture Review Intake using the form : https://opella-health.atlassian.net/wiki/spaces/CYBSECKB10/pages/557974353/Security+Architecture+Review+Intake', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["OPELLA_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('1f9916e9-fa0d-470b-b07c-f07971ccae93', 'd6a4f79e-9f17-4da1-9765-3ba5291ddb97', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Cyber Security Code Scan', 'Vulnerabilities at code level of the digital solution must be identified and remediated. Additionally, if open source dependencies within the code are used then they must be reviewed to ensure proper use.', 'QU-STD-0000469 Secure Development of Applications:  https://api-eu.sanofi.com:8443/smartlink/api/qualipso/910529', 'Result of the code scan with list of vulnerabilities detected and indicating that no critical/high vulnerabilities remains open.', 'When attesting this control, consider the following:

 - Is the code of the digital solution stored into Opella GitHub repository?
 - Has a Cybersecurity code scan been requested and completed, before the release into production, to detect potential vulnerabilities?
 - Is a proof available, including at least: the list of vulnerabilities detected, the scan identifier, the date of the scan, the branch that was scanned, the result of the scan (SCA, SAST...) and name of the person who realized the screenshot and the timestamp?
 - If Critical/High vulnerabilities have been identified, have they been remediated before deployment in Production?

If open-source code is used:
 - Have we ensured compliance usage with the license terms (e.g. use for commercial purposes allowed, number of workstations allowed)?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, 'CYBERSECURITY', NULL, true),
	('f99e6ad0-a689-4eed-8b98-169bdc03422a', '1a86ec24-95f5-4310-9369-f5b93d33a91b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Cloud Security Posture', 'Vulnerabilities of cloud environment of the digital solution must be identified and remediated.', 'DIG-CO-STD-0000031-Systems Security Standard:https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019', 'PRISMA/ SonarCube cloud service monitoring report indicating that no medium or high vulnerabilities are open.', 'PRISMA/ SonarCube cloud service monitoring report indicating that no medium or high vulnerabilities are open.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'INFRASTRUCTURE', NULL, true),
	('6eb933a4-9c3d-490b-b2ad-37a4f666bc6f', '865139a5-726a-4402-a3ac-eceaf051bf86', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Vulnerability Lifecycle Program', 'Infrastructure vulnerability exposure of the digital solution must be monitored all along its lifecycle to ensure it is exempt from known vulnerabilities.', 'DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019', 'If a vulnerability is identified through a Qualys scan, the corresponding report will be shared with the application owner, who is responsible for taking the necessary remediation actions within the required timelines.', 'If a vulnerability is identified through a Qualys scan, the corresponding report will be shared with the application owner, who is responsible for taking the necessary remediation actions within the required timelines.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, 'CYBERSECURITY', NULL, true),
	('7c576686-92cb-4792-a5ae-4df00dff5433', '5963099b-6be9-4ec1-96db-a7471d87c5d7', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Cyber Pentest', 'Attacks must be simulated to identify overall vulnerabilities before releasing the digital solution to production .', 'DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019', 'Cyber pentest report summarizing the simulation of the attacks on the digital solution executed and critial risks remediated.', 'Cyber pentest report summarizing the simulation of the attacks on the digital solution executed and critial risks remediated.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, 'CYBERSECURITY', NULL, true),
	('cf1377dd-3854-41bb-a511-00ce412ea116', 'c86b0c27-30fb-405f-acbd-a392d8c8a43b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_TECHNOLOGY', 'MANAGE_SECURITY', 'BUILD', 'APPROVAL_REQUIRED', 'Cloud infrastructure code scan', 'Vulnerabilities of cloud infrastructure code of the digital solution must be identified and remediated.', 'DIG-CO-STD-0000031-Systems Security Standard: https://opella-connect.veevavault.com/ui/#permalink=V190000000IV019', 'PRISMA/ SonarCube code scan report from Github repository indicating that no medium or high vulnerabilities are open.', 'PRISMA/ SonarCube code scan report from Github repository indicating that no medium or high vulnerabilities are open.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'INFRASTRUCTURE', NULL, true),
	('976322e7-b549-4e40-bfdc-a295ff69ae78', 'f59a8266-784b-48e9-a903-d228e39fc23e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SUPPLIER', 'BUILD', 'APPROVAL_REQUIRED', 'Identify Third Party Risk', 'Third Party Risk must be identified during any sourcing activity in order to determine applicable due diligence and contracting actions to be executed prior to final qualification for the Cyber, Data Privacy, and Quality risk domains. A Non-Disclosure Agreement must be signed by both Opella and the 3rd Party to create a confidential relationship if applicable to conduct due diligence activities.', '1. DIG-CO-SOP-0018146-System Life Cycle: https://opella-connect.veevavault.com/ui/#permalink=V190000000IO009
2. For Quality: DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974
3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025
4. Procurement Governance: GF-QU-STD-0000419-Procurement Global Operating Standard: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/819585', 'Third Parties risk assessment (e.g Third Party Risk Identification Form completed).', 'All vendors with access to Opella''s network or are critical vendors need to go through the VIRP.During vendor onboarding  incase the vendor does not meet the Opella''s requirements, Risk Acceptance Letter to be signed by the Business', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('c32a1baa-64cb-43f3-87e7-917b0795123c', '86b82cdf-84dd-4ee6-bc8f-6ee5698cd4fd', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SUPPLIER', 'BUILD', 'APPROVAL_REQUIRED', 'Contract', 'According to a risk based approach based on the third party risk identification process,  the Digital Opella contract Owner (the person requesting and managing the contract process) must ensure that Quality contractual Clauses, Cyber Security measures, and Data Privacy Agreements relevant to the scope of services* are included in a contract with the third party.   

*Note : a Contract, including Master Service Agreement can cover services related to one or several digital solutions.', '1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974 
2. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025', 'Reference of established contract, agreement or Purchase order including proper clauses for each 3rd party used.', 'When attesting this control, consider the following:

For each Third Party providing or supporting the digital solution (SaaS system, On-Premise Software, Middleware, Infrastructure or Platform provider, Managed Services, Outsourced services):

- For Third Party identified as a “High Risk third party”* the control is to be attested in alignement with compliance status found into the High-Risk Third-Party dashboard.
 
Otherwise:
 
For Third Party supporting a GxP  feature / process: 
- Are quality contractual clauses signed by authorized Opella and third party signatories, included into the contract and stored in a contract management system? If not, has a quality contractual clause exemption form been approved by the Contract owner?  

- If the contract is up for renewal by end of the current year, and the contractual clauses have been signed for more than 5 years, is a gap assessment documented and an action plan defined for remediations?
 
For Third-Party that either accesses, stores or manages Opella information, has access to Opella systems, or has privileged access, or supports a vital process: Are the Cyber contractual measures included into the contract?
 
For Third-Party processing personal data: Is the Data Privacy Agreement included into the contract?
 
* A High Risk Third Party is a provider supporting either a Vital activity or handling high risk data (highly sensitive data, sensitive personal data or GxP  / SOX relevant data).', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('5b4e556c-025b-4e34-823d-3a8d5256d436', 'd2596b40-4456-4c7e-ad89-e990b34d9b1b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SUPPLIER', 'BUILD', 'APPROVAL_REQUIRED', '3rd Party Assessments', 'According to a risk based approach based on the third party risk identification process, an assessment of the 3rd Party is performed in order to evaluate quality, cyber and data privacy compliance. The results of this assessment are documented; it confirms the 3rd party meets Opella requirements to begin providing the solution or service.   

For SOX digital solutions and associated infrastructure components under the scope of the SOX annual campaign: A yearly independent assessment must be provided for any service outsourced to a Third Party so that compliance assurance is obtained.', '1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974
2. DFC-QU-GOP-0000204-Computerized Systems Third-Party Assessments: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/351770 
3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025', 'Third party Assessments performed including: third party audit/assessment report, Cyber Security certificates evaluation or completed VIRP, Data Privacy assessment.', 'When attesting this control, consider the following:

For each Third Party providing or supporting the digital solution (SaaS system, On-Premise Software, Middleware, Infrastructure or Platform provider, Managed Services, Outsourced services):
 
For Third Party identified as a “High Risk third party”*, the control is to be attested in alignement with compliance status found into the High-Risk Third-Party dashboard.
 
Otherwise, 
 
- For Quality Assessment:
Based on the Third Party Risk Identification form result for the Third Party, if a Quality Assessment or Quality audit was required, has it been executed and recorded into CONNECT?

- For VIRP (Cyber-Security) Assessment:
If the Third-Party either accesses, stores or manage Opella information, has access to Opella systems, or has privileged access, or supports a vital process: Has a VIRP assessment been completed and registered in the CyberVadis tool?
 
- For Data Privacy Assessment :
If the Third Party processes personal data: Has a Data Privacy assessment been performed in OneTrust?
 
* A High Risk Third Party is a provider supporting either supporting a Vital activity or handling high risk data (highly sensitive data, sensitive personal data or GxP  / SOX relevant data).', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'CYBERSECURITY', NULL, true),
	('86f10f52-6243-49ec-b366-5050540e893f', '5c9909da-bdba-47eb-88ba-af66890170f7', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_SUPPLIER', 'RUN', 'APPROVAL_REQUIRED', '3rd Party Monitoring and Termination', 'Relevant 3rd Party failures potentially impacting the data integrity, security, or privacy aspects associated to the digital solution as well as 3rd Party termination must be reported, assessed and addressed in order to minimize impact and restore controls.', '1. DFC-QU-GOP-0000498-CS Third Party Quality Management - Sourcing, Contracting, Management and Termination: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/724974
2. DFC-QU-GOP-0000204-Computerized Systems Third-Party Assessments: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/351770
3. For Cyber: DIG-CO-STD-0000020-Third Parties - Contractors Cybersecurity requirements: https://opella-connect.veevavault.com/ui/#permalink=V190000000IY025', '* Record of 3rd party failure/incident reported, with impact assessment covering data integrity, security, and privacy aspects
* Assessment documentation evaluating the failure''s impact on the digital solution and associated controls. 
* Remediation/corrective action record showing how impact was minimized and controls restored
* For 3rd party termination: documented termination record, including transition/exit plan and confirmation that data handling obligations were met
* For High Risk Third Parties specifically (supporting Vital activities or handling highly sensitive/GxP/SoX-relevvant data): evidence of enhanced monitoring commensurate with that risk classification
* Reference to the 3rd party''s classification/risk tier, to confirm the correct level of monitoring rigor was applied', 'When attesting this control, consider the following:

* Has the 3rd party''s risk classification (including High Risk status, if applicable) been correctly identified per the defined criteria?
* Were any 3rd party failures impacting data integrity, security, or privacy reported and assessed in a timely manner?
* Were corrective actions taken to minimize impact and restore affected controls?
* For terminated 3rd parties: was termination executed per the defined process, with data/access appropriately closed out?
* For High Risk Third Parties: is there evidence of monitoring proportionate to that elevated risk (e.g. more frequent reviews, deeper assessments)?

All employees are required to promptly report any vendor-related incidents of which they become aware.to cyber@opella.com.', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["THIRD_PARTY_ENGAGED"], "operator": "IN", "outcomeKey": "THIRD_PARTY_ENGAGEMENT"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'CYBERSECURITY', NULL, true),
	('dc64c63f-202d-4b34-8f4b-7b4a0d082874', '58de171c-5cb9-4b32-9d78-060b76aaa29f', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Transparency Assessment', 'AI transparency obligations shall be identified and implemented before deployment.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Transparency Assessment, User Notification Evidence', 'Are users informed when interacting with AI-generated content where required? Are AI-generated outputs clearly distinguishable from human-generated content? Are transparency requirements consistently applied across user interfaces?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('107c7e22-4ec3-4211-809c-17d94250f53e', '538c492c-245b-490a-86cd-39ce496831b4', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'PV', 'MANAGE_DELIVERY', 'RUN', 'APPROVAL_REQUIRED', 'PV Monitoring for Digital Properties - PV Clause availability in Contract', 'ONLY applicable if there is 2 way communication on the platform:
If monitoring is performed by an outsourced service provider, a PV clause must be included in the contract wherever a service provider is involved in monitoring. 

Note: If this is performed by Opella employee, this control is not required.', 'DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties', 'Before GO LIVE: Signed contract containing PV clause, for any digital property involving a service provider', 'When attesting this control, consider the following:

1. Does the digital property has two-way communication where PV information may be mentioned?
2. Who is responsible to perform the monitoring (Service provider or Opella employee)?
3. If a service provider performs the monitoring, is a PV clause present in the contract?
4. If Opella employee, no action is required for this control', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}, {"values": ["SERVICE_PROVIDER"], "operator": "IN", "outcomeKey": "PV_MONITOR"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'PV', NULL, true),
	('c6ebdc07-a5ff-4e7a-a3bb-d2b615d84c0e', 'f6e69665-74c5-47f3-8fe0-8387631fd439', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Model and Prompt Governance', 'AI models, prompts, grounding data and configurations shall be controlled and versioned.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Version History, Configuration Repository', 'Are AI models, prompts, configurations, and knowledge sources version controlled? Are changes documented and approved?  Is a history of modifications maintained? Can previously deployed versions be identified and retrieved?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('3f705ac6-4096-41fe-9b7b-086453daa816', '1a2d005c-4d48-4d90-b479-673720b2b191', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'APPROVAL_REQUIRED', 'AI Explainability Assessment', 'High-risk AI solutions shall include appropriate explainability information for intended users.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Explainability Documentation', 'Is information available to explain how AI outputs are generated? Are explanations appropriate for the intended audience? Are limitations and uncertainties communicated where appropriate? Has explainability information been documented and reviewed?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, 'AI', NULL, true),
	('d8738b3d-ee0d-49cd-8f4a-60c68273628e', 'e39c24d2-dc35-4be0-827d-e305640a236b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MONITOR_PERFORMANCE_INDICATORS', 'RUN', 'APPROVAL_REQUIRED', 'AI Performance Monitoring', 'AI solutions shall be monitored in production to identify degradation, quality issues or unexpected behaviour.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Monitoring Dashboard, Monitoring Report', 'Is monitoring in place for AI quality, reliability, and performance? Have monitoring metrics and thresholds been defined? Are alerts generated when performance degrades?  Are monitoring results periodically reviewed? Are corrective actions defined and tracked when issues are detected?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'AI', NULL, true),
	('38b0bbbf-6999-4b45-a385-1ba08a9358fd', '828802e9-318d-4d12-a854-9786209e4e63', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MONITOR_PERFORMANCE_INDICATORS', 'RUN', 'APPROVAL_REQUIRED', 'AI Incident Monitoring', 'AI-related incidents shall be recorded, assessed and remediated.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Incident Records', 'Are AI-related incidents recorded and investigated? Are root causes identified and documented?  Are corrective and preventive actions implemented? Are significant incidents escalated appropriately? Are lessons learned incorporated into the AI solution lifecycle?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'AI', NULL, true),
	('abe83830-123b-4341-8cce-1939f6df8b41', 'a0405e56-a891-44df-828e-55daf4675d09', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MONITOR_PERFORMANCE_INDICATORS', 'RUN', 'APPROVAL_REQUIRED', 'AI Continuous Improvement', 'AI solutions shall be periodically reviewed for continued fitness for intended use.', 'https://sanofi.sharepoint.com/sites/ORAIGovernance/SitePages/OR.AI-Opella%20Responsible%20AI.aspx', 'Periodic Review Report, Improvement Actions', 'Is the AI solution periodically reviewed for continued fitness for intended use? Are changes in business requirements, data, or operating context assessed? Are improvement opportunities documented and tracked? Are monitoring results used to drive improvements? Is periodic review evidence retained?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'AI', NULL, true),
	('e26edae2-a1ac-4947-8fab-fc8219f9f812', '9ce48c02-47c1-4232-91ce-0f9d6469c7f4', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'PV', 'MANAGE_DELIVERY', 'RUN', 'APPROVAL_REQUIRED', 'PV Training', 'ONLY applicable if there is 2 way communication on the platform:

1. PV training must be completed by personnel involved in monitoring  (service provider and/or Opella employee).', 'DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties
(Opella SOP is currently in a draft stage)', 'Before GO LIVE: PV training documentation (certification/attendance record) for individuals involved in monitoring.

After GO LIVE: PV Training documentation [On a yearly basis refresher training required for individuals involved in monitoring ]', 'Have all individuals involved in monitoring completed PV training, with evidence available?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 12, 'PV', NULL, true),
	('8614ac0b-23ef-4e43-8fbe-bafdf961bfff', '010a40d2-eae8-4d61-b2bf-d0e4d8589d64', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'PV', 'MANAGE_DELIVERY', 'RUN', 'APPROVAL_REQUIRED', 'PV Reconciliation', 'ONLY applicable if there is 2 way communication on the platform:

Monthly reconciliation (For any periodicity besides monthly reconciliation, a documentation is required) .', 'DFC-QU-GOP-0000613-Life Cycle Management of Digital Properties
(Opella SOP is currently in a draft stage)', 'After GO LIVE: Completed periodic reconciliation documents (monthly, or as otherwise agreed)', 'Where reconciliation applies, what are the evidence available to document that the reconciliation has been completed?', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["PV"], "operator": "IN", "outcomeKey": "PV"}]}]}', current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, 1, 'PV', NULL, true);


--
-- Data for Name: nfr_definition; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.nfr_definition (id, code, active, created_by_user_id, created_at, updated_at) VALUES
	('2a55602f-e7d1-4f17-b0d8-57042c94bf51', 'NFR-01', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('eaa3bcbe-272f-4b6d-95f6-bcafeb44cdeb', 'NFR-02', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('b2064414-2123-41af-b2ab-74a72d6e6a52', 'NFR-03', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f2653553-9139-405f-a510-b12fe195f81b', 'NFR-08', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('ba890274-6fcf-45f3-86c0-05ba7ce73e32', 'NFR-09', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('5d2f8856-050b-41f5-b2d2-fb59f65f36cf', 'NFR-10', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('9881e8a9-f4d6-4627-8ea2-7833bbad8fcd', 'NFR-11', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('9e1df205-e8f9-42d0-a1cb-93a629c0707e', 'NFR-12', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('58e7a13d-95b6-4aff-a93f-b08613bd2b9b', 'NFR-13', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('77b32464-9320-41ee-9f2d-0af178016832', 'NFR-14', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('163cef95-d70b-428a-ae84-72a1ed207fae', 'NFR-15', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('ac722f69-5bb2-4277-aaeb-997ac9985d2e', 'NFR-16', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('a607d58e-cfdb-46ef-afd7-4a56065562c1', 'NFR-17', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('c54e3b54-49a0-4a35-a2de-f35c0fd7964b', 'NFR-18', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('330c182c-0a23-4e49-bafd-5d62ae48a855', 'NFR-19', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('905f35ec-62c9-4f1f-829c-66d1eb65d247', 'NFR-20', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('27182909-b008-42bf-a0a9-1776468e884e', 'NFR-21', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('b4c20e62-dac0-4bd4-b88c-fcedc7b4bfa6', 'NFR-22', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('4524e59f-e7cd-4758-abc7-f75a02e1924c', 'NFR-23', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('74fc523e-4533-41d5-94f8-d9babe917259', 'NFR-24', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f1d57645-9bea-45ef-a0d9-ed351bc4f1cf', 'NFR-25', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('850e6c37-b708-4e73-8be1-fe9aaa017bfb', 'NFR-26', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('17351137-5380-43fa-afb3-180ca682a127', 'NFR-29', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('376392d0-a9e5-4b77-992b-ae65f3db31a8', 'NFR-30', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('1bc7191f-81e1-45d6-8634-733f31e9bd08', 'NFR-31', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('33740363-b4b9-4cf6-b1a5-f70c9a9d8aec', 'NFR-32', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('2042e88c-f3c3-4f62-a52d-0450f9b0742d', 'NFR-33', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('2dc45294-6d91-4898-8f42-804b7effd193', 'NFR-34', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('b11d737b-5521-48c9-9281-4c6c18d73a46', 'NFR-35', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('e8c654fb-1faa-4892-919d-e054adc32133', 'NFR-36', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('d7ef72f3-7a62-4fc5-aa23-0c172f9d3526', 'NFR-38', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('b66bb021-7486-40cb-8f7d-d9a91fcd8d04', 'NFR-39', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('6c43b8a0-5150-4dcb-b4fc-64cd0fe6eb4b', 'NFR-40', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('0a01bf0f-7284-4ac8-948c-6ea171b5cad3', 'NFR-41', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('ca7891f6-995f-4351-86ae-616665f408f1', 'NFR-42', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('32e29ebb-0794-4c92-8aaf-1230c056de1d', 'NFR-44', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('2796144d-7837-4d31-ab5c-b31909ba9b5f', 'NFR-52', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('580ddb3a-e97e-4a8b-9d1b-53759d0b35ef', 'NFR-53', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('4836d9d8-6be8-404b-a711-ce5a8a8d4f6a', 'NFR-54', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('1094a551-513d-4e12-b901-f6ff7741c37b', 'NFR-55', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('e46f2065-7899-4d6c-9ea8-2c6cb89911f3', 'NFR-56', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('f63c030d-ece5-47e8-9ad6-e3368c7fdee8', 'NFR-57', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('4c25426d-d58e-47a8-ba4d-9cb7ad9d90e6', 'NFR-58', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('95c51290-a68f-4a03-8375-c4f6a78d7722', 'NFR-59', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('ed37a4de-4573-4412-9ed0-bd9b34a10261', 'NFR-60', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('8b060bbd-13b8-40f4-a8df-0ea83b8e2a00', 'NFR-61', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('de2316c3-de8d-43d1-a1dd-eb583616197e', 'NFR-62', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('8826814f-02f8-4050-b451-883d4747590d', 'NFR-63', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('93b1d6e0-a1f3-4c5b-bf1a-06fd404da816', 'NFR-64', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('7612dbd5-de5c-466b-a2c6-11d74e9bad0b', 'NFR-65', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('601bb291-306b-475d-a42e-87df03a8fa38', 'NFR-66', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079'),
	('c90b93f6-d933-4648-a7bc-9c5d6d3e61bf', 'NFR-67', true, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079');


--
-- Data for Name: nfr_definition_version; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.nfr_definition_version (id, definition_id, version_number, catalog_version_key, version_reason, owner_team, it_process, slc_phase, attestation_type, statement, objective, source_of_truth, targeted_evidence, attestation_guidance, applicability_type, trigger_rule, auto_attestation_rule, revalidation_interval_months, created_by_user_id, created_at, updated_at, reviewer_team, assessment_template_key, evidence_required) VALUES
	('aca6b047-0bd2-4e17-b71b-9a8006421ee5', '2a55602f-e7d1-4f17-b0d8-57042c94bf51', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that the digital solution creates and retains a secure, computer-generated, time-stamped audit trail of creation, modification, or deletion of data impacting regulated Electronic Records, so that the solution can comply with regulations and maintain data integrity.

Specific: user/administrator access accounts are one type of record to be audit trailed.', '1. Each audit trail entry should specify the type of action (e.g. Create, Modify, Delete) performed on the electronic record.
2. Each audit trail entry should include the user (inc administrator) name who performed the action.
3. Each audit trail entry should include the exact date and time (hours, minutes, seconds) of user entries and actions, with time zone information if applicable.
4. In case of modification or deletion, the audit trail should record the old data or value and also the new data or value.
5. If required by regulations, each audit trail entry should include the reason for the change.
6. The digital solution should be able to present the audit trail in a human-readable form 
7. The digital solution should provide functionalities to view, search, and analyze the audit trail.
8. The audit trail must always be on, i.e. users must not be able to turn it off or modify it.
9. Audit trail must be securely retained for the same duration as the associated record.

Reference STD: QUA-CO-STD-0000155: Management of GxP Electronic Records & Electronic Signatures', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('b0add7eb-d31e-451f-91ec-9beaaeaad870', 'eaa3bcbe-272f-4b6d-95f6-bcafeb44cdeb', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution has built-in checks for correct and secure entry and processing of data when exchanging data with other solutions, to minimize risks and ensure data integrity.', '1. Given a set of data to be migrated/exchanged, the digital solution should validate the format and content of incoming data from other digital solutions before processing and generate alerts in case of error (e.g. volume, accuracy)
2. The digital solution should ensure secure data transmission with other digital solutions, utilizing appropriate encryption methods.

The extent of the checks to be implemented is dependent on the use case.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}, {"conditions": [{"values": ["ECOMMERCE_OR_FINANCIAL"], "operator": "IN", "outcomeKey": "PROPERTY_CATEGORY"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('0401050d-29e0-43a6-8b59-1ecf996814ee', 'b2064414-2123-41af-b2ab-74a72d6e6a52', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_QUALITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution contains error detection mechanisms for invalid field entries, out of range values, blank fields for required entry, invalid data types and sequence enforcement related to the defined Electronic Records.', '1. The digital solution should automatically check for invalid field entries upon data input.
2. The digital solution should not allow the user to proceed without filling in required entry fields.
3. The digital solution should validate the data type of entered data (e.g. date format)
4 The digital solution should implement operational check to enforce the correct sequence of steps and events when necessary (e.g. a step cannot be executed if preceding step is not complete).
5. In case of any error (incl out of range value), the digital solution should show an appropriate error message and guide the user to correct the error.
6. The digital solution should not save any data until all the errors are resolved.

The extent of the checks to be implemented is dependent on the use case.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["GXP"], "operator": "IN", "outcomeKey": "GXP_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('faccea15-2e20-4fd3-bfc9-4c67c3e3ce22', 'f2653553-9139-405f-a510-b12fe195f81b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure all passwords comply with the minimum requirements.', 'Preferred solution is Opella SSO / AzureAD / Akamai.

If it''s a PAM or Opella account, then Identity shall be used:
     --> https://identity.sanofi.com/edentity/ui/setTimeZone.jsf
1. The digital solution must have the capability to create a password for a unique user ID. 

2. Password creation must adhere to the following rules: 
•	Length of passwords: 8 characters minimum
•	Complexity: the password must have a minimum of 3 out of the following 4 elements: 
-	Numeric characters: 0,1,2,3,4,5,6,7,8,9
-	Special characters: !, “,#,$,%,&,´,(,),*,+,-,.,/,[,],\, @,^,_,{,|,},~
-	Lowercase alphabetical characters
-	Uppercase alphabetical characters
•	Password history: the password must be different from the 10 previous used passwords 
•	Maximum duration of the password: the password must be changed every 90 days
•	No minimum duration of password 
•	No easily guessable words allowed in passwords 
For additional details on passwords for PAM, SaaS refer to the document DFC-QU-STD-0000298-Access Control: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/581828. 

3. Passwords must be stored using modern and cryptographically strong hashing algorithm with a random salt per password, as specified in the document DFC-QU-STD-0000259 - Cryptography Standard.

4. Prior to release, the digital solution must be tested in the BeSafe portal  (https://safe.sanofi.com/testYourPassword) to ensure that password creation complies to Policy requirements.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('2913a08e-f255-4f9b-a90a-bc72bc0dbade', 'ba890274-6fcf-45f3-86c0-05ba7ce73e32', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure password changes are completed securely.', 'Prefer solution is Opella SSO / AzureAD / Akamai.

If it''s a PAM or Opella account, then Identity shall be used:
     --> https://identity.sanofi.com/edentity/ui/setTimeZone.jsf

Note: If you are specifically using a PAM service account, even though they have no password expiration, they are still bounded by a regular change of password to ensure there is no unauthorized access.

1. The digital solution must have the capability to change a password. 
2. The digital solution must enable this capability when a password is forgotten.
3. The existing password must be entered prior to initiating a new password change.
4. If a new password is successfully accepted per the Password Creation rules, digital solution must send an email to the owner of the user ID to inform the owner of the password change.
5. When a user forgets a password, the password is changed and not recovered, avoiding password not to be stored encrypted, as requested by the Cryptography Policy DFC-QU-STD-0000259-Cryptography Standard: https://api-eu.sanofi.com:8443/smartlink/api/qualipso/500892.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('920f7820-809e-4f00-b024-5a84fad09756', '5d2f8856-050b-41f5-b2d2-fb59f65f36cf', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution has configurable authority levels for users and administrators, so they can perform specific operations (e.g. using the digital solution, managing records, electronically signing a record, managing user accounts, etc.) according to their assigned roles and permissions.', 'Service accounts for Pharma/Pasteur domains must use PAM process in accordance with the type of privileges requested.

Other accounts must follow following rules:
1. The digital solution must have varying authority levels that can be assigned to users and administrators.
2. The digital solution users and administrators should be able to create, modify, and delete records depending on their authority level.
3. The digital solution should enable the creation, modification, and deactivation of user accounts.
4. The digital solution should prevent users and administrators from performing operations that exceed their authority level.
5. The digital solution should maintain a log of all operations performed by users and administrators, including changes to authority levels.
6. The digital solution should alert the security team/individual when an attempt is made to perform an operation that exceeds a user''s or administrator''s authority level.
7. If the system is not using SSO, any change made to an account must force the reconnection of the user to his account.
8. The system must provide the ability to create a list of users with associated access privileges that can be filtered and sorted for the current date, and for a 1 year past date.
9. Administration, maintenance and support remote access must be restricted to access only the needed components. 

For APIs: 
1) Use AzureAd or Cognito for managing permissions', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('5de7c595-4867-47ca-a01c-863ade241519', '9881e8a9-f4d6-4627-8ea2-7833bbad8fcd', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that the digital solution uniquely identifies users and prevents the allocation of inactivated user IDs to new users, to maintain data integrity and security.', 'Accounts used on application and Operative Systems shall be Opella domain accounts.
Identity is Opella''s standard solution for account management.

If Identity cannot be used, then:
1. The digital solution must require unique identification details for each user during registration.
2. The digital solution must have a mechanism in place to check for duplicate user IDs during registration.
3. The digital solution should not allow a user ID to be allocated to a new user if the user ID has been previously registered or inactivated. 
4. The digital solution must provide a clear error message when an attempt is made to register with an inactivated or in-use user ID.
5. The digital solution must retain an audit log to track user ID allocation and inactivation for administrative review.

If there are nominative accounts (no generic / shared accounts), then the system must provide the ability to identify users uniquely, and a nominative account must be used.

The use of service accounts must be strictly limited to the purpose that is required.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('4c7c9a08-dfd3-4496-a043-37a0d6f2b19c', '9e1df205-e8f9-42d0-a1cb-93a629c0707e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure all default accounts are deactivated to prevent them from being exploited to access the digital solution.', 'All default accounts for technology deployed (OS, middleware) must be disabled. 
If the default account cannot be disabled, then it must comply with DFC-QU-STD-0000298-Access Control & GQCMS-QU-STD-0000452-User Access Management Controls:
1. the default password must be updated to a stronger password. 
2. an owner must be identified.
3. the default account must be registered into the role based access definition.
4. when possible, username must be updated to differ from default name.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('2f047781-6e80-458c-acc0-50e9d3c5b5ff', '58e7a13d-95b6-4aff-a93f-b08613bd2b9b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution allows for deactivation and reactivation of user and administrator accounts without losing their activity history, so access can be appropriately managed while preserving important user data.', 'If using standard SSO, then this is automatically validated. If not (if using not the standard), then the digital solution must:

1. The digital solution must provide functions to deactivate and reactivate user and administrator accounts.
•	When an account is deactivated, the digital solution should retain all historical data and activities related to that account.
•	When an account is reactivated, the digital solution should restore access to all historical data and activities related to that account.
2. The digital solution must record the times and dates of account deactivation and reactivation in the user activity log.
3. The digital solution must prevent deactivated accounts from logging in until they have been reactivated.
4. The digital solution should not allow any data modification or deletion during the period an account is deactivated.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('43ebd2a5-27c5-4280-bcdd-20131ecdac22', '77b32464-9320-41ee-9f2d-0af178016832', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want all backend requests to the digital solution to be sent in a hidden format for security.', 'When the digital solution is using form-based authentication, a POST request must be used to avoid authentication credentials to be cached to browser history. 
•	Use POST instead of GET. 
•	Ensure a correct message (200 message) is displayed when retrieving the response from the request.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('17fe4a05-fd48-46ae-a30c-3ddfb7aaad89', '163cef95-d70b-428a-ae84-72a1ed207fae', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure authentication controls are enabled for the digital solution to prevent brute-force attacks.', '1. Mechanisms must be in place to secure login to the digital solution including: 
•	Login to the digital solution must be blocked after 5 unsuccessful login attempts; login can be blocked based on user ID or IP address (prioritized ID).
•	The digital solution should maintain the security and confidentiality of the users'' credentials during the authentication process.

2. For machine-to-machine login mechanisms, the key-pair must be prioritized over credentials with clear lifecycle management.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('4ccabc65-0483-4b81-a472-2ed8c8a090d0', 'ac722f69-5bb2-4277-aaeb-997ac9985d2e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to implement multi-factor authentication to avoid credential stuffing attacks to the digital solution.', 'Secure authentication (e.g. two-factor authentication) must be implemented for sensitive accounts to prevent successful spear-phishing attacks from evolving to access into the solution.

MFA is mandatory for all the following cases:
- Connexion to a SaaS (user and admin accounts)
- Administrative access to specific solutions (Technology Platforms, Application that manages sensitive personal data or sensitive data)


1. MFA requirements must be defined for all digital solution actions that required secure authentication; examples include: 
•	Privileged account authentication
•	Actions to be carried out on confidential data
2. MFA must be implemented according to the digital solution’s authentication requirements. 

Note: The Multi Factor Authenitcation is an additional method to the user / password that increases the level of security. This MFA is usually something that the user has (token) or is (fingerprint). 

Examples of MFA can be through Tokens, Codes, SMS, email, Mobile Apps, Fingerprint, etc.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}, {"values": ["CONFIDENTIAL", "HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('f0563477-8970-4ecb-955e-5e60928d7924', 'a607d58e-cfdb-46ef-afd7-4a56065562c1', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution authenticates users through Single Sign-On (SSO), so they can seamlessly access the digital solution without needing a different login.', 'SSO is mandatory for all Opella accounts (including internal and external) to login to SaaS applications.

1. The digital solution must be integrated with a Single Sign-On (SSO) digital solution to allow transparent user authentication using SSO methodes trusted by Opella (e.g., OAuth on Azure AD).
2. The digital solution should automatically authenticate the user’s identity through the SSO digital solution when a user accesses the digital solution, without requiring manual login.
•	If the authentication is successful, the SSO digital solution should grant the user access to the digital solution and associated applications.
•	If the authentication fails, the SSO digital solution should deny access and display an appropriate error message.
3. The digital solution should maintain the security and confidentiality of the user''s credentials during the SSO authentication process.
4. The digital solution should log all successful and unsuccessful SSO authentication attempts for audit purposes.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["OPELLA_EMPLOYEES_ONLY"], "operator": "IN", "outcomeKey": "TARGET_AUDIENCE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('5d2a977b-c08c-4861-ba64-fdd843147812', 'c54e3b54-49a0-4a35-a2de-f35c0fd7964b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that only the necessary network services (ports) are exposed to the user to reduce the likelihood of surface attacks.', 'Measures must be taken to secure the digital solution’s network services such as: 
•	Limiting network services exposure to only what the user needs to see (e.g. only port 443 for a web server).
•	Designing the internal network so that databases and application servers are placed on dedicated network areas, which standard users cannot access.
•	Limiting administrative interfaces (e.g. RDP and SSH) to a dedicated administrative network.
•	Refraining from opening all ports in both directions.
•	Restrict administration exposure on the WAN (RDP/SSH/HTTPS). For NGDC (no firewall), use SEP firewall (for Windows) or iptable (for Linux). Only BASTION IP addresses should be allowed to connect to administration interfaces/ports.
•	Ensuring only secured ports are used and required for the digital solution.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('798cd3dc-2a66-41cd-bd45-89135a3cfccb', '330c182c-0a23-4e49-bafd-5d62ae48a855', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that configuration of cipher suites remains up to date to avoid vulnerabilities.', 'For internal solutions, use the request via SSL Certificate Global Request.
 --> https://sanofiservices.service-now.com/onesupport?id=sc_cat_item&sys_id=add1aad7db597300bb471923059619e0&table=sc_cat_item&searchTerm=ssl 

For external solutions, ensure: 
The digital solution’s SSL configuration must be compliant with best practices. At a minimum:
•	The SSLv2/v3 should be disabled.
•	WEAK/INSECURE Cipher Suites should be avoided.
•	SSL certificate must have a key size of 2048 bytes and an algorithm of SHA 256 for encryption.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('c078f83f-ffaf-4088-beff-5aa976409ad9', '905f35ec-62c9-4f1f-829c-66d1eb65d247', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that my digital solution is protected against denial of service (at the network and code level) to prevent any digital solution unavailability.', 'Anti-DOS measures must be implemented on the network and application layers depending on the availability needs of the digital solution. For example:
•	At the network level, a service provider can prevent such attacks.
•	At the digital solution layer level, mitigation measures such as setting up a Captcha or a Web Application Firewall (WAF) can reduce the impact of the attack.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('68da4e50-af05-43fa-a019-04cd6efc08e2', '27182909-b008-42bf-a0a9-1776468e884e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that my digital solution is segregated across multiple network areas, to prevent attacks/incidents from spreading to the rest of the solution and/or enterprise network.', '1. The applicable network areas must be defined, and the digital solution’s servers must be mapped and placed across these network areas accordingly. 
2. The digital solution’s servers must be mapped to each network area according to their criticality and the confidentiality of the data they contain (e.g. administration server, database servers, backup servers, etc.).
3. The digital solution’s servers must be separated using VLANs, IP subnets, and firewalls, or by colors/zones if it’s a SCADA network (industrial network).  
4. The digital solution’s environments (e.g. pre-production, production, and recipe) must be separated. 

If SCADALAN network is used: SCADALANv2 is the architecture standard for Opella''s industrial information system segmentation.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('4ab0026b-6d27-441c-8ffe-70e9c1ef444f', 'b4c20e62-dac0-4bd4-b88c-fcedc7b4bfa6', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that any services exposed on the internet are partitioned from the rest of the network to prevent the spread of incidents/attacks to the internal network.', '1. Any digital solution component that is exposed on the internet must be clearly defined in APM (Application Portfolio Management) or DPR (Digital Property Registry), except for local projects.
2. Exposed components must be placed in a demilitarized zone (DMZ).
3. A reverse proxy and/or web firewall must be set up and configured between the DMZ and the internet.
4. A firewall must be set up and configured between the DMZ and the network.
5. Firewall rules must be reviewed by the Cyber security expert.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('ad6e3921-f88c-44cc-809a-3b937fdc729c', '4524e59f-e7cd-4758-abc7-f75a02e1924c', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution’s cloud architecture is secured to avoid the spread of attacks in the cloud infrastructure or digital solution’s infrastructure.', 'Measures must be taken to secure the digital solution’s cloud architecture such as: 
•	Prohibiting RDP (Remote Desktop Protocol) access or similar protocols except from approved infrastructure dedicated to remote accesses (e.g., Bastion).
•	Partitioning the infrastructures of different projects/applications by setting up subnetworks or a VPC (virtual private cloud)
•	Identifying and taking inventory of interconnection points between cloud infrastructure and the enterprise network
•	Configuring and setting up firewalls at the interconnection points identified
•	If Cloud-as-code / Infrastructure-as-Code is used, ensure there are not high or critical vulnerabilities found before deploying.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('bc96c4cd-2c89-4bf8-9c44-0313ccb6a589', '74fc523e-4533-41d5-94f8-d9babe917259', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure my digital solution’s infrastructure is secured to prevent technical vulnerabilities.', 'Measures must be taken to ensure the appropriate hardening is in place (Network, Operating System, Database); at a minimum the following must be done: 
•	The infrastructure has been passed through a security review before deploying. If it’s cloud-as-code, a secure cloud check must be done with appropriate tools (such as Prisma).
•	Infrastructure is protected with network security controls, such as firewalls, Intrusion Prevention/Detection Systems (IPS/IDS), access controls lists and network segmentation.
•	Unnecessary files, folders, services / ports, and debugging functions have been removed and disabled.
•	Web and solution components are up to date (including operating digital solution, middleware, Content Management Systems (CMS), and plugins, and other components supporting the Web application).
•	Webserver should not be prone to path traversal, not directory listing.
•	Infrastructure is using the latest version available of the product.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('6bb99028-ff65-4425-9354-6190375ebd72', 'f1d57645-9bea-45ef-a0d9-ed351bc4f1cf', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the digital solution is protected against injection methods, to prevent technical vulnerabilities.', 'Security measures must be in place to ensure the web application is protected against Reflective/Permanent XSS (Cross Site Scripting) and any possible command injections (SQL, Operating system, Active Directory, XML):
•	Validate and sanitize all user inputs (form fields, URLs, cookies) before processing them.
•	Use prepared statements for SQL calls.
•	Encapsulate database requests in stored procedures.
•	Implement secure headers (content security policy and x-protection).

If application uses a token (JWT), then this NFR is not applicable.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["LIKE_EXTERNAL"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('4af8885b-6f4d-4fd5-9bd0-9dbc8fae8bdb', '8826814f-02f8-4050-b451-883d4747590d', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall maintain version control of AI models, prompts, configurations, and knowledge sources', 'AI models, prompts, configurations, and grounding sources shall be version controlled. Changes to AI configurations shall be documented and traceable. Previous versions shall be retrievable when required. Version history shall be available for audit and troubleshooting purposes.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('09bb55db-be62-4ed9-bcdc-05796eba20aa', '850e6c37-b708-4e73-8be1-fe9aaa017bfb', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to minimize the exposure of the web application session so I can prevent security attacks on open sessions that are not in use.', '1. The session identifier must be created on the server side. 
2. A random algorithm must be used to generate session identifiers.
3. Domain and patch for cookies, containing the authenticated session, should be restricted.
4. Logout functionality should terminate all associated session connections.
5. A new session identifier must be generated for any re-authentication.
6. The session should timeout if not in use for a maximum of 15 minutes if Highly Confidential information are processed, or a maximum 1 hour if not.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["ACCESS_RESTRICTED"], "operator": "IN", "outcomeKey": "ACCESS"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('2cb9457b-4c8b-4b8d-8b11-ef371d3a8e66', '17351137-5380-43fa-afb3-180ca682a127', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to secure the use of APIs, so that they are not a source of vulnerability or attack to the digital solution.', '1. An inventory of the digital solution’s APIs must be tracked and established. 
2. The digital solution’s APIs must be secured through practices such as: 
•	Tracking API editors (only Applicable for 3rd parties)
•	Tracking and capturing detailed API operations (only Applicable for 3rd parties)
•	Conducting API reviews (only Applicable for 3rd parties)
•	Tracking the API score in SAST or DAST tool (CodeGuard)

3. Measures must be taken to minimize the processing of confidential, strategic, or personal data by the digital solution’s APIs.
4. The digital solution must use APIs that encrypt the exchanged data flows.
5. The digital solution must use APIs with an authentication and autorization system implemented.
6. The digital solution muse use APIs with a call and rate limiting.
7. When applicable, expose or consume the APIs via Opella Layer7 (architecture standard)', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('cfe4c267-7393-4fd7-b649-acd7e9da8757', '376392d0-a9e5-4b77-992b-ae65f3db31a8', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure all data transmission to and from the digital solution is encrypted.', 'Measures must be taken to secure data transmission to and from my digital solution (including migration activities) such as:
•Implementing encrypted protocols (e.g., HTTPS instead of HTTP, SFTP instead of FTP, etc.)
• Ensuring HTTP redirects to HTTPS
• Using Layer7 technology when applicable  for ETLs (Extract, Transform, and Load procedures)
• Encrypting data transmission with secure protocols (e.g., TLS with PFS) and ensuring its integrity
• Only authorizing encrypted protocols to web servers, with an SSL certificate and HSTS (HTTP Strict Transport Security) enabled
• Only using secure algorithms and ciphers for protocols
• Passwords / Credentials are not transmitted in clear text over the network', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('395c7f40-bd47-4ccf-8ef9-dfba25db9f86', '1bc7191f-81e1-45d6-8634-733f31e9bd08', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that only essential information is shared or consumed, with a focus on avoiding the exposure of any additional information beyond what is specifically requested.', '1. Measures should be taken to implement data masking techniques to conceal any irrelevant or sensitive information that is not directly related to the requested data.
2. The digital solution must only expose the bare minimum of information required for a particular user or task at the frontend.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('117b3396-168f-4a7a-bfb4-32239821175d', '33740363-b4b9-4cf6-b1a5-f70c9a9d8aec', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that all strategic and confidential data is hosted according to criticality, to ensure maximum data security.', '1. The digital solution’s strategic and/or confidential data must be stored in a data host that has successfully completed the Cybersecurity assessment (VIRP process) with a successful score (above 700) or with equivalent certification (e.g., ISO 27001).
2. Measures must be taken to anonymize and/or remove sensitive content from strategic and/or confidential data before hosting this data in a public cloud or outside of Opella standards.
3. If applicable, each data folder/container must be properly isolated to ensure segregation between different parties.
4.  Robust authentication mechanisms must be in place to authorize users’ access to data folders/containers.
6. All access modifications to data folders/containers must be tracked and logged. 
7. Encryption measures should be taken to protect the data within each data folder/container.

If it''s a local system (HMI, PLC for instance), then: 
• Data and backup data must be stored in different physical locations and must be protected with an equal security level of encryption.
• Databases must be encrypted.
• Configuration files must be encrypted', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}, {"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["FULLY_MANAGED"], "operator": "IN", "outcomeKey": "PLATFORM_TYPE"}]}]}', '{"outcomeKey": "PLATFORM_TYPE", "acceptedValues": ["FULLY_MANAGED"]}', NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('ea8dcd47-7c5c-40b7-8413-bbc93b482d97', 'e46f2065-7899-4d6c-9ea8-2c6cb89911f3', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that all sensitive personal data is encrypted at rest so data is further protected from potential breaches.', 'If the digital solution stores personal data:
1. sensitive personal data must be encrypted by the digital solution when at rest.
2.  encryption should be in line with approved encryption standards.
3. the digital solution should verify that the encryption was successful, and the data remains encrypted at rest.
4. the digital solution should not allow unencrypted personal data to be stored.
5. the digital solution should provide a report/log confirming that the data encryption process was successful for audit and compliance purposes.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('1e81256e-4178-47de-8101-cd738d865977', '2042e88c-f3c3-4f62-a52d-0450f9b0742d', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that all sensitive information is removed when production data is used in non-production environments.', '1. Production data without proper masking or sanitization must not be handled outside of production environment.
2. If the project requires to handle production data (especially personal data or confidential and Highly Confidentia) outside of production, an anonymization tool must be used.
3. Confidential or Highly Confidentia data must only be stored when necessary.
4. Confidential or Highly Confidentia data must be encrypted at rest. 
5. Confidential or Highly Confidentia data must be anonymized and filtered from production environments if they will be used in non-product environments (qualification, development, etc.).
6. Confidential or Highly Confidentia data must not be made public.
7. Test data must be deleted from the testing environment after finishing the tests', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["CONFIDENTIAL", "HIGHLY_CONFIDENTIAL"], "operator": "IN", "outcomeKey": "CONFIDENTIALITY_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('a53aad17-b139-4361-93d1-ec800561656d', '2dc45294-6d91-4898-8f42-804b7effd193', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure monitoring mechanisms are in place to detect cybersecurity threats.', '1. All of the digital solution’s infrastructure components must be centrally monitored and tracked with EDR tools. 
2. The triggers and rules for receiving monitoring alerts must be defined; examples of triggers include: 
•	Malicious activity
•	User malicious behavior 
•	Endpoint monitoring (file integrity, process execution, registry changes)
•	Indicators of compromise (IOC)
•	Threat intelligence

3. The digital solution’s infrastructure monitoring logs must be enabled and forwarded to a cybersecurity monitoring platform. 
4. Antimalware solutions must be deployed', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('3a6d661c-b170-40a8-93c5-5a8935f56e7f', 'b11d737b-5521-48c9-9281-4c6c18d73a46', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure my digital solution is connected to a log escalation and monitoring solution for active incident detection.', '1. The associated log escalation and monitoring solution must:
• Record all connection, access control and validation failures – all server-side entries must be recorded with sufficient user context to identify suspicious or malicious accounts, and kept for a sufficient period of time to permit a deferred investigation; Or
• Implement an effective alert process so that suspicious activities are detected and processed in a timely manner. (e.g. automated alerts are triggered by the log analysis integrated in the SOC).

2. Every log entry should include:
• The date and time when the event occurred.
• The location (IP address, device, etc.) where the event occurred.
• The source of the event (e.g. the screen or page accessed).
• The outcome of the event (e.g. successful login, failed login, account locked due to too many failed attempts, etc.).
• The identity of any individuals, subjects, or objects/entities associated with the event, (e.g. user ID, role, etc.).

3. The digital solution must store logs in a secure manner, preventing unauthorized access, modification, or deletion.

4. The digital solution must provide a function for the system administrator to view, search, and analyze the logs.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["EXTERNALLY_MANAGED_PLATFORM"], "operator": "IN", "outcomeKey": "PLATFORM_HOSTING"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('070565db-f711-4b14-b4d5-83ba9bd340fe', 'e8c654fb-1faa-4892-919d-e054adc32133', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure the website is equipped with tools to accurately measure usage (e.g., visits and page views) and to produce analytics reports for tracking purposes.', 'All websites must integrate with analytics technology that at a minimum track:
•	Number of visits
•	Engagement
•	Sessions per users 
•	Session time', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('2804bfc5-df53-4ada-8831-7b6c6a686aac', 'd7ef72f3-7a62-4fc5-aa23-0c172f9d3526', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall provide mechanisms enabling human review, approval, intervention, or override of AI outputs where required.', 'The solution shall provide mechanisms allowing human review, approval, intervention, or override of AI-generated outputs where required. Human oversight responsibilities shall be documented and assigned. The solution shall prevent autonomous execution of actions requiring human approval. Where applicable, evidence of human review or approval shall be retained for audit purposes.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('abed2d93-aa6c-45a4-bf69-e52686472be2', 'b66bb021-7486-40cb-8f7d-d9a91fcd8d04', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'AI-generated content shall be clearly distinguishable from human-generated content.', 'AI-generated content shall be clearly distinguishable from human-generated content. Users shall be informed when content, recommendations, or responses are generated by AI. AI labels shall be preserved when outputs are exchanged with other digital solutions where technically feasible. Labeling mechanisms shall be consistently applied across all user interfaces.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('a75bbab5-8655-4cbf-9ad1-97b9f51c805a', '6c43b8a0-5150-4dcb-b4fc-64cd0fe6eb4b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall provide explanations appropriate to the audience regarding how AI-generated outputs are produced.', 'The solution shall provide information describing how AI-generated outputs are produced. Explanations shall be appropriate for the intended audience and use case. The key factors, data sources, or inputs influencing the output shall be identifiable where technically feasible. Limitations and known constraints of the AI solution shall be documented and available to users.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('07e365b5-8114-4095-bc17-2fcda819eac6', '0a01bf0f-7284-4ac8-948c-6ea171b5cad3', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall maintain traceability of AI models, prompts, configurations, knowledge sources, and generated outputs where required to support audit, investigation, troubleshooting, compliance, and lifecycle management activities.', 'The solution shall maintain traceability of AI model versions, prompts, configurations, knowledge sources, and generated outputs where applicable. Traceability information shall support audit, investigation, troubleshooting, compliance, and model governance activities. Records shall be protected against unauthorized modification and retained according to applicable retention requirements. Traceability information shall be retrievable throughout the AI solution lifecycle.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('06c89174-6505-4a60-85e6-10fefdb0c103', 'ca7891f6-995f-4351-86ae-616665f408f1', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure my digital solution''s infrastructure is up to date and can be patched overtime to prevent cybersecurity vulnerabilities.', '1. The Operating Systems of the infrastructure of the digital solution are not obsolete and supported by Opella. 
2. The systems support regular updates through Opella patching solution and are enrolled in Up2date.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('f229b1d9-92ee-4ba5-95be-e1b8fa7c3971', '32e29ebb-0794-4c92-8aaf-1230c056de1d', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'CYBER_SECURITY', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure my application is robust against cybersecurity vulnerabilities and that a patching strategy can be defined.', '1. All unnecessary softwares must be removed from the infrastructure. 
2. All softwares running necessary for the solution must be up-to-date. 
3. Software''s agent and application must be patched regularly, at least when a high or critical vulnerability is disclosed.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('d753c674-a0d9-4caf-bdbd-b6a72f21b083', '2796144d-7837-4d31-ab5c-b31909ba9b5f', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that if a personal data portability request is received, we can fulfilll it', 'If the digital solution stores personal data, the digital solution should allow authorized users to search for and extract all data related to a specific data subject. The extract should be available in a common / machine readable format (csv, txt, xml, ...). Any extraction should be logged by the digital solution for audit and compliance purposes.
This feature/right will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users)', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('c0ed6467-02f0-41e0-91e0-5c07de57a671', '580ddb3a-e97e-4a8b-9d1b-53759d0b35ef', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that if a personal data correction request is received, we can fulfilll it', 'If the digital solution stores personal data, the digital solution should allow authorized users to rectify / update personal data of a data subject, if that is inaccurate or obsolete in respect to the purpose for which it is processed(*) Any extraction should be logged by the digital solution for audit and compliance purposes.
This feature will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users)

(*) therefore, this requirement to not apply to cases in which personal data shall be retained as it was at the time when it was collected or processed (e.g. for audit or regulatory purposes).', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('7abe4b86-779d-4847-906b-2d66b50d56b6', '4836d9d8-6be8-404b-a711-ce5a8a8d4f6a', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that if a personal data erasure request is received, we can fulfilll it', 'If the digital solution stores personal data, the digital solution should allow authorized users to delete/anonymize the personal data of a data subject. 
Any deletion should be logged by the digital solution for audit and compliance purposes.

This feature will normally be available to admins/super-users, unless such data extration is already required as a business/functional requirement (in that case, it will be open to authorized standard users).', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('295c5746-42d1-41ff-b7b4-43879af3291a', '1094a551-513d-4e12-b901-f6ff7741c37b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that all personal data is encrypted in transit so data is protected from unauthorized access and potential breaches.', 'If the digital solution exchanges personal data with other solutions or otherwise transmits personal data over a digital network:
1. all personal data must be encrypted when in transit.
2.  encryption should be in line with approved encryption standards.
3. the digital solution should verify that the data encryption was successful, and the data remains encrypted in transit.
4. the digital solution should not allow unencrypted personal data to be transmitted.
5. the digital solution should provide a report/log confirming that the data encryption process was successful for audit and compliance purposes.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('4290779b-4c85-456a-aee5-855f697bdf92', 'f63c030d-ece5-47e8-9ad6-e3368c7fdee8', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that personal data is not retained for longer than it is necessary to fulfill the purposes for which it is processed within the digital solution', 'If the digital solution stores personal data, the digital solution must include automated or semi-automated procedures to either delete or anonymize personal data when specific conditions (identified by the business owner) are met.

 Examples include, but are not limited to:
- personal data is deleted/anonymized if/when a certain condition is met (e.g. when the data subject withdraws consent)
- personal data is deleted/anonymized after a fixed period after a certain condition is met (20 years after the end of the employment contract, or 1 year after the data was collected).
Different subsets of personal data may be subject to different rules.

The digital solution should not allow for endless retention of personal data', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('aaecbdc3-1b5b-4a2d-b9b5-609985906796', '4c25426d-d58e-47a8-ba4d-9cb7ad9d90e6', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that personal data is not used and/or accessed when it is no longer needed for certain purposes and to certain users, but remains available to other users and for different purposes (if applicable)', 'If the digital solution stores personal data and supports the processing of such data for different purposes, criteria and controls shall be in place to ensure that once a certain purpose is achieved, the relevant personal data remains available for other purposes but:
a) it can no longer be processed for the already achieved purpose(s), and
b) access is restriced accordingly.

Example: in a payroll system, time and attendance information of the last working period is actively processed to generate the corresponding payslip and transmit information for payment. When this purpose is achieved, such personal data is no longer needed for that purpose (which is achieved) and is archived to fulfil other purposes, such as to comply with regulatory requirements and allow for audits. As such, the time and attendance information of a certain month shal be retained but it must be frozen (no changes possible), and access should be restriced to those who may need access for regulatory or audit purpose. When all the purposes are achieved, personal data must be deleted or anonymized (see the previous NFR).

Example: user data is processed to allow for login, and for activity tracking. When the user is terminated, the personal data of the user does no longer allow access to the system, but the data is retained for a longer period, for security and audit purpose.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('6dff452b-28d9-4be0-9910-87df9829c5e5', '95c51290-a68f-4a03-8375-c4f6a78d7722', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to facilitate responsible handling of reports including personal data by means of labelling', 'If the digital solution includes the possibility to extract/export reports including personal data, such reports shall:
- include a footer/header disclaimer such as "This report contains personal data. Handle carefully to prevent unauthorized or unnecessary disclosure and dispose of it when no longer necessary"
- includes the name of the user that exported/downloaded the report, and the timestamp.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('41871b4d-f424-43ef-b925-13f5a25315ba', 'ed37a4de-4573-4412-9ed0-bd9b34a10261', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that the default configuration or user''s options is the most conservative in terms of privacy, in accordance with the privacy y default principle / obligation', 'If the digital solution allows user to certain choices concerning their own personal data, and/or to set certain preferences concerning personal data, the default value of each choice/preference must be the least intrusive.

Examples:
- users can choose whether to display their full name or only initials to other uses <-- default = initials
- users can choose whether to share activity logs for product improvement or not <-- default = no
- users can choose whether to give feedback or not regarding certain features of the application <-- default = no
- users can choose whether their status (active or inactive) can be visible to other users <-- dafault = not visible
- etc.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}, {"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('71f8fb9d-6e36-4008-b870-62cabd4b368a', '8b060bbd-13b8-40f4-a8df-0ea83b8e2a00', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that users are provided with appropriate information concerning the intended use of their data, as required by the law', 'If the digital solution allows users to input personal data about them, an appropriate privacy notice muct be available to users and mut be accessible from the digital solution itself  (contact the Privacy Office to get support with regards to identification or drafting of the notice)', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('561f2fc2-25f6-46ca-a557-2282ea2f3619', 'de2316c3-de8d-43d1-a1dd-eb583616197e', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DATA_PRIVACY_OFFICE', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'I want to ensure that data is not exposed to users who don''t really need it, as this would constitute a data breach.', 'Ensure that access to personal data and related functions of the digital solution is restricted to authorized users based on defined roles and legitimate business needs. Access shall be governed by a formal authorization process and implemented through appropriate authentication mechanisms, role-based access controls, and least-privilege principles. Access rights shall be appropriately provisioned, periodically reviewed, modified, and revoked throughout the user lifecycle.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["TECHNICAL_PERSONAL_DATA", "GENERAL_PERSONAL_DATA", "SENSITIVE_PERSONAL_DATA"], "operator": "IN", "outcomeKey": "PERSONAL_DATA_TYPE"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('fa246bfe-5d53-400f-97a2-b34dcb53ddc4', '93b1d6e0-a1f3-4c5b-bf1a-06fd404da816', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall support monitoring of AI performance, quality, and reliability over time.', 'The solution shall support monitoring of AI quality, reliability, and performance. Performance thresholds and monitoring metrics shall be defined. Mechanisms shall exist to detect degradation of AI performance over time. Monitoring results shall be periodically reviewed.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_LIMITED", "AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('00999338-ef6e-40ca-8c19-fb11160c9c8c', '7612dbd5-de5c-466b-a2c6-11d74e9bad0b', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall support storage and retrieval of AI testing, evaluation, and validation evidence', 'Evidence of AI testing, evaluation, and validation activities shall be maintained. Evaluation results shall be traceable to the deployed version of the AI solution. Evaluation evidence shall be retrievable for audits and reviews. Approved acceptance criteria shall exist before deployment.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('de69e013-aef2-4146-91d7-6ea893db714e', '601bb291-306b-475d-a42e-87df03a8fa38', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall maintain governance and traceability of the knowledge sources used to generate AI outputs', 'Knowledge sources used by the AI solution shall be identified and documented. Ownership of knowledge sources shall be defined. Processes shall exist to review and maintain the quality of knowledge sources. AI solutions shall only use authorized knowledge sources.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false),
	('7999d0ce-0e88-4c84-bd34-ebd866334369', 'c90b93f6-d933-4648-a7bc-9c5d6d3e61bf', 1, 'RISK_PROFILE_V1', 'INITIAL_IMPORT', 'DIGITAL_DATA', 'MANAGE_DELIVERY', 'BUILD', 'SELF_ATTESTATION', 'The solution shall implement safeguards to reduce the risk of harmful, inaccurate, biased, or inappropriate outputs.', 'The solution shall implement safeguards to reduce the likelihood of harmful, inaccurate, biased, or inappropriate outputs. Mechanisms shall exist to identify and report unsafe AI outputs. Safety controls shall be periodically reviewed and updated. Documented mitigation measures shall exist for identified AI risks.', '', '', '', 'OUTCOME_TRIGGERED', '{"groups": [{"conditions": [{"values": ["WEBSITE", "MOBILE_APP", "CHATBOT"], "operator": "IN", "outcomeKey": "PROPERTY_TYPE"}, {"values": ["AI_HIGH"], "operator": "IN", "outcomeKey": "AI_RISK_CLASSIFICATION"}]}]}', NULL, NULL, current_setting('dpr.catalogue_actor_user_id'), '2026-09-09 11:16:30.079', '2026-09-09 11:16:30.079', NULL, NULL, false);


--
-- PostgreSQL database dump complete
--


DO $dpr_prod_verify$
BEGIN
  IF (SELECT count(*) FROM public.region) <> 8
     OR (SELECT count(*) FROM public.country) <> 71
     OR (SELECT count(*) FROM public.brand) <> 90
     OR (SELECT count(*) FROM public.brand_country_availability) <> 2649
     OR (SELECT count(*) FROM public.control_definition) <> 42
     OR (SELECT count(*) FROM public.control_definition_version) <> 42
     OR (SELECT count(*) FROM public.nfr_definition) <> 52
     OR (SELECT count(*) FROM public.nfr_definition_version) <> 52
     OR (SELECT count(*) FROM public.audit_event) <>
          current_setting('dpr.catalogue_audit_count_before')::bigint + 188 THEN
    RAISE EXCEPTION 'Unexpected import counts; ROLLBACK required';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT created_by_user_id FROM public.control_definition
      UNION ALL SELECT created_by_user_id FROM public.control_definition_version
      UNION ALL SELECT created_by_user_id FROM public.nfr_definition
      UNION ALL SELECT created_by_user_id FROM public.nfr_definition_version
    ) AS creators
    WHERE created_by_user_id IS DISTINCT FROM current_setting('dpr.catalogue_actor_user_id')
  ) THEN
    RAISE EXCEPTION 'Incorrect import attribution; ROLLBACK required';
  END IF;
END
$dpr_prod_verify$;
COMMIT;

SELECT 'regions' AS item, count(*) AS count FROM public.region
UNION ALL SELECT 'countries', count(*) FROM public.country
UNION ALL SELECT 'brands', count(*) FROM public.brand
UNION ALL SELECT 'brand_country_links', count(*) FROM public.brand_country_availability
UNION ALL SELECT 'controls', count(*) FROM public.control_definition
UNION ALL SELECT 'control_versions', count(*) FROM public.control_definition_version
UNION ALL SELECT 'nfrs', count(*) FROM public.nfr_definition
UNION ALL SELECT 'nfr_versions', count(*) FROM public.nfr_definition_version;

SELECT a.entity_type, a.action, u.email AS actor, count(*) AS audit_records
FROM public.audit_event a
JOIN public."user" u ON u.id = a.actor_user_id
WHERE (a.entity_type = 'CONTROL_DEFINITION' AND a.entity_id IN (SELECT id FROM public.control_definition))
   OR (a.entity_type = 'CONTROL_DEFINITION_VERSION' AND a.entity_id IN (SELECT id FROM public.control_definition_version))
   OR (a.entity_type = 'NFR_DEFINITION' AND a.entity_id IN (SELECT id FROM public.nfr_definition))
   OR (a.entity_type = 'NFR_DEFINITION_VERSION' AND a.entity_id IN (SELECT id FROM public.nfr_definition_version))
GROUP BY a.entity_type, a.action, u.email
ORDER BY a.entity_type;
