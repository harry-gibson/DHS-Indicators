--  AN_ANEM_W_ANY
-- Percentage of women aged 15-49 who are anaemic

-- I'm calculating this from the woman tables (v457) rather than the woman height-weight-haemoglobin HH tables
-- to save writing a new query from scratch, results should be the same
-- Denominator is all women aged 15-49
-- Numerator is all women aged 15-49 who have mild/moderate/severe anaemia

--select sum(denom_nonwt) d_nw, sum(denom_wt) d_w, sum(num_wt) / sum(denom_wt) val from (

SELECT
-- PERMA-BUMPH - same for all indicator extractions
h0.hv001 as clusterid
-- there is 1:1 join between cluster id and locs.* but as we're doing it inside the individual-level query
-- i.e. pre-grouping (to avoid another nested query) we need to use an aggregate func here
, min(locs.latitude) as latitude
, min(locs.longitude) as longitude
, min(locs.dhsid) as dhsid
, min(locs.urban_rural) as urban_rural

-- DENOMINATOR (UNWEIGHTED)
, SUM(	
	CASE WHEN 
		r01_wmn.v012::Integer BETWEEN 15 and 49 -- this is probably always true but may be survey dependent
	THEN 1 ELSE 0 END) as Denom_NonWt

-- DENOMINATOR (WEIGHTED)
, SUM(
	CASE WHEN 
		r01_wmn.v012::Integer BETWEEN 15 and 49
	THEN r01_wmn.v005::Float / 1000000 ELSE 0 END) as Denom_Wt

-- NUMERATOR (UNWEIGHTED)	
, SUM(
	CASE WHEN 
		r01_wmn.v012::Integer BETWEEN 15 and 49
		AND
		r42.v457::Integer in (1,2,3)
	THEN 1 ELSE 0 END) as Num_NonWt
	
-- NUMERATOR (WEIGHTED)	
, SUM(	
	CASE WHEN 
		r01_wmn.v012::Integer BETWEEN 15 and 49
		AND
		r42.v457::Integer in (1,2,3)
	THEN r01_wmn.v005::Float / 1000000 ELSE 0 END) as Num_Wt

FROM
dhs_data_tables."REC01" r01_wmn
LEFT OUTER JOIN 
	dhs_data_tables."REC42" r42
	ON r01_wmn.surveyid = r42.surveyid AND r01_wmn.caseid = r42.caseid
INNER JOIN -- we have to join to hh data to get the cluster id for grouping and location info
	dhs_data_tables."RECH0" h0
	-- dirty, but this is how it works
	ON r01_wmn.surveyid = h0.surveyid AND LEFT(r01_wmn.caseid, -3) = h0.hhid
LEFT OUTER JOIN
	(SELECT
		surveyid
		, dhsclust as clusterid
		, latnum as latitude
		, longnum as longitude
		, dhsid as dhsid
		, urban_rura as urban_rural
	FROM
		dhs_data_locations.dhs_cluster_locs
	) locs
ON h0.hv001::Integer = locs.clusterid AND h0.surveyid::Integer = locs.surveyid

WHERE h0.surveyid='{SURVEYID}'
	
GROUP BY h0.hv001
ORDER BY h0.hv001::Integer

--)clust