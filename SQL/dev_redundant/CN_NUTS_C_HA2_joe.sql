-- CN_NUTS_C_HA2
-- Percentage of children under age five years stunted (below -2 SD of height-for-age according to the WHO

-- CTE projecting age in months at time of measurement from RECH6: "Children Height/Weight/Hemoglobin"
-- These are calculated using the algorithm from the Stata - 
--   not using the field "HC1 = Child's afe in months"

-- Returns unweighted denominators which are slightly under the expected values from
-- the DHS API (e.g. http://api.dhsprogram.com/rest/dhs/data/CN_NUTS_C_HA2?f=html&surveyIds=EG2014DHS)
-- Tried using h6.hc1 instead of the computed value - this produces denominators significantly greater than
-- the expected values...
WITH h6 AS (
	SELECT
		surveyid,
		hhid,
		hc0,
		(DATE_PART('year', h6_with_dates.dom) - DATE_PART('year', h6_with_dates.dob)) * 12 +
			(DATE_PART('month', h6_with_dates.dom) - DATE_PART('month', h6_with_dates.dob)) AS agemonths,
		hc70
	FROM (
		SELECT
			-- Survey ID
			h6.surveyid,
			-- Household ID
			h6.hhid,
			-- Include FK to "Household Schedule"
			h6.hc0,
			-- Include height/age standard deviation
			h6.hc70,
			-- date of measurement
			TO_DATE(h6.hc18 || '/' || h6.hc17 || '/' || h6.hc19, 'dd/mm/yy') AS dom,
			-- date of birth
			TO_DATE(
				CASE
				WHEN h6.hc16::Integer > 31 THEN
					'15'
				ELSE
					h6.hc16
				END || '/' || h6.hc30 || '/' || h6.hc31, 'dd/mm/yy'
			) AS dob
		FROM
			dhs_data_tables."RECH6" h6
	) h6_with_dates
)
-- CTE projecting the required data from RECH1: "Household Schedule"
,h1 AS (
	SELECT
	h1.surveyid,
	h1.hhid,
	h1.hv103,
	h1.hvidx
	FROM
		dhs_data_tables."RECH1"  h1
	WHERE
		hv103::Integer = 1 -- Slept [in this house] last night = true
)
--select sum(denom_nonwt) d_nw, sum(denom_wt) d_w, sum(num_wt) / sum(denom_wt) val from (

SELECT 
h0.hv001 as clusterid
, min(locs.latitude) as latitude
, min(locs.longitude) as longitude
, min(locs.dhsid) as dhsid
, min(locs.urban_rural) as urban_rural
,SUM(
	CASE
	WHEN agemonths < 60
	THEN 1::Float
	ELSE 0::Float
	END
) as denom_nonwt
,SUM(
	CASE
	WHEN agemonths < 60 AND hc70::Integer < -200
	THEN 1::Float
	ELSE 0::Float
	END
) as num_nowt
,SUM(
	CASE
	WHEN agemonths < 60
	THEN h0.hv005::Float / 1000000
	ELSE 0::Float
	END
) as denom_wt
,SUM(
	CASE
	WHEN agemonths < 60 AND hc70::Integer < -200
	THEN h0.hv005::Float / 1000000
	ELSE 0::Float
	END
) as num_wt
FROM
        -- Household's basic data
	dhs_data_tables."RECH0" h0
INNER JOIN  
        -- Children Height/Weight/Hemoglobin
	h6
	ON  h6.surveyid = h0.surveyid
	AND h6.hhid = h0.hhid
INNER JOIN  
	-- Household Schedule - each line = household member
	h1
	ON  h1.surveyid = h0.surveyid
	AND h1.hhid = h0.hhid
	AND h1.hvidx = h6.hc0
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
	ON h0.hv001::Integer = locs.clusterid 
	AND h0.surveyid::Integer = locs.surveyid
WHERE h0.surveyid = '{SURVEYID}' and h6.surveyid = '{SURVEYID}' 
GROUP BY h0.hv001
ORDER BY h0.hv001::Integer

--) clust
