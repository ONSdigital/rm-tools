-- Sample Schema
-- Select data from sample service 
-- BY sampleuniref or ALL 
SELECT *     
FROM sample.sampleunit su
   , sample.samplesummary ss
WHERE su.samplesummaryfk = ss.samplesummarypk
--AND su.sampleunitref = '49900000576';

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- Collection Exercise Schema
-- Select information about the Collection Exercise 
-- BY survey AND/OR exercise OR ALL
SELECT ee.exerciseref
     , ee.scheduledstartdatetime
FROM collectionexercise.survey es
   , collectionexercise.collectionexercise ee
WHERE ee.surveyfk      = es.surveypk 
--AND es.surveyref     = '221'
--AND ee.exerciseref   = '221_201712';

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


-- Case Schema
-- Select case state
-- BY samplunit ref OR ALL
SELECT c.id as case_uuid
     , c.casePK 
     , c.statefk 
     , c.sampleunittype
FROM casesvc.casegroup cg
   , casesvc.case c
WHERE cg.casegrouppk   = c.casegroupfk
--AND cg.sampleunitref = '49900000576';


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


-- Case Schema
-- Case Events
-- Select case events for every case
-- BY samplunitref OR ALL
SELECT * FROM 
(
SELECT
  events.sampleunitref 
, events.sampleunittype
, events.caseref
, events.case_uuid
, events.case_created
, events.action_created
, events.action_cancellation_created
, events.action_cancellation_completed
, events.action_completed
, events.action_updated     
, events.respondent_account_created
, events.secure_message_sent_ind                                                                                           
, events.respondent_enroled         
, events.access_code_authentication_attempt_ind 
, events.collection_instrument_downloaded_ind 
, events.unsuccessful_response_upload_ind  
, events.successful_response_upload_ind 
, events.offline_response_processed_ind     
FROM 
(SELECT 
    cg.sampleunitref
  , c.sampleunittype 
  , c.caseref
  , c.id as case_uuid
  -- response chasing categories
  , MAX(CASE WHEN ce.categoryFK = 'ACCESS_CODE_AUTHENTICATION_ATTEMPT'  THEN 1 ELSE  0 END) access_code_authentication_attempt_ind 	--(B)  -- count distinct event
  , SUM(CASE WHEN ce.categoryFK = 'RESPONDENT_ACCOUNT_CREATED' 		THEN 1 ELSE  0 END) respondent_account_created 			--(B)  -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'RESPONDENT_ENROLED' 			THEN 1 ELSE  0 END) respondent_enroled 				--(B)  -- count all events
  , MAX(CASE WHEN ce.categoryFK = 'COLLECTION_INSTRUMENT_DOWNLOADED'    THEN 1 ELSE  0 END) collection_instrument_downloaded_ind	--(BI) -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'SUCCESSFUL_RESPONSE_UPLOAD' 		THEN 1 ELSE  0 END) successful_response_upload_ind		--(BI) -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'SECURE_MESSAGE_SENT' 	        THEN 1 ELSE  0 END) secure_message_sent_ind 	                --(BI) -- count distinct event
  -- remaining categories
  , SUM(CASE WHEN ce.categoryFK = 'CASE_CREATED'                        THEN 1 ELSE  0 END) case_created 				--(B,BI) -- count all event
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CREATED'                      THEN 1 ELSE  0 END) action_created  				--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CANCELLATION_COMPLETED' 	THEN 1 ELSE  0 END) action_cancellation_completed 		--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CANCELLATION_CREATED' 	THEN 1 ELSE  0 END) action_cancellation_created 		--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_COMPLETED' 			THEN 1 ELSE  0 END) action_completed 				--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_UPDATED' 			THEN 1 ELSE  0 END) action_updated 				--(B,BI) -- count all events  
  , MAX(CASE WHEN ce.categoryFK = 'OFFLINE_RESPONSE_PROCESSED' 		THEN 1 ELSE  0 END) offline_response_processed_ind		--(BI)	 -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'UNSUCCESSFUL_RESPONSE_UPLOAD' 	THEN 1 ELSE  0 END) unsuccessful_response_upload_ind 		--(BI)   -- count distinct event   
FROM   casesvc.caseevent ce
RIGHT OUTER JOIN casesvc.case c  ON c.casePK = ce.caseFK 
INNER JOIN casesvc.casegroup cg  ON c.casegroupFK = cg.casegroupPK
GROUP BY cg.sampleunitref
       , c.sampleunittype
       , c.casePK) events
ORDER BY events.sampleunitref
       , events.sampleunittype
       , events.caseref
) all_events
--WHERE all_events.sampleunitref = '49900000576';

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


-- Case Schema
-- Case Events
-- Select totals of case events grouped by samplunittype
SELECT
  events.sampleunittype
, SUM(events.case_created)                           case_created
, SUM(events.action_created)                         action_created
, SUM(events.action_cancellation_created)            action_cancellation_created
, SUM(events.action_cancellation_completed)          action_cancellation_completed
, SUM(events.action_completed)                       action_completed
, SUM(events.action_updated)                         action_updated
, SUM(events.respondent_account_created)             respondent_account_created
, SUM(events.secure_message_sent_ind)                secure_message_sent_ind                                                                 
, SUM(events.respondent_enroled)                     respondent_enroled      
, SUM(events.access_code_authentication_attempt_ind) access_code_authentication_attempt_ind
, SUM(events.collection_instrument_downloaded_ind)   collection_instrument_downloaded_ind
, SUM(events.unsuccessful_response_upload_ind)       unsuccessful_response_upload_ind
, SUM(events.successful_response_upload_ind)         successful_response_upload_ind
, SUM(events.offline_response_processed_ind)         offline_response_processed_ind
FROM 
(SELECT 
  -- response chasing categories
    cg.sampleunitref
  , c.sampleunittype
  , c.casepk
  , MAX(CASE WHEN ce.categoryFK = 'ACCESS_CODE_AUTHENTICATION_ATTEMPT'  THEN 1 ELSE  0 END) access_code_authentication_attempt_ind 	--(B)  -- count distinct event
  , SUM(CASE WHEN ce.categoryFK = 'RESPONDENT_ACCOUNT_CREATED' 		THEN 1 ELSE  0 END) respondent_account_created 			--(B)  -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'RESPONDENT_ENROLED' 			THEN 1 ELSE  0 END) respondent_enroled 				--(B)  -- count all events
  , MAX(CASE WHEN ce.categoryFK = 'COLLECTION_INSTRUMENT_DOWNLOADED'    THEN 1 ELSE  0 END) collection_instrument_downloaded_ind	--(BI) -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'SUCCESSFUL_RESPONSE_UPLOAD' 		THEN 1 ELSE  0 END) successful_response_upload_ind		--(BI) -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'SECURE_MESSAGE_SENT' 	        THEN 1 ELSE  0 END) secure_message_sent_ind 	                --(BI) -- count distinct event
  -- remaining categories
  , SUM(CASE WHEN ce.categoryFK = 'CASE_CREATED'                        THEN 1 ELSE  0 END) case_created 				--(B,BI) -- count all event
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CREATED'                      THEN 1 ELSE  0 END) action_created  				--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CANCELLATION_COMPLETED' 	THEN 1 ELSE  0 END) action_cancellation_completed 		--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_CANCELLATION_CREATED' 	THEN 1 ELSE  0 END) action_cancellation_created 		--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_COMPLETED' 			THEN 1 ELSE  0 END) action_completed 				--(B,BI) -- count all events
  , SUM(CASE WHEN ce.categoryFK = 'ACTION_UPDATED' 			THEN 1 ELSE  0 END) action_updated 				--(B,BI) -- count all events  
  , MAX(CASE WHEN ce.categoryFK = 'OFFLINE_RESPONSE_PROCESSED' 		THEN 1 ELSE  0 END) offline_response_processed_ind		--(BI)	 -- count distinct event
  , MAX(CASE WHEN ce.categoryFK = 'UNSUCCESSFUL_RESPONSE_UPLOAD' 	THEN 1 ELSE  0 END) unsuccessful_response_upload_ind 		--(BI)   -- count distinct event   
FROM   casesvc.caseevent ce
RIGHT OUTER JOIN casesvc.case c  ON c.casePK = ce.caseFK 
INNER JOIN casesvc.casegroup cg  ON c.casegroupFK = cg.casegroupPK
GROUP BY   cg.sampleunitref
         , c.sampleunittype
         , c.casepk) events
GROUP BY events.sampleunittype;


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- Action Schema
-- Actions
-- Supply case uuid OR LIST of case uuids to list actions by the case uuid(s) supplied 
-- To be able to calculate due date for the action rule the Collection Exercise date needs to be supplied

WITH get_case_uuid as 
(SELECT COALESCE(actions.case_uuid, cases.case_uuid) AS case_uuid,COALESCE(actions.actionplanfk, cases.actionplanfk) AS actionplanfk
FROM
(SELECT ac.id as case_uuid, ac.actionplanfk FROM action.case ac) cases
FULL JOIN 
(SELECT DISTINCT aa.caseid as case_uuid, aa.actionplanfk FROM action.action aa) actions
ON (cases.case_uuid = actions.case_uuid))
,use_case_uuid AS 
(SELECT '2017-09-12 00:00:00+01'::DATE as scheduledstartdatetime, case_uuid,actionplanfk
 FROM get_case_uuid
--  WHERE get_case_uuid.case_uuid  = '00a981ae-e7e0-4379-93af-c0ea2286fa6d'
--  WHERE get_case_uuid.case_uuid  = '0e46b8c1-4043-4d29-93ef-e76247e7640d'
WHERE get_case_uuid.case_uuid IN('00a981ae-e7e0-4379-93af-c0ea2286fa6d','0e46b8c1-4043-4d29-93ef-e76247e7640d')
)
SELECT 
       row_number() OVER (PARTITION BY use_case_uuid.case_uuid ORDER BY use_case_uuid.case_uuid,ar.daysoffset) AS rule_num  
     , use_case_uuid.case_uuid as case_uuid    
     , ar.description
     , now()::DATE AS report_date
     , ar.daysoffset     
     , CASE WHEN action_case.case_startdate::date IS NULL THEN 'NO' ELSE 'YES' END AS case_actionable   
     , action_case.case_startdate::date AS actioncase_startdate  
     , use_case_uuid.scheduledstartdatetime::date as ce_scheduled_start
      ,(COALESCE(action_case.case_startdate,use_case_uuid.scheduledstartdatetime) + interval '1' day * ar.daysoffset)::date  AS date_due 
     , EXTRACT(DAY FROM (now() - COALESCE(action_case.case_startdate,use_case_uuid.scheduledstartdatetime))) AS days_passed     
     , CASE WHEN EXTRACT(DAY FROM (now() - COALESCE(action_case.case_startdate,use_case_uuid.scheduledstartdatetime))) >= ar.daysoffset THEN 'YES' ELSE 'NO' END AS rule_due 
     , CASE WHEN action_case.actionstate IS NULL THEN 'NO' ELSE 'YES' END AS action_created  
     , action_case.actionstate
     , action_case.createddatetime
FROM 
  use_case_uuid
, action.actionrule ar
,(SELECT COALESCE(cases.actionplanFK,actions.actionplanFK)     AS  actionplan
           , cases.actionplanstartdate                         AS case_startdate
           , actions.createddatetime
           , COALESCE(cases.actionrulePK,actions.actionruleFK) AS actionrule
           , COALESCE(cases.actiontypeFK,actions.actiontypeFK) AS actiontype
           , actions.stateFK                                   AS actionstate
           , COALESCE(cases.caseid,actions.caseid)             AS case_uuid
      FROM            (SELECT c.actionplanFK
                            , c.actionplanstartdate::DATE
                            , c.id as caseid
                            , c.casePK
                            , r.actionrulePK
                            , r.actiontypeFK
                            , c.id
                       FROM  action.case c
                           , action.actionrule r
                           , use_case_uuid
                       WHERE c.actionplanFK = r.actionplanFK
                       AND use_case_uuid.case_uuid = c.id
                       AND use_case_uuid.actionplanfk = c.actionplanfk) cases
            FULL JOIN (SELECT a.actionplanFK
                            , a.createddatetime::DATE
                            , a.caseFK
                            , a.caseid
                            , a.actionruleFK
                            , a.actiontypeFK
                            , a.stateFK
                       FROM action.action a
                           ,use_case_uuid
                       WHERE a.caseid = use_case_uuid.case_uuid
                       AND use_case_uuid.actionplanfk = a.actionplanfk) actions
     ON (actions.actionplanFK = cases.actionplanFK 
     AND actions.actionruleFK = cases.actionrulePK
     AND actions.actiontypeFK = cases.actiontypeFK
     AND actions.caseFK       = cases.casePK) 
     GROUP BY case_uuid, actionplan, actionplanstartdate, actionrule, actiontype, actionstate, createddatetime
) action_case
WHERE use_case_uuid.case_uuid = action_case.case_uuid
AND ar.actionrulepk = action_case.actionrule
      

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- Action Schema
-- Actions
-- Choose WHERE clause
 


       
WITH action_results AS (SELECT  template.actionplan                            AS actionplan
                                , template.plan_description                 AS action_plan_name
                                , template.type_description                 AS action_type
                                , action_case_cnt.actionplanstartdate::date AS action_plan_startdate      
                                , template.daysoffset                       AS daysoffset
                                , template.handler                          AS handler
                                , COALESCE(action_case_cnt.cnt,0) AS cnt
                                , action_case_cnt.actionstate     AS action_state     
                          FROM (SELECT COALESCE(cases.actionplanFK,actions.actionplanFK) AS  actionplan
                                     , cases.actionplanstartdate
                                     , actions.createddatetime
                                     , COALESCE(cases.actionrulePK,actions.actionruleFK) AS actionrule
                                     , COALESCE(cases.actiontypeFK,actions.actiontypeFK) AS actiontype
                                     , actions.stateFK                                   AS actionstate
                                     , COUNT(*) cnt
                                FROM (SELECT  c.actionplanFK
                                            , c.actionplanstartdate::DATE
                                            , c.casePK
                                            , r.actionrulePK
                                            , r.actiontypeFK
                                      FROM  action.case c
                                          , action.actionrule r
                                      WHERE c.actionplanFK = r.actionplanFK) cases
                                      FULL JOIN (SELECT a.actionplanFK
                                                      , a.createddatetime::DATE
                                                      , a.caseFK
                                                      , a.actionruleFK
                                                      , a.actiontypeFK
                                                      , a.stateFK
                                                 FROM action.action a) actions
                                      ON (actions.actionplanFK = cases.actionplanFK 
                                      AND actions.actionruleFK = cases.actionrulePK
                                      AND actions.actiontypeFK = cases.actiontypeFK
                                      AND actions.caseFK       = cases.casePK) 
                              GROUP BY actionplan, actionplanstartdate, actionrule, actiontype, actionstate, createddatetime) action_case_cnt 
                              FULL JOIN (SELECT  r.actionplanFK AS actionplan
                                               , r.actionrulePK AS actionrule
                                               , r.actiontypeFK AS actiontype
                                               , p.description  AS plan_description
                                               , t.description  AS type_description
                                               , r.daysoffset  
                                               , t.handler    
                                         FROM   action.actionplan p
                                              , action.actionrule r
                                              , action.actiontype t
                                         WHERE p.actionplanPK = r.actionplanFK 
                                         AND   r.actiontypeFK = t.actiontypePK) template
                                         ON (template.actionplan = action_case_cnt.actionplan 
                                         AND template.actiontype = action_case_cnt.actiontype
                                         AND template.actionrule = action_case_cnt.actionrule)
                                         ORDER BY template.actionplan,template.daysoffset,template.plan_description,action_plan_startdate)

SELECT * FROM action_results
--WHERE action_plan_startdate IS NOT NULL AND action_state IS NULL      -- Cases present AND ACTIONABLE AND actions NOT YET created
--WHERE action_plan_startdate IS NOT NULL AND action_state IS NOT NULL  -- Cases present AND ACTIONABLE AND actions created
--WHERE action_plan_startdate IS NULL AND action_state IS NOT NULL      -- Cases INACTIONABLE AND action created
--WHERE action_plan_startdate IS NULL AND action_state IS NULL          -- No Cases/Cases INACTIONABLE and NO created actions - Lists seed data  